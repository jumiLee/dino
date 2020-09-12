CREATE PROCEDURE `abn_getUserInfo`($V_USER_ACCOUNT	INT /*���� ����*/)
BEGIN
	
/* ��������*/ 
	DECLARE $V_RESULT INT ;
	DECLARE $V_BOSS_EXIST_FLAG INT;
	DECLARE $V_BOSS_CREATE_TIME BIGINT;
	DECLARE $V_BOSS_REMAIN_TIME BIGINT;
	DECLARE $V_CURRENT_TIME BIGINT;
	DECLARE $V_ATTEND_SHOW_FLAG INT;
	DECLARE $V_TODAY_ATTEND_FLAG INT;
	DECLARE $V_RWD_RCV_FLAG INT;
	DECLARE $V_WBOSS_EXIST_FLAG INT;		/* ���庸�� �������� */
	DECLARE $V_WBOSS_CREATE_TIME BIGINT;	/* ���庸�� �����ð� */
	DECLARE $V_WBOSS_REMAIN_TIME BIGINT;	/* ���庸�� ���ӽð� */
	DECLARE $V_MSG_NEW INT; 
	DECLARE $V_FRD_NEW INT; 
	DECLARE $V_ACHV_NEW INT;
	DECLARE $V_BOOK_NEW INT;
	DECLARE $V_MON_NEW INT;
	DECLARE $V_FRD_NEW_REG INT;
	DECLARE $V_DEF_NEW INT;
	DECLARE $V_BOSS_NEW INT;
	DECLARE $V_TRE_NEW INT;
	DECLARE $V_INFI_NEW INT;
	DECLARE $V_ITEM_NEW INT;
    DECLARE $V_SKILL_NEW INT;
	DECLARE $V_FRD_BOSS_NEW INT;
    DECLARE $V_EVT_PAY_REMAIN_DAY INT;
 
	/* new flag ��ȸ	*/
		select	IFNULL(SUM(msg_new),2) , 
				IFNULL(SUM(frd_new),2) ,
				IFNULL(SUM(achv_new),2),
				IFNULL(SUM(book_new),2),
				IFNULL(SUM(mon_new),2) ,
				IFNULL(SUM(tre_new),2) ,
				IFNULL(SUM(item_new),2)
		  into  $V_MSG_NEW, $V_FRD_NEW, $V_ACHV_NEW, $V_BOOK_NEW, $V_MON_NEW, $V_TRE_NEW, $V_ITEM_NEW
		  from (
				select 	case t1.new_type when 1 then check_flag end as msg_new,
						case t1.new_type when 2 then check_flag end as frd_new,
						case t1.new_type when 3 then check_flag end as achv_new,
						case t1.new_type when 4 then check_flag end as book_new,
						case t1.new_type when 5 then check_flag end as mon_new,
						case t1.new_type when 6 then check_flag end as tre_new,
						case t1.new_type when 7 then check_flag end as item_new                        
				 from (  
						select new_type , check_flag
						  from USER_NEW_NOTICE 
						 where user_account= $V_USER_ACCOUNT) t1 ) t2;
		
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
    
    -- �̺�Ʈ���� �ܿ��ϼ� ��ȸ
    /*
    SET $V_EVT_PAY_REMAIN_DAY = (select ifnull((select (max_day_no - (datediff(now(),make_dt))-1) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = 1), 0));
    IF ($V_EVT_PAY_REMAIN_DAY < 0) then 
		SET $V_EVT_PAY_REMAIN_DAY = 0;
    END IF;
	*/	
/* ����� �⺻ ���� ��ȸ   */

	select t1.user_email, t1.user_pwd, t1.user_nickname, t1.user_img, t1.reg_dt, t2.user_coin, t2.user_gold,  t2.user_level,  t2.user_exp,  t2.user_rank,  t2.win_cnt,  t2.lose_cnt,  t2.friend_cnt,  t2.user_point,  t2.user_ap,
				t1.user_account, f_getTargetExp(t2.user_level, 1) as target_exp, 
				2 as def_new, $V_FRD_BOSS_NEW  as boss_new, $V_TRE_NEW  as tre_new, 2  as infi_new, $V_ITEM_NEW  as item_new, $V_SKILL_NEW  as skill_new, 
				$V_ATTEND_SHOW_FLAG as attned_flag,
				$V_WBOSS_EXIST_FLAG as wb_exist, $V_WBOSS_CREATE_TIME as wb_create_time, $V_WBOSS_REMAIN_TIME as wb_remain_time 
                -- ,$V_EVT_PAY_REMAIN_DAY as evt_pay_remain_day
		from MST_USER t1, USER_DETAIL t2
	 where t1.user_account = t2.user_account 
		 and t1.user_account = $V_USER_ACCOUNT;
END