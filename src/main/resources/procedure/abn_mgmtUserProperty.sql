CREATE PROCEDURE `abn_mgmtUserProperty`(
	$V_JOB_CODE		INT,	-- 1: 사용, 2:획득
	$V_USER_ACCOUNT INT,	-- 나의계정
    $V_USE_TYPE 	INT, 
    $V_UNIT_CD 		INT, 	-- 비용타입
    $V_PRICE		INT,	-- 금액
    OUT $V_RESULT	INT		-- 결과값
)
BEGIN
	DECLARE $V_MY_PRICE  INT;
	
    SET $V_RESULT = 0;
    
	IF($V_JOB_CODE =1 ) then
	-- 비용있는지 체크 
		SET $V_MY_PRICE = (SELECT case 
									when $V_UNIT_CD = 1 then user_gold  
									when $V_UNIT_CD = 2 then user_coin
									when $V_UNIT_CD = 3 then user_point
									else user_gold
								   end 	
	                     FROM user_detail 
	                    WHERE user_account = $V_USER_ACCOUNT);
		
		IF($V_PRICE > $V_MY_PRICE) then
			SET $V_RESULT = -11;  /* 금액부족 */
		END IF;
        
	-- 비용처리
        IF($V_RESULT =0) then
			IF ($V_PRICE <> 0 ) then /*  결제금액이 0이 아닌경우만 사용자 골드/코인/포인트 업데이트 */
				IF($V_UNIT_CD = 1) then   /* 골드 사용 */
					UPDATE user_detail SET user_gold = (user_gold - $V_PRICE ) WHERE user_account = $V_USER_ACCOUNT ; 
                 --   Call Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT, 1,4,2,$V_PRICE, $V_USE_TYPE, null, null, null);
                    
				ELSEIF ($V_UNIT_CD = 2) then   /* 코인 사용 */
					UPDATE user_detail SET user_coin = (user_coin - $V_PRICE )   WHERE user_account = $V_USER_ACCOUNT ;
                  --  Call Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT, 1,4,1,$V_PRICE, $V_USE_TYPE, null, null, null);
                    
				ELSEIF ($V_UNIT_CD = 3) then   /* 포인트 사용 */
					UPDATE user_detail SET user_point = (user_point - $V_PRICE ) WHERE user_account = $V_USER_ACCOUNT ;                      
				END IF;
                -- Log
                Call Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT, 2, 2, $V_UNIT_CD, $V_USE_TYPE, $V_PRICE, null, null, null); 
            END IF;
        END IF;
    END IF;
    
-- 회득
    IF($V_JOB_CODE =2) then
	-- 획득 처리
        IF($V_RESULT =0) then
			IF ($V_PRICE <> 0 ) then /*획득금액 0이 아닌경우만 사용자 골드/코인/포인트 업데이트 */
				IF($V_UNIT_CD = 1) then   /* 골드 획득 */
					UPDATE user_detail SET user_gold = (user_gold + $V_PRICE ) WHERE user_account = $V_USER_ACCOUNT ; 
				ELSEIF ($V_UNIT_CD = 2) then   /* 코인 획득 */
					UPDATE user_detail SET user_coin = (user_coin + $V_PRICE )   WHERE user_account = $V_USER_ACCOUNT ;                    
				ELSEIF ($V_UNIT_CD = 3) then   /* 포인트 획득 */
					UPDATE user_detail SET user_point = (user_point + $V_PRICE ) WHERE user_account = $V_USER_ACCOUNT ;                      
				END IF;
                -- Log                
				Call Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT, 2, 1, $V_UNIT_CD, $V_USE_TYPE, $V_PRICE, null, null, null);                
            END IF;
        END IF;
    END IF;
END