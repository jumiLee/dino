CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_mgmtUserAchvReward`(
	$V_JOB_TYPE			INT,	-- 1: 개별보상처리, 2:일괄보상처리
    $V_USER_ACCOUNT 	INT,  	-- 사용자 계정 
    $V_ACHV_TYPE		INT,	-- 업적타입
    $V_ACHV_ID			INT,	-- 업적아이디 
    OUT $V_RESULT		INT,
    OUT $V_RESULT_MSG 	NVARCHAR(100) 
)
BEGIN

    DECLARE $V_NOTICE_RESULT INT; 
	DECLARE $V_RWD_RESULT INT; /* 보상 지급 결과 */
	DECLARE $V_ACHV_RWD_TYPE INT; DECLARE $V_ACHV_RWD_ID INT; DECLARE $V_ACHV_RWD_SUB_ID INT; DECLARE $V_ACHV_COMPLETE_CNT INT;
	DECLARE $V_USER_ACHV_CNT INT;
    DECLARE $V_RWD_RCV_FLAG INT;
	DECLARE vRowCount INT DEFAULT 0;
	DECLARE cur_AchvRwd CURSOR FOR 
		SELECT t1.achv_id, achv_rwd_type, achv_rwd_id, achv_rwd_sub_id, achv_complete_cnt FROM mst_achievement t1, user_achievement t2 
		 WHERE t1.achv_type = t2.achv_type and t1.achv_id = t2.achv_id 
		   AND t2.achv_complete_flag = 1 and t2.rwd_rcv_flag = 2 /* 완료/보상미수취만 조회  */
		   AND t1.achv_type =$V_ACHV_TYPE and t2.user_account = $V_USER_ACCOUNT;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vRowCount = 1; /* 데이터 없을 경우 처리 */

	SET $V_RESULT = 0;
	SET $V_RESULT_MSG = "success";
    
/* 개별 보상 처리 */
	IF ($V_JOB_TYPE = 1) then
	/* 1-1) 기본정보 조회 */
		SELECT achv_rwd_type, achv_rwd_id, achv_rwd_sub_id, achv_complete_cnt
		  INTO $V_ACHV_RWD_TYPE, $V_ACHV_RWD_ID, $V_ACHV_RWD_SUB_ID, $V_ACHV_COMPLETE_CNT
		  FROM mst_achievement
		 WHERE achv_type =$V_ACHV_TYPE AND achv_id =$V_ACHV_ID;
			  
	/*  1-2) 완료된 보상인지 조회 */
		select achv_cnt, rwd_rcv_flag INTO $V_USER_ACHV_CNT, $V_RWD_RCV_FLAG 
		  from user_achievement 
		 where user_account = $V_USER_ACCOUNT and achv_type =$V_ACHV_TYPE AND achv_id =$V_ACHV_ID;
		-- 이미 보상 수령
        IF ( $V_RWD_RCV_FLAG  = 1) then
			SET $V_RESULT = -10; 
			SET $V_RESULT_MSG = 'Already received!';
		END IF;
        -- 완료된 업적 아님
		IF ($V_USER_ACHV_CNT <> $V_ACHV_COMPLETE_CNT ) then
			SET $V_RESULT = -11; 
			SET $V_RESULT_MSG = 'Not completed!';
		END IF;
		
	/*  1-3) 보상처리	*/
		IF($V_RESULT = 0) then
			START transaction;
			/* 1-3-1) 보상지급 */
				IF ($V_ACHV_RWD_TYPE <> 21) then
					Call abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_ACHV_RWD_TYPE, $V_ACHV_RWD_ID, $V_ACHV_RWD_SUB_ID, $V_RWD_RESULT);
					IF ($V_RWD_RESULT <> 0 ) then
						SET $V_RESULT = -12;
					END IF;
				END IF;
      
			/*  1-3-2) 보상수취처리 */
				IF($V_RESULT = 0) then
					UPDATE user_achievement 
						 SET rwd_rcv_flag= 1 , rwd_rcv_dt = NOW()
					WHERE user_account = $V_USER_ACCOUNT and achv_type = $V_ACHV_TYPE and achv_id = $V_ACHV_ID;
				END IF;
			
			/*  1-3-3) 사용자 알림 업데이트 (업적 완료 후 보상수신 안한 업적이 없으면) */
				IF($V_RESULT = 0) then
					IF (select count(user_account) from user_achievement where user_account =$V_USER_ACCOUNT and rwd_rcv_flag = 2 and achv_complete_flag=1 and achv_type < 5) <= 0 then/* 전투 업적은 메인화면에 NEW 표시 안함 */
						-- Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT,3,2, $V_NOTICE_RESULT); 
                        Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT,
													3,	-- new_type
													1, 	-- check_flag
                                                    $V_NOTICE_RESULT); 
					END IF;
                    
				END IF;
    
			IF($V_RESULT <> 0 ) then
				ROLLBACK;
			ELSE
				COMMIT;
			END IF;

		END IF; /* end (1-3 보상처리) */
	
		/* 1-6) 업적보상수취 로그 
		IF ($V_RESULT =0) Then
			Call Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT,4,2,null,$V_ACHV_TYPE,$V_ACHV_ID,$V_ACHV_RWD_TYPE,$V_ACHV_RWD_ID,$V_ACHV_RWD_SUB_ID);
		END	IF;
         */
	END IF;/* end (job_type=1) */
	

/* 일괄 보상 처리 */	
	IF ($V_JOB_TYPE = 2) then 
	
		OPEN cur_AchvRwd;
		read_loop: loop
		FETCH cur_AchvRwd INTO $V_ACHV_ID, $V_ACHV_RWD_TYPE, $V_ACHV_RWD_ID, $V_ACHV_RWD_SUB_ID, $V_ACHV_COMPLETE_CNT;
		
		IF (vRowCount = 1) then
			LEAVE read_loop;
		END IF;

		/* 1. 보상처리 */
		IF($V_RESULT = 0 AND  $V_ACHV_RWD_TYPE <> 21) THEN
			START transaction;
			/* 1) 보상지급 */
				Call abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_ACHV_RWD_TYPE, $V_ACHV_RWD_ID, $V_ACHV_RWD_SUB_ID, $V_RWD_RESULT);
				
				IF ($V_RWD_RESULT <> 0 ) then
					SET $V_RESULT = -21;
				END IF; 
					
			/* 2) 보상수취처리 */
				IF($V_RESULT = 0) then
					UPDATE user_achievement 
					   SET rwd_rcv_flag= 1 , rwd_rcv_dt = NOW()
					 WHERE user_account = $V_USER_ACCOUNT and achv_type = $V_ACHV_TYPE and achv_id = $V_ACHV_ID;
				END IF;
				
				IF($V_RESULT <> 0 ) then
					ROLLBACK;
				ELSE
					COMMIT;
				END IF;
		END IF; /* End ($V_RESULT=0) */
				
		/* 업적보상수취 로그 
		IF ($V_RESULT =0) then
			CALL Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT,4,2,null,$V_ACHV_TYPE,$V_ACHV_ID,$V_ACHV_RWD_TYPE,$V_ACHV_RWD_ID,$V_ACHV_RWD_SUB_ID);
		END if;
		*/
		END LOOP read_loop;
		CLOSE cur_AchvRwd;
		
		/* 2. 사용자 알림 업데이트 */
		IF($V_RESULT = 0) then
			IF (select count(user_account) from user_achievement where user_account =$V_USER_ACCOUNT and rwd_rcv_flag = 2 and achv_complete_flag=1 and achv_type < 5) <=0 then
				Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT,3,1, $V_NOTICE_RESULT);
			END IF;
		END IF;
			
	END IF; /* end (job_type=2)*/
END