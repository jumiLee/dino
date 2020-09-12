CREATE DEFINER=`edenweb`@`localhost` PROCEDURE `abn_getItemListByShopCategory`(
    $V_SHOP_CATEGORY	INT
)
BEGIN	
		SELECT 	t2.item_id, t2.item_nm, t2.item_category, t2.item_type, t2.item_price, t2.unit_cd, t2.item_desc, t2.item_value, t2.item_cnt, 
				t2.item_period_flag, t2.item_period, t2.item_dup_flag, t2.item_new_flag, t2.item_img_no
		  FROM 	MST_ITEM_SHOP t1, MST_ITEM t2
		 WHERE 	t1.item_id = t2.item_id
           AND 	t1.shop_category = $V_SHOP_CATEGORY
		   AND 	t1.use_flag = 1
		ORDER BY t2.item_order;
END