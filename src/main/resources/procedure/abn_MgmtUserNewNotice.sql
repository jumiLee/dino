CREATE PROCEDURE `abn_MgmtUserNewNotice`(
	$V_JOB_TYPE     INT, /* 1:등록*/
    $V_USER_ACCOUNT INT, /* 사용자 계정 */
    $V_NEW_TYPE     INT, 
    $V_CHECK_FLAG   INT,
    OUT $V_RESULT	INT
)
BEGIN
	
	
	SET $V_RESULT = 0; 

	IF($V_JOB_TYPE = 1 ) Then
	
		/* 이미 등록되어 있는 것인지 체크 */
		IF (select count(user_account) from USER_NEW_NOTICE where user_account = $V_USER_ACCOUNT and new_type = $V_NEW_TYPE and check_flag = $V_CHECK_FLAG) = 0 Then
		
				IF (select count(user_account) from USER_NEW_NOTICE where user_account = $V_USER_ACCOUNT and new_type = $V_NEW_TYPE) > 0 THEN
					
					UPDATE USER_NEW_NOTICE 
					   SET check_flag=$V_CHECK_FLAG
					 WHERE user_account = $V_USER_ACCOUNT and new_type = $V_NEW_TYPE;
					 
					
				ELSE
				
					INSERT INTO USER_NEW_NOTICE (user_account, new_type, check_flag) 
					VALUES ($V_USER_ACCOUNT, $V_NEW_TYPE,$V_CHECK_FLAG); 
					
				END IF;
		END IF;
	END IF;
END