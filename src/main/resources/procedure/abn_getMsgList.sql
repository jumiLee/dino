CREATE PROCEDURE `abn_getMsgList`(
	$V_JOB_CODE		INT,	/*  1:나의 수신함 리스트, 2:나의 발신함 리스트*/
	$V_USER_ACCOUNT INT 	/*  나의계정 */
)
BEGIN
	
	IF($V_JOB_CODE = 1) then
		select 	receive_sn
				,sender_account
				,good_type, good_id, IFNULL(good_sub_id,0) as good_sub_id
				,IFNULL(f_getRwdName (good_type,good_id,good_sub_id),0) as good_nm
				,DATE_FORMAT(issue_dt,'%H:%i:%s') as receive_dt 
				,receive_msg 
                ,7-(DATEDIFF(now(),issue_dt)) as remain_day
		  from 	USER_RECEIVE_BOX t1
		 WHERE 	t1.user_account = $V_USER_ACCOUNT
		   and 	check_flag=2 ; /* unchecked message*/
		   
	END	IF;
END