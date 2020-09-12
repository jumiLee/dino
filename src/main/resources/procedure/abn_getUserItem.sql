CREATE PROCEDURE `abn_getUserItem`(
	$V_JOB_TYPE			INT	-- 1:�Ⱓ��������	
	,$V_USER_ACCOUNT	INT -- ����� ����
)
BEGIN	
    -- ����ڰ� ������ �Ⱓ�� ������ 
	IF ($V_JOB_TYPE = 1) then
		SELECT 	t1.item_uniqueID, t1.item_id, t1.remain_time, t1.make_dt, t1.end_dt, t1.last_mod_dt, t1.item_usage
				,t2.item_nm, t2.item_category, t2.item_type, t2.item_price, t2.unit_cd, t2.item_desc, t2.item_value, t2.item_period_flag, t2.item_period, t2.item_dup_flag, t2.item_new_flag, t2.item_img_no
		  FROM 	user_item t1, mst_item t2  
		 WHERE 	t1.item_id = t2.item_id
	   	   and  t1.user_account= $V_USER_ACCOUNT
	   	   and	t2.item_period_flag = 1
           and 	(case 
				when t2.item_period_flag=1 and t1.end_dt >= now() then 1 
                when t2.item_period_flag=2 then 1
                end ) = 1 ;
	END IF;
    
    -- ����ڰ� ������ ĳ���� ������ 
	IF ($V_JOB_TYPE = 2) then
		SELECT 	t1.item_uniqueID, t1.item_id, t1.remain_time, t1.make_dt, t1.end_dt, t1.last_mod_dt, t1.item_usage
				,t2.item_nm, t2.item_category, t2.item_type, t2.item_price, t2.unit_cd, t2.item_desc, t2.item_value, t2.item_period_flag, t2.item_period, t2.item_dup_flag, t2.item_new_flag, t2.item_img_no
		  FROM 	user_item t1, mst_item t2  
		 WHERE 	t1.item_id = t2.item_id
	   	   and  t1.user_account= $V_USER_ACCOUNT
           and 	t2.item_type = 61
           and (case 
				when t2.item_period_flag=1 and t1.end_dt >= now() then 1 
                when t2.item_period_flag=2 then 1
                end ) = 1 ;
	END IF;
    
    -- ����ڰ� ������ ������ 
	IF ($V_JOB_TYPE = 3) then
		SELECT 	t1.item_uniqueID, t1.item_id, t1.remain_time, t1.make_dt, t1.end_dt, t1.last_mod_dt, t1.item_usage 
				,t2.item_nm, t2.item_category, t2.item_type, t2.item_price, t2.unit_cd, t2.item_desc, t2.item_value, t2.item_period_flag, t2.item_period, t2.item_dup_flag, t2.item_new_flag, t2.item_img_no
		  FROM 	user_item t1, mst_item t2  
		 WHERE 	t1.item_id = t2.item_id
	   	   and  t1.user_account= $V_USER_ACCOUNT
           and 	t2.item_type in (61,91)
           and 	(case 
				when t2.item_period_flag=1 and t1.end_dt >= now() then 1 
                when t2.item_period_flag=2 then 1
                end ) = 1 ;
	END IF;
END