CREATE PROCEDURE `abn_getAttendInfo`($V_USER_ACCOUNT	INT /*���� ����*/)
BEGIN
	DECLARE $V_TODAY_ATTEND_FLAG INT;
    DECLARE $V_RWD_RCV_FLAG  INT;
    DECLARE $V_ATTEND_SHOW_FLAG INT;
    
	IF (SELECT count(user_account) FROM MST_USER  where user_account = $V_USER_ACCOUNT) > 0 THEN
	/* �⼮üũ�߰� */
		/* �Ϸ���� üũ*/
		SET $V_TODAY_ATTEND_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 and DATE_FORMAT(attend_date,'%Y%m%d')=DATE_FORMAT(NOW(),'%Y%m%d') );	
		/* 1�д��� üũ (�׽�Ʈ��)*/
		/*SET $V_TODAY_ATTEND_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 
																 and CONVERT(VARCHAR(8),attend_date,112) + REPLACE(CONVERT(VARCHAR(5),attend_date,108),':','')=CONVERT(VARCHAR(8),getdate(),112) + REPLACE(CONVERT(VARCHAR(5),getdate(),108),':',''));	
		*/																 
		SET $V_RWD_RCV_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 and rwd_rcv_flag=2 );
	END IF;
				
	IF $V_TODAY_ATTEND_FLAG = 0 OR $V_RWD_RCV_FLAG > 0 THEN
		SET $V_ATTEND_SHOW_FLAG =0; /* �⼮üũ X */
	ELSE
		SET $V_ATTEND_SHOW_FLAG = 1; /* �⼮üũ O */
	END IF;
    
    select $V_ATTEND_SHOW_FLAG as attned_flag;
END