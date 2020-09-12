CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_mgmtUserAchv_out`(
	IN $V_JOB_TYPE		INT,	-- 1:업적 수행 업데이트
    IN $V_USER_ACCOUNT 	INT,  
    IN $V_TARGET_USER	NVARCHAR(20), -- 사용안함
    IN $V_ACHV_TYPE		INT,	
    IN $V_ACHV_ID		INT,	
    IN $V_ACHV_CNT		INT, 	
    OUT $V_RESULT		INT 
)
BEGIN
	
	DECLARE $V_ACHV_COMPLETE_CNT INT;
	DECLARE $V_ACHV_LIMIT_UNIT INT;
	DECLARE $V_ACHV_LIMIT_CNT INT;
	DECLARE $V_USER_ACHV_CNT INT;
	DECLARE $V_USER_ACHV_LIMIT_CNT INT; 
	DECLARE $V_CUR_ACTIVE_ACHV INT;

	DECLARE $STR_TARGET_USER BIGINT;

	SET $V_RESULT = 0;		
	SET $V_USER_ACHV_CNT=0;
	SET $V_USER_ACHV_LIMIT_CNT =0; 

	/* --1. 업적 수행 업데이트 */ 
	IF ($V_JOB_TYPE = 1) THEN
	/* 1-1) 업적업데이트 가능한지 조회 */
		/* 1-1-1) 해당업적이 활성화 상태인지 조회 */
		IF ($V_ACHV_TYPE = 1) THEN	/* 이벤트 업적일 경우는 시간도 체크 */
			SET $V_CUR_ACTIVE_ACHV = (select COUNT(achv_type) from mst_achievement 
									   where achv_type = $V_ACHV_TYPE and achv_id=$V_ACHV_ID 
										 and NOW() between achv_apply_fr_dt and achv_apply_to_dt 
										 and DATE_FORMAT(NOW(), '%k') between DATE_FORMAT(achv_apply_fr_dt, '%k') and DATE_FORMAT(achv_apply_to_dt, '%k')
									 );
		ELSE
			SET $V_CUR_ACTIVE_ACHV = (select COUNT(achv_type) from mst_achievement where achv_type = $V_ACHV_TYPE and achv_id=$V_ACHV_ID and NOW() between achv_apply_fr_dt and achv_apply_to_dt );
		END IF;
			
		IF ($V_CUR_ACTIVE_ACHV) = 0 THEN
			SET $V_RESULT = -111;	/* 해당기간에 적용되는 업적이 아님. */
		END IF;
		 
		 
		 /* 1-1-2) 해당업적의 완료회수 및 사용자 업적 수행 조회  */
		 IF ($V_RESULT = 0) THEN
		 
			SELECT achv_complete_cnt, achv_limit_unit, achv_limit_cnt
			  INTO $V_ACHV_COMPLETE_CNT,$V_ACHV_LIMIT_UNIT,$V_ACHV_LIMIT_CNT
			  FROM mst_achievement 
			 WHERE achv_type=$V_ACHV_TYPE and achv_id = $V_ACHV_ID;
			 
			SELECT achv_cnt,  achv_limit_cnt
			  INTO  $V_USER_ACHV_CNT,$V_USER_ACHV_LIMIT_CNT
			  FROM user_achievement 
			 WHERE user_account= $V_USER_ACCOUNT and achv_type=$V_ACHV_TYPE and achv_id = $V_ACHV_ID;
			
			IF ($V_ACHV_COMPLETE_CNT = $V_USER_ACHV_CNT) THEN
				SET $V_RESULT = -11 ; /* 이미 완료된 업적 */
			END IF; 
			
			IF ($V_RESULT = 0) THEN
			
				IF ($V_ACHV_LIMIT_UNIT IS NOT NULL AND $V_ACHV_LIMIT_CNT > 0) THEN /* 업적수행 제한회수가 있으면,	 */
					IF ($V_ACHV_LIMIT_CNT = $V_USER_ACHV_LIMIT_CNT)  THEN
						SET $V_RESULT = -12;
					END IF;
				END IF;
			END IF;
		END IF;

			
		/* 1-2) 기존 등록되어 있는 업적이면 업데이트 */
		IF ($V_RESULT =0) THEN
			IF (select count(*) from user_achievement where user_account= $V_USER_ACCOUNT and achv_type=$V_ACHV_TYPE and achv_id = $V_ACHV_ID) > 0 THEN
				/* 1-2-1) 업적수행 완료이면, */
				IF ($V_ACHV_COMPLETE_CNT = 	($V_USER_ACHV_CNT + $V_ACHV_CNT))  THEN
					UPDATE user_achievement
					   SET achv_cnt = achv_cnt + $V_ACHV_CNT ,achv_complete_flag=1, achv_complete_dt=NOW(), achv_upd_dt=NOW()
							,achv_limit_cnt = (achv_limit_cnt + 1)
					 WHERE user_account= $V_USER_ACCOUNT and achv_type=$V_ACHV_TYPE and achv_id = $V_ACHV_ID;
						
					IF ($V_ACHV_TYPE < 5) THEN /* 전투관련 업적은 업데이트 하지 않음 */
					/* 사용자 고지정보에 업적완료(NEW) 업데이트 */
						CALL abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT, 3,2, $V_RESULT);
					END IF;
				ELSE						
					UPDATE user_achievement
					 SET achv_cnt = achv_cnt + $V_ACHV_CNT, achv_upd_dt=NOW() 
					     ,achv_limit_cnt = (achv_limit_cnt + 1)
					 WHERE user_account= $V_USER_ACCOUNT and achv_type=$V_ACHV_TYPE and achv_id = $V_ACHV_ID;
				END	IF;	
			/* 1-3) 새로운 업적 등록	*/
			ELSE
				IF ($V_ACHV_LIMIT_UNIT > 0) THEN
					SET $V_USER_ACHV_LIMIT_CNT = 1; /* 업적수행 제한회수가 있으면,	수행제한회수 1 */
				END IF;
	
				IF ($V_ACHV_COMPLETE_CNT = 1) THEN /* 수행회수가 1이면, 등록동시 완료처리 */
					
					INSERT INTO user_achievement (user_account, achv_type, achv_id, achv_complete_flag, achv_complete_dt, rwd_rcv_flag, achv_cnt, achv_upd_dt, achv_limit_cnt)
					VALUES ($V_USER_ACCOUNT, $V_ACHV_TYPE, $V_ACHV_ID, 1,NOW(),2, $V_ACHV_CNT, NOW(), $V_USER_ACHV_LIMIT_CNT);
					
					/* 사용자 고지정보에 업적완료(NEW) 업데이트 */
					IF ($V_ACHV_TYPE < 5) THEN /* 전투관련 업적은 업데이트 하지 않음 .*/
						CALL abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT, 3,2, $V_RESULT);
					END IF;
				ELSE
					INSERT INTO user_achievement (user_account, achv_type, achv_id, achv_complete_flag, rwd_rcv_flag, achv_cnt, achv_upd_dt, achv_limit_cnt)
					VALUES ($V_USER_ACCOUNT, $V_ACHV_TYPE, $V_ACHV_ID, 2,2, $V_ACHV_CNT, NOW(), $V_USER_ACHV_LIMIT_CNT);
				END IF;
			END IF;
		END IF;
		
		/* 1-3) 업적 로그  */
		IF $V_RESULT =0 THEN
			/*SET $STR_TARGET_USER = Convert(BIGINT, $V_TARGET_USER);*/ /* 카톡아이디가 최대 18자리임. */
			SET $STR_TARGET_USER = CAST($V_TARGET_USER AS UNSIGNED INTEGER); /* 카톡아이디가 최대 18자리임. */
			-- CALL Log_BaseLog ($V_USER_ACCOUNT,$STR_TARGET_USER,4,1,null,$V_ACHV_TYPE,$V_ACHV_ID,$V_ACHV_CNT,$V_ACHV_COMPLETE_CNT,null); 
		END IF;
	END IF; /* end (job_type=1) */
	
END