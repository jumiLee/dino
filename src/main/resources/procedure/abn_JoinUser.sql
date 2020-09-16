CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_JoinUser`(
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
    DECLARE $V_RESULT_ITEM INT;
	DECLARE $V_RESULT_ITEM_MSG VARCHAR(100);
    DECLARE $V_ITEM_UNIQUEID BIGINT;	-- 생성된 아이템 고유번호 
    DECLARE $V_MON_ID INT;
	DECLARE $V_USER_MON_SN INT;
    DECLARE $V_RESULT_MON INT;
    
    SET $V_RESULT = 0;
	SET $V_USER_ACCOUNT =0;
	SET $V_EXIST_CH_USER = 0;   
    
--  default value setting 
	select 	sum(default_gold), sum(ifnull(default_point,default_point_AI)), sum(default_coin), sum(mon_id)
      into	$V_USER_GOLD, $V_USER_POINT, $V_USER_COIN, $V_MON_ID
	  from (    
			select 	case when var_id='DEFAULT_GOLD' then var_value end default_gold,
					case when var_id='DEFAULT_POINT' and $V_USER_LEVEL=1 then var_value end default_point,
                    case when var_id='DEFAULT_COIN' then var_value end default_coin,
                    case when var_id='DEFAULT_POINT_AI' and $V_USER_LEVEL=3 then var_value  end default_point_AI,
                    case when var_id='DEFAULT_MON_ID' then var_value end mon_id
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
        
        -- 2-4) 기본 몬스터 등록 
        call abn_AddUserMonster( $V_USER_ACCOUNT
								,$V_MON_ID
                                ,0			-- defau;t monster has no merchant ID
                                ,$V_RESULT_MON, $V_USER_MON_SN);
	END IF;
END