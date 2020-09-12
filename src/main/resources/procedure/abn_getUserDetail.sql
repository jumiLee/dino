CREATE PROCEDURE abn_getUserDetail`($V_USER_ACCOUNT	INT /*나의 계정*/)
BEGIN
	
    select 	t1.user_account as user_account
			,t1.user_nickname as nickname
			,t1.user_img as user_image
			,t1.user_level as user_level
			,t2.user_gold as money
			,t2.user_coin as coin
			,t2.user_point as crystal
            ,t3.user_gold as safe_money
	from mst_user t1, user_detail t2, user_safe t3
	where t1.user_account = t2.user_account
     and t2.user_account = t3.user_account 
     and t1.user_account = t3.user_account
	and t1.user_account=$V_USER_ACCOUNT;
END