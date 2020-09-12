CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_MgmtUserSafe`( 
	IN $V_JOB_TYPE		INT,	/* 작업코드 (1:deposit, 2:withdraw, 3:refresh, 4:free charge)*/
	IN $V_USER_ACCOUNT	INT,	/* 사용자 계정	*/
    IN $V_USER_GOLD		INT,	/* 입출금액 */
    OUT $V_RESULT		INT 	/* 결과값			*/
  )
BEGIN
	DECLARE $V_CUR_USER_GOLD INT;		-- 현재보유 user_gold
    DECLARE $V_CUR_USER_SAFE_GOLD INT;	-- 금고보유액
    DECLARE $V_SAFE_LIMIT INT;			-- 금고보유최대값
    DECLARE $V_SAFE_BALANCE INT;		-- safe balance
       
    SET $V_RESULT = 0;

	SELECT user_gold, safe_limit INTO $V_CUR_USER_SAFE_GOLD ,$V_SAFE_LIMIT
      FROM user_safe 
	 WHERE user_account = $V_USER_ACCOUNT;
    
/* deposit */
	IF $V_JOB_TYPE = 1 THEN		
	-- 보유 금액보다 많은 금액을 입금하려고 하는지 체크
		SET $V_CUR_USER_GOLD = (select user_gold from user_detail where user_account = $V_USER_ACCOUNT);        
		IF ($V_USER_GOLD > $V_CUR_USER_GOLD) THEN
			SET $V_RESULT = -11	;	-- 입금액 > 보유액            
        END iF;
                
	-- 입금가능 최대금액보다 많은 금액을 입금하려고 하는지 체크
		IF($V_RESULT = 0) THEN
			IF ( ($V_CUR_USER_SAFE_GOLD +$V_USER_GOLD)  > $V_SAFE_LIMIT) THEN
				SET $V_RESULT = -12	;	-- 입금최대치 초과
			END iF;
		END iF;
	-- 입금처리
		IF($V_RESULT = 0) THEN
			UPDATE user_detail
               SET user_gold = (user_gold - $V_USER_GOLD)
			 WHERE user_account = $V_USER_ACCOUNT;
			
             UPDATE user_safe
				SET user_gold = (user_gold + $V_USER_GOLD)
			  WHERE user_account = $V_USER_ACCOUNT;             
        END IF;        
	-- Balance 
		SET $V_SAFE_BALANCE = $V_CUR_USER_SAFE_GOLD + $V_USER_GOLD;        
	END IF;
    
/* withdraw */
	IF $V_JOB_TYPE = 2 THEN
	-- 보유 금액보다 많은 금액을 인출하려고 하는지 체크        
		IF ($V_USER_GOLD > $V_CUR_USER_SAFE_GOLD) THEN
			SET $V_RESULT = -13	;	-- 출금액 > 금고보유액
        END iF;
	-- 출금처리
		IF($V_RESULT = 0) THEN
			UPDATE user_detail
               SET user_gold = (user_gold + $V_USER_GOLD)
			 WHERE user_account = $V_USER_ACCOUNT;
			
             UPDATE user_safe
				SET user_gold = (user_gold - $V_USER_GOLD)
			  WHERE user_account = $V_USER_ACCOUNT;             
        END IF;      
	-- Balance 
		SET $V_SAFE_BALANCE = $V_CUR_USER_SAFE_GOLD - $V_USER_GOLD;    
	END IF;
 
 /* refresh */
	IF $V_JOB_TYPE = 3 THEN
		update user_safe 
		  set safe_limit= (select sum(t2.item_value)  
							 from user_item t1, mst_item t2 
							where t1.item_id = t2.item_id 
                              and t2.item_type=91 
                              and t1.item_usage = 1
                              and user_account =$V_USER_ACCOUNT)
		where user_account=$V_USER_ACCOUNT;
    END IF;
 
/* 금고 이력 저장 */
	IF($V_RESULT = 0 AND $V_JOB_TYPE <> 3) THEN 
		INSERT INTO user_safe_hist (user_account, safe_job_type, user_gold, balance, issue_dt) 
        VALUES ($V_USER_ACCOUNT, $V_JOB_TYPE, $V_USER_GOLD, $V_SAFE_BALANCE, now());
    END IF;
END