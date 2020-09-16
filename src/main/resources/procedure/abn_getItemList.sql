CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_getItemList`(
    $V_JOB_CODE	INT	-- 1:일반조회
    ,$V_ITEM_ID	INT	-- item_id
)
BEGIN	
	IF($V_JOB_CODE = 1) THEN
		IF ($V_ITEM_ID = 0 ) THEN 
			select 	 t1.item_id as item_id
					,t1.item_nm as item_nm
					,t1.item_category as item_category
					,t1.item_type as item_type
					,t1.item_price as item_price
					,t1.unit_cd as unit_cd
					,t1.item_desc as item_desc
					,t1.item_value as item_value
					,t1.item_cnt as item_cnt
					,t1.item_period_flag as item_period_flag
					,t1.item_period as item_period
					,t1.item_dup_flag as item_dup_flag
					,t1.item_new_flag as item_new_flag
					,t1.item_img_no as item_img_no
			  from 	mst_item t1
			 where	t1.use_flag = 1
			 order by t1.item_order;
		ELSE
			select 	 t1.item_id as item_id
					,t1.item_nm as item_nm
					,t1.item_category as item_category
					,t1.item_type as item_type
					,t1.item_price as item_price
					,t1.unit_cd as unit_cd
					,t1.item_desc as item_desc
					,t1.item_value as item_value
					,t1.item_cnt as item_cnt
					,t1.item_period_flag as item_period_flag
					,t1.item_period as item_period
					,t1.item_dup_flag as item_dup_flag
					,t1.item_new_flag as item_new_flag
					,t1.item_img_no as item_img_no
			  from 	mst_item t1
			 where	t1.item_id = $V_ITEM_ID	;
        END IF;
	END IF;    
END