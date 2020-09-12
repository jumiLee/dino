CREATE PROCEDURE `abn_MgmtAttend`( 
	IN $V_JOB			INT,	/* 작업코드 (1: 출석등록, 2:보상수령업데이트)*/
	IN $V_USER_ACCOUNT	INT,	/* 사용자 계정	*/
    IN $V_ATTEND_TYPE	INT,	/* 출석타입			*/
    IN $V_DAY_NO		INT,	/* 일자일련번호	*/
    OUT $V_RESULT		INT 	/* 결과값				*/
)
BEGIN

/* 변수정의 */
	DECLARE $V_EXIST_ATTEND_CNT INT;  /* 이미 등록된 출석정보 수 */
	DECLARE $V_RWD_TYPE INT;					/* 보상타입		*/
	DECLARE $V_RWD_ID INT;						/* 보상아이디	*/	
    DECLARE  $V_RWD_RCV_FLAG INT; 				/* 보상수령여부 */
	DECLARE $V_RWD_SUB_ID INT;				/* 보상서브아이디(보물인경우만)	*/
	DECLARE	$V_RWD_RESULT INT;				/* 보상수령처리 결과 */
	DECLARE $V_MAX_ATTEND_CNT INT;		/* 총 출석일 수*/
	DECLARE $V_RECEIVE_MSG NVARCHAR(1000);
	DECLARE $V_RWD_NAME NVARCHAR(100); /* 뽑기권 보상의 경우 사용*/
	DECLARE $V_MSG_RESULT_MSG NVARCHAR(1000);
	DECLARE $V_MSG_RESULT INT ;  /* 뽑기권 보상의 경우 사용*/

/* 변수값 조회 */	
	IF  $V_DAY_NO is null or $V_DAY_NO =0 THEN
		SET $V_MAX_ATTEND_CNT = (select COUNT(day_no) from MST_ATTEND where attend_type=$V_ATTEND_TYPE);
		SET $V_DAY_NO = (select IFNULL(MAX(day_no),0)+1 from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE)	;
	
	/* 출석체크완료 시 데이터 초기화 */
		IF $V_MAX_ATTEND_CNT < $V_DAY_NO THEN
			DELETE FROM USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE;
			set $V_DAY_NO = 1;
		END IF;
	END IF;
	
	SET $V_EXIST_ATTEND_CNT = (select COUNT(user_account) from USER_ATTEND where user_account = $V_USER_ACCOUNT and attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO);
	SET $V_RESULT = 0;
	SET $V_RWD_RESULT = 0;
	
/* 출석 등록 */
	IF $V_JOB = 1 THEN
		IF (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 and DATE_FORMAT(attend_date,'%Y%m%d')=DATE_FORMAT(NOW(),'%Y%m%d') ) = 0 THEN -- 오늘 출석이력 없으면,
			IF $V_EXIST_ATTEND_CNT = 0 THEN	/* 오늘최초등록*/
				INSERT INTO USER_ATTEND (user_account, attend_type, attend_date, day_no, rwd_rcv_flag) VALUES($V_USER_ACCOUNT, $V_ATTEND_TYPE, NOW(), $V_DAY_NO, 2);
			ELSE
				SET $V_RESULT = -12 ;  /* 이미 등록 */ 
			END IF;
        END IF;
	END IF;
	
/* 보상수령업데이트 */
	IF $V_JOB = 2 THEN
	
	/* 보상수령조건 검사 */
		IF $V_EXIST_ATTEND_CNT = 0 THEN
			SET $V_RESULT = -21 ;		/* 등록된 출석정보 없음 */
		END IF;
		
		IF $V_RESULT = 0 THEN
		
			SET $V_RWD_RCV_FLAG = (select rwd_rcv_flag from USER_ATTEND where user_account = $V_USER_ACCOUNT and attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO );
			
			IF  $V_RWD_RCV_FLAG = 1 THEN
				SET $V_RESULT = -22;  /* 이미 수령했음 */			
			END IF;
		END IF;
		
	/* 보상 수령 */
		IF $V_RESULT = 0 THEN
			
			-- SELECT $V_RWD_TYPE = rwd_type, $V_RWD_ID = rwd_id, $V_RWD_SUB_ID = rwd_sub_id FROM MST_ATTEND WHERE attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO ;
            SELECT rwd_type, rwd_id, rwd_sub_id into $V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID FROM MST_ATTEND WHERE attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO ;
			/* -- 모두 우편함으로 보내도록 수정 
			IF ($V_RWD_TYPE = 21) THEN	-- 뽑기권 보상 지급
				SET $V_RWD_NAME = (select cd_value_nm from MST_CODE where cd_column='rwd_type' and cd_value=$V_RWD_TYPE );
				SET $V_RECEIVE_MSG = CONCAT('[출석보상] ' ,$V_RWD_NAME, '이 지급되었습니다.');
				CALL abn_mgmtReceiveBox (3, $V_USER_ACCOUNT, null,0,$V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RECEIVE_MSG, $V_MSG_RESULT, $V_MSG_RESULT_MSG);
			ELSE  -- 일반 보상 지급 
				CALL abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RWD_RESULT);
			END IF;
            */
            SET $V_RWD_NAME = (select f_getRwdName($V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID) );
			SET $V_RECEIVE_MSG = CONCAT('[Attendance] Please receive ' ,$V_RWD_NAME);
			CALL abn_mgmtReceiveBox (3, $V_USER_ACCOUNT, null,0,$V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RECEIVE_MSG, $V_MSG_RESULT, $V_MSG_RESULT_MSG);
			
		END IF;
		
	/* 보상 수령 결과 없데이트 */
		IF $V_RESULT = 0 THEN
		
			UPDATE USER_ATTEND 
			   SET rwd_rcv_flag = 1 , rwd_rcv_date = NOW()
			 WHERE user_account = $V_USER_ACCOUNT
			   AND attend_type	= $V_ATTEND_TYPE
			   AND day_no		= $V_DAY_NO ;
		END	IF;
		
	END IF;
END