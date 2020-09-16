CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_getUserDetail`($V_USER_ACCOUNT	INT /*나의 계정*/)
BEGIN
	
    select 	t1.user_account as user_account
			,t1.user_nickname as nickname
			,t2.user_point as user_point
	from mst_user t1, user_detail t2
	where t1.user_account = t2.user_account
	and t1.user_account=$V_USER_ACCOUNT;
END