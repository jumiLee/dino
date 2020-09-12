CREATE PROCEDURE `abn_getUserInfo`($V_USER_ACCOUNT	INT /*나의 계정*/)
BEGIN
	
/* 변수정의*/ 
	DECLARE $V_RESULT INT ;
	DECLARE $V_BOSS_EXIST_FLAG INT;
	DECLARE $V_BOSS_CREATE_TIME BIGINT;
	DECLARE $V_BOSS_REMAIN_TIME BIGINT;
	DECLARE $V_CURRENT_TIME BIGINT;
	DECLARE $V_ATTEND_SHOW_FLAG INT;
	DECLARE $V_TODAY_ATTEND_FLAG INT;
	DECLARE $V_RWD_RCV_FLAG INT;
	DECLARE $V_WBOSS_EXIST_FLAG INT;		/* 월드보스 존재유무 */
	DECLARE $V_WBOSS_CREATE_TIME BIGINT;	/* 월드보스 생성시간 */
	DECLARE $V_WBOSS_REMAIN_TIME BIGINT;	/* 월드보스 존속시간 */
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
 
	/* new flag 조회	*/
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
	/* 출석체크추가 */
		/* 하루단위 체크*/
		SET $V_TODAY_ATTEND_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 and DATE_FORMAT(attend_date,'%Y%m%d')=DATE_FORMAT(NOW(),'%Y%m%d') );	
		/* 1분단위 체크 (테스트용)*/
		/*SET $V_TODAY_ATTEND_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 
																 and CONVERT(VARCHAR(8),attend_date,112) + REPLACE(CONVERT(VARCHAR(5),attend_date,108),':','')=CONVERT(VARCHAR(8),getdate(),112) + REPLACE(CONVERT(VARCHAR(5),getdate(),108),':',''));	
		*/																 
		SET $V_RWD_RCV_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 and rwd_rcv_flag=2 );
	END IF;
				
	IF $V_TODAY_ATTEND_FLAG = 0 OR $V_RWD_RCV_FLAG > 0 THEN
		SET $V_ATTEND_SHOW_FLAG =0; /* 출석체크 X */
	ELSE
		SET $V_ATTEND_SHOW_FLAG = 1; /* 출석체크 O */
	END IF;
    
    -- 이벤트결제 잔여일수 조회
    /*
    SET $V_EVT_PAY_REMAIN_DAY = (select ifnull((select (max_day_no - (datediff(now(),make_dt))-1) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = 1), 0));
    IF ($V_EVT_PAY_REMAIN_DAY < 0) then 
		SET $V_EVT_PAY_REMAIN_DAY = 0;
    END IF;
	*/	
/* 사용자 기본 정보 조회   */

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