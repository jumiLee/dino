CREATE PROCEDURE `abn_getCashList`(
	$V_JOB_CODE		INT,	/* 1: Á¶È¸		*/
	$V_DEVICE_TYPE	INT,	/* Device type (1:AOS. 2:IOS) */
    $V_PAYMENT_TYPE	INT
)
BEGIN
	IF($V_JOB_CODE = 1) then
		
		  SELECT cash_id, cash_type_cd, cash_amt, cash_dis_amt, coin_amt, coin_nm, coin_desc, prod_id,device_type, ifnull(prod_img,0) as prod_img
		    FROM MST_CASH
		   WHERE del_flag= 2 and display_flag=1
             AND device_type=$V_DEVICE_TYPE
             AND payment_type = $V_PAYMENT_TYPE;
	END IF;
	
END