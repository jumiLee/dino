CREATE PROCEDURE `abn_getNoticeInfo`($V_USER_ACCOUNT	INT /*나의 계정*/)
BEGIN
		select	IFNULL(SUM(msg_new),2) as msg_new
				,IFNULL(SUM(shop_new),2) as shop_new
				,IFNULL(SUM(achv_new),2) as achv_new
				,IFNULL(SUM(draw_new),2) as draw_new		  
		  from (
				select 	case t1.new_type when 1 then 1 end as msg_new
						,case t1.new_type when 2 then 1 end as shop_new
						,case t1.new_type when 3 then 1 end as achv_new
                        ,case t1.new_type when 4 then 1 end as draw_new
						/*case t1.new_type when 4 then check_flag end as book_new,
						case t1.new_type when 5 then check_flag end as mon_new,
						case t1.new_type when 6 then check_flag end as tre_new,
						case t1.new_type when 7 then check_flag end as item_new  */                      
				 from (  
						select new_type , check_flag
						  from USER_NEW_NOTICE 
						 where user_account= $V_USER_ACCOUNT
                           and check_flag = 2) t1 ) t2;
END