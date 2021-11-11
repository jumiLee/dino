CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_MgmtUserNewNotice`(
	 $V_JOB_TYPE     INT 	-- 1: register or modify
    ,$V_USER_ACCOUNT INT 	
    ,$V_NEW_TYPE     INT 	-- 4: monster
    ,$V_CHECK_FLAG   INT	-- 1:new register, 2:new release
    -- ,OUT $V_RESULT	 INT
)
BEGIN
	
    IF($V_JOB_TYPE = 1 ) Then
	
		/* 이미 등록되어 있는 것인지 체크 */
		IF (select count(user_account) from user_new_notice where user_account = $V_USER_ACCOUNT and new_type = $V_NEW_TYPE and check_flag = $V_CHECK_FLAG) = 0 Then
		
				IF (select count(user_account) from user_new_notice where user_account = $V_USER_ACCOUNT and new_type = $V_NEW_TYPE) > 0 THEN
					UPDATE user_new_notice 
					   SET check_flag=$V_CHECK_FLAG
					 WHERE user_account = $V_USER_ACCOUNT and new_type = $V_NEW_TYPE;					
				ELSE
					INSERT INTO user_new_notice (user_account, new_type, check_flag) 
					VALUES ($V_USER_ACCOUNT, $V_NEW_TYPE,$V_CHECK_FLAG); 					
				END IF;
		END IF;
	END IF;
END