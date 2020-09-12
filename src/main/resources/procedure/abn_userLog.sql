CREATE PROCEDURE `abn_JoinUser`(
	$V_USER_LEVEL		INT,			/* 	사용자 레벨 (0:GM, 1:일반, 2:게스트, 3:테스트)	*/
	$V_USER_EMAIL		NVARCHAR(50), 	/*  사용자 이메일		*/
    $V_USER_PWD       	NVARCHAR(10), 	/*  사용자 비밀번호 	*/
	$V_USER_NICKNAME  	NVARCHAR(100), 	/*  사용자 닉네임		*/
	OUT $V_USER_ACCOUNT	INT	,			/*  생성된 사용자 계정	*/
    OUT $V_RESULT		INT				/*  결과값 (0: 성공, -11:사용중인 이메일, -12:사용중인 닉네임) */
)
BEGIN
	 
	DECLARE $V_EXIST_CH_USER INT; -- 기존 채널 사용자 체크
	DECLARE $V_USER_COIN  INT;
    DECLARE $V_USER_GOLD  INT;
    DECLARE $V_USER_POINT  INT;
    DECLARE $V_USER_SAFE_LIMIT  INT;	-- 금고보유최대액 
    DECLARE $V_RESULT_ITEM INT;
	DECLARE $V_RESULT_ITEM_MSG VARCHAR(100);
    DECLARE $V_ITEM_UNIQUEID BIGINT;	-- 생성된 아이템 고유번호 
    DECLARE $V_AP_RECOVER_CNT INT;

    SET $V_RESULT = 0;
	SET $V_USER_ACCOUNT =0;
	SET $V_EXIST_CH_USER = 0;   

--  default value setting 
	select sum(ap_recover_cnt), sum(default_gold), sum(default_point), sum(default_coin),sum(default_safe_limit) 
      into	$V_AP_RECOVER_CNT, $V_USER_GOLD, $V_USER_POINT, $V_USER_COIN, $V_USER_SAFE_LIMIT
	  from (    
			select 	case when var_id='AP_RECOVER_CNT' then var_value end ap_recover_cnt,
					case when var_id='DEFAULT_GOLD' then var_value end default_gold,
					case when var_id='DEFAULT_POINT' then var_value end default_point,
                    case when var_id='DEFAULT_COIN' then var_value end default_coin,
					case when var_id='DEFAULT_SAFE_LIMIT' then var_value end default_safe_limit 
			 from 	mgr_variable
			where 	var_category =1
            ) t1;
    
	/*  email check  */
	IF (select count(user_email) from mst_user where BINARY user_email = $V_USER_EMAIL) > 0 Then
		SET $V_RESULT = -11;	 /* 사용중인 이메일 */
	END IF;
		
    /*  nickname check  */
    IF($V_RESULT =0) THEN
		IF (select count(user_nickname) from mst_user where BINARY user_nickname = $V_USER_NICKNAME) > 0 Then
			SET $V_RESULT = -12;	 /* 사용중인 닉네임 */
		END IF;
    END IF;
    
	/* 사용자 등록 프로세스 */
	IF ($V_RESULT = 0 ) Then
		-- 2-1) 사용자 마스터 정보 생성 (mst_user) 
		INSERT INTO mst_user (user_nickname, user_email, user_pwd, tut_flag, tut_step, reg_dt, user_level, ch_type, ch_id, user_img)  /* 튜토리얼 기본 완료로 수정 (Sales version) -> 원복시킴*/
		VALUES($V_USER_NICKNAME, $V_USER_EMAIL,$V_USER_PWD, 2, 1, NOW(),$V_USER_LEVEL, 0,0,0);
				
		-- 2-2) 생성된 USER_ACCOUNT 값 세팅
		SET $V_USER_ACCOUNT = (select user_account from mst_user  where user_email = $V_USER_EMAIL);
        
        -- 2-3) 사용자 상세정보 생성 (USER_DEDTAIL)
        INSERT INTO user_detail (user_account, user_coin, user_gold, user_point, user_level, user_rank, win_cnt, lose_cnt, friend_cnt, user_score,user_exp)
		VALUES ($V_USER_ACCOUNT, $V_USER_COIN, $V_USER_GOLD, $V_USER_POINT, $V_USER_LEVEL, 0, 0, 0, 0, 0,0);
        
        -- 2-4) 사용자 금고정보 생성 (USER_SAFE)
        INSERT INTO user_safe (user_account, user_gold, safe_limit) 
        VALUES ($V_USER_ACCOUNT, 0, $V_USER_SAFE_LIMIT);
        
        -- 2-5) 사용자 금고이력정보 생성 (USER_SAFE_HIST)
        INSERT INTO user_safe_hist (user_account, safe_job_type, user_gold, balance, issue_dt) 
        VALUES ($V_USER_ACCOUNT, 3, 0, 0, now());
        
        -- 2-6) 기본충전 정보 생성 (USER_AP)
        INSERT INTO user_ap (user_account,ap_type,max_AP,cur_AP,last_dt)
		VALUES ($V_USER_ACCOUNT,1,$V_AP_RECOVER_CNT,$V_AP_RECOVER_CNT,now());

        -- 2-7) 기본 캐릭터 아이템 지급
        Call abn_MgmtItem_out (5, $V_USER_ACCOUNT, 6110001, 1 , 0, $V_RESULT_ITEM , $V_RESULT_ITEM_MSG);
        Call abn_MgmtItem_out (5, $V_USER_ACCOUNT, 6110002, 1 , 0, $V_RESULT_ITEM , $V_RESULT_ITEM_MSG);
        Call abn_MgmtItem_out (5, $V_USER_ACCOUNT, 6110003, 1 , 0, $V_RESULT_ITEM , $V_RESULT_ITEM_MSG);
        Call abn_MgmtItem_out (5, $V_USER_ACCOUNT, 6110004, 1 , 0, $V_RESULT_ITEM , $V_RESULT_ITEM_MSG);
        Call abn_MgmtItem_out (5, $V_USER_ACCOUNT, 6110005, 1 , 0, $V_RESULT_ITEM , $V_RESULT_ITEM_MSG);
        
        -- 2-8) 기본캐릭터 장착처리
        SET $V_ITEM_UNIQUEID = (SELECT item_uniqueId FROM user_item where user_account=$V_USER_ACCOUNT and item_id=6110001);
        call abn_MgmtItem_use ($V_USER_ACCOUNT, $V_ITEM_UNIQUEID, 1, $V_RESULT_ITEM); 
	END IF;

	/* 이력추가  */
	IF ($V_RESULT = 0 ) Then
		Call Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT, 1,1,0,null, null, null, null, null);	-- 계정생성
        Call Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT, 2,1,1,$V_USER_GOLD, null, null, null, null);	-- Gold 기본지급
	END IF;
	
	/* 결과값 테스트
	select $V_RESULT result, $V_USER_ACCOUNT user_account,$V_EXIST_CH_USER exist_user, $V_RET_MOBILE user_mobile ; */
END