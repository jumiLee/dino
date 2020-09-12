CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_chargeFreeGold`(
	$V_USER_ACCOUNT 	INT	-- 나의계정
)
BEGIN
	DECLARE $V_CUR_AP INT;			-- 무료충전 가능 회수 
    DECLARE $V_CHAGE_AMT INT;		-- 무료충전 금액
    DECLARE $V_CUR_USER_GOLD INT;	-- 현재보유골드
	DECLARE $V_USE_TYPE	INT;			
    DECLARE $V_RESULT INT;
	SET $V_RESULT  = 0;
    SET $V_CHAGE_AMT = 0;
    
    -- 현재 골드가 있는지 체크
		SET $V_CUR_USER_GOLD = (select user_gold from user_safe where user_account = $V_USER_ACCOUNT);        
		IF ($V_CUR_USER_GOLD > 0) THEN
			SET $V_RESULT = -11	;	-- 보유 골드 있음
        END iF;
	
    -- 충전가능 회수 남아있는지 체크
		IF ($V_RESULT = 0) THEN
			SET $V_CUR_AP = (select cur_ap from user_ap where user_account = $V_USER_ACCOUNT and ap_type=1);    
			IF ($V_CUR_AP = 0) THEN
				SET $V_RESULT = -12	;	-- 충전가능회수 없음
			END IF;
		END IF;
    
	IF ($V_RESULT = 0) THEN
		SET $V_USE_TYPE	= 4; -- 무료골드충전 (재정의될 수 있음)
        SET $V_CHAGE_AMT = (select var_value from mgr_variable where var_category = 2 and var_id='AP_RECOVER_GOLD');
		Call abn_mgmtUserProperty (2, $V_USER_ACCOUNT, $V_USE_TYPE, 1 , $V_CHAGE_AMT, $V_RESULT);
        
        IF($V_RESULT = 0) THEN
			update user_ap
               set cur_ap = (cur_ap -1) 
			 where user_account = $V_USER_ACCOUNT and ap_type=1;
        END IF;        
    END IF;    
    
    select $V_RESULT as resultCd, $V_CHAGE_AMT as amt, cur_ap, max_ap, $V_CUR_USER_GOLD as safe_money
      from user_ap
	 where ap_type=1
       and user_account=$V_USER_ACCOUNT;
END