CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_mgmtReceiveBox`(
	$V_JOB				INT,				/*  작업코드 (1: 개별수신, 2:일괄수신, 3: 지급) */
	$V_USER_ACCOUNT   	INT,				/*  사용자 계정 */
    $V_RECEIVE_SN		BIGINT,				/*  수신함 일련번호 */
    $V_SENDER_ACCOUNT 	INT,				/*  받는사용자 계정 */ 
    $V_GOOD_TYPE		INT,				/*  보낼 물건 타입 */
    $V_GOOD_ID			INT,				/*  보낼 물건 아이디 */
    $V_GOOD_SUB_ID		INT,				/*  보낼 물건 서브아이디(보물인 경우만) */
    $V_RECEIVE_MSG		VARCHAR(1000) CHARACTER SET utf8 ,		/*  보낼 메세지 */
    OUT $V_RESULT		INT , 				/* 결과값 */
    OUT $V_MSG			VARCHAR(100) 		/* 결과메세지 */
)
BEGIN
	
	DECLARE $V_RESULT_ITEM INT; DECLARE $V_RESULT_ITEM_MSG VARCHAR(100);
	DECLARE $V_RWD_RESULT INT; /* 보상 지급 결과 */
	DECLARE $V_NOTICE_RESULT INT; /* 알림업데이트 결과 */
	
	DECLARE vRowCount INT DEFAULT 0;
	DECLARE cur_RcvBox CURSOR FOR SELECT receive_sn, sender_account, good_type, good_id, good_sub_id FROM user_receive_box WHERE user_account = $V_USER_ACCOUNT AND check_flag = 2; /* 수신하지 않은 메세지들 */
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vRowCount = 1; /* 데이터 없을 경우 처리 */


	SET $V_RESULT = 0;
	SET $V_MSG='success';
	SET $V_RWD_RESULT = 0;
	SET $V_NOTICE_RESULT = 0;
	SET SQL_SAFE_UPDATES=0;
	
	
/* 개별 수신 처리  */
	IF($V_JOB = 1)	THEN
		/* 2-1 ) 필요한 변수 세팅 */
		SELECT  sender_account, good_type, good_id, good_sub_id
		  INTO $V_SENDER_ACCOUNT, $V_GOOD_TYPE, $V_GOOD_ID, $V_GOOD_SUB_ID
		  FROM user_receive_box
		 WHERE user_account = $V_USER_ACCOUNT AND receive_sn = $V_RECEIVE_SN;

		/* 2-1) 존재하는 메세지 번호인지 검사 */

		IF (select count(receive_sn) from user_receive_box where user_account = $V_USER_ACCOUNT and receive_sn = $V_RECEIVE_SN) =0 THEN
			SET $V_RESULT = -11 ;
		  SET $V_MSG = 'Not Exist Message No';
		END IF;
		
		IF ($V_RESULT = 0) THEN
			IF (select count(receive_sn) from user_receive_box where user_account = $V_USER_ACCOUNT and receive_sn = $V_RECEIVE_SN and check_flag=1 ) > 0 THEN
				SET $V_RESULT = -12;
				SET $V_MSG = 'Already received!';
			END IF;
		END IF;
		
		/* 2-2) 우편함 선물 지급 (뽑기권 제외) */
		IF ($V_RESULT = 0) THEN
			IF( $V_GOOD_TYPE < 20) THEN
				CALL abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_GOOD_TYPE, $V_GOOD_ID, $V_GOOD_SUB_ID, $V_RWD_RESULT);
			END IF;
			
			IF ($V_RWD_RESULT <> 0 ) Then
				SET $V_RESULT = -13; 
			end if;
		END IF;
		
		/* 2-3)  우편함 수신처리 */
		IF ($V_RESULT = 0) Then
		
		  UPDATE user_receive_box 
			 SET check_flag = 1 , check_dt = now()
		   WHERE user_account = $V_USER_ACCOUNT and receive_sn = $V_RECEIVE_SN;
		   
		  IF (ROW_COUNT() = 0 ) Then
			SET $V_RESULT = -14;
			SET $V_MSG = 'DB Error while updating message status';
		  END if;
		  
		  /* 사용자 알림 업데이트 (확인 안한 메세지가 없으면) */
		  IF (select count(user_account) from user_receive_box where user_account =$V_USER_ACCOUNT and check_flag = 2) = 0 then
		  	Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT,1,1, $V_NOTICE_RESULT);
		  END IF;
		END IF;
	END IF; /* end job_code=1 */
	
/*  일괄 수신 처리 (뽑기권은 일괄수신에서 제외) */
	IF($V_JOB = 2) Then	
		
		OPEN cur_RcvBox;
		read_loop: loop
		FETCH cur_RcvBox INTO $V_RECEIVE_SN, $V_SENDER_ACCOUNT, $V_GOOD_TYPE, $V_GOOD_ID, $V_GOOD_SUB_ID;
		
		IF (vRowCount = 1) then
			LEAVE read_loop;
		END IF;
		
			IF( $V_GOOD_TYPE <> 21 )	then	/* 뽑기권이 아니면 */
				
				IF ($V_GOOD_SUB_ID IS NULL) then
					SET $V_GOOD_SUB_ID = 0;
				END if;
					
				/* 우편함 선물 지급 */
				Call abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_GOOD_TYPE, $V_GOOD_ID, $V_GOOD_SUB_ID, $V_RWD_RESULT);
				
				IF ($V_RWD_RESULT <> 0 ) then
					SET $V_RESULT = -21; 
				END if;
				
				/* 수신함 상태 업데이트 */ 
				IF ($V_RESULT = 0) Then
					UPDATE user_receive_box 
					 SET check_flag = 1 , check_dt = now()
					 WHERE user_account = $V_USER_ACCOUNT and receive_sn = $V_RECEIVE_SN;      					 
				END If;
			END IF;
		
		END LOOP read_loop;

		CLOSE cur_RcvBox;
		
		/* 알림함 업데이트 */
		IF ($V_RESULT = 0) Then
			IF (select count(*) from user_receive_box where user_account = $V_USER_ACCOUNT and check_flag=2) = 0 then
				Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT,1,2, $V_NOTICE_RESULT);
			END If;
		END If;

		
	END IF;
	
	
/* 수신함 지급  */
	IF($V_JOB = 3) Then
		/*수신함에 넣을 메세지 길이 체크*/
		IF (length($V_RECEIVE_MSG) > 1000) Then
			SET $V_RESULT =  -51;
			SET $V_MSG = 'message lengthgth < 1000';
		END If;
		
		/* 수신함 지급 */
		IF($V_RESULT =0) Then
			INSERT INTO user_receive_box (user_account, sender_account, good_type, good_id, good_sub_id, issue_dt, receive_msg)
			VALUES ( $V_USER_ACCOUNT, $V_SENDER_ACCOUNT, $V_GOOD_TYPE, $V_GOOD_ID, $V_GOOD_SUB_ID, now(), $V_RECEIVE_MSG);
			
			IF (ROW_COUNT() = 0)  Then
				SET $V_RESULT = -52 ;
				SET $V_MSG = 'error while insert';
			END IF;
		END If;
		
		/* 사용자 알림 업데이트 */
		IF($V_RESULT =0) Then
			Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT,1,2, $V_NOTICE_RESULT);
		END If;
		
	END  IF;
END