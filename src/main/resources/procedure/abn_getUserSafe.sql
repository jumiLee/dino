CREATE  PROCEDURE `abn_getUserSafe`($V_USER_ACCOUNT	INT /*나의 계정*/)
BEGIN
	select  t1.user_gold as safe_money
			,t1.safe_limit as safe_limit
			,t2.user_gold as user_gold
	 from 	user_safe t1, user_detail t2
	where 	t1.user_account = t2.user_account
	  and 	t1.user_account = $V_USER_ACCOUNT;
END