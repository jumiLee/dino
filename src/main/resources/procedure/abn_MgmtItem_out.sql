CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_MgmtItem_out`(
	$V_TRADE_CD       	INT		-- 거래코드 (mst_code.trade_cd 참고)  1:구매, 5:보상 및 무료지급  8:아이템 체크상테 업데이트
    ,$V_ACCOUNT        	INT		-- 사용자 계정
    ,$V_ITEM_ID        	BIGINT 	-- 아이템 아이디 / 아이템 고유번호
    ,$V_ITEM_CNT       	INT		-- 아이템 개수 (거래코드가 사용인 경우엔 (-) 값을 등록)      
    ,$V_PAYMENT_AMT    	INT		-- 결제금액  (결제금액을 null로 넘기면 MST_ITEM의 등록된 값을 적용)     
    ,OUT $V_RESULT		INT
    ,OUT $V_RESULT_MSG	NVARCHAR(100) 
    ,OUT $V_ITEM_UNIQUEID BIGINT
)
BEGIN

	DECLARE $V_UNIT_CD       INT;			-- 결제단위	
	DECLARE $V_TRADE_AMT     NUMERIC(10,2); -- 결제금액	
	DECLARE $V_ADD_ITEM_CNT  INT;			-- 실제 추가될 아이템 개수  
	DECLARE $V_ITEM_DUP_FLAG INT;			-- 아이템 중첩가능 ( 1: 가능, 2:불가능) 
	DECLARE $V_MY_MONEY		 INT;			-- 나의 현재 보유결제 가능액 
	DECLARE $V_ITEM_TYPE	 INT;			-- 아이템 타입 
	DECLARE $V_EXIST_ITEM_CNT INT;
	DECLARE $V_RESULT_NOTICE INT;
	DECLARE $V_ITEM_PERIOD_FLAG INT;
    DECLARE $V_ITEM_PERIOD INT;

	SET $V_RESULT =0;
	SET $V_RESULT_NOTICE =0;
	SET $V_RESULT_MSG = 'abn_MgmtItem_sucess';
    SET $V_ITEM_UNIQUEID = 0;
	SET $V_ITEM_DUP_FLAG = (select item_dup_flag from mst_item where item_id=$V_ITEM_ID);
   
	SET max_sp_recursion_depth = 10 ;
   -- 1-1) 아이템에 대한 결제단위 및 결제금액 정보 조회
	IF($V_PAYMENT_AMT is null) then
		SELECT unit_cd, (item_price * $V_ITEM_CNT), (item_cnt * $V_ITEM_CNT), item_period_flag, item_period
		  INTO $V_UNIT_CD, $V_TRADE_AMT, $V_ADD_ITEM_CNT, $V_ITEM_PERIOD_FLAG, $V_ITEM_PERIOD  
		  FROM mst_item
            WHERE ITEM_ID = $V_ITEM_ID;      
	ELSE
		SELECT unit_cd, $V_PAYMENT_AMT, (item_cnt * $V_ITEM_CNT), item_period_flag, item_period
		  INTO $V_UNIT_CD, $V_TRADE_AMT, $V_ADD_ITEM_CNT, $V_ITEM_PERIOD_FLAG, $V_ITEM_PERIOD  
             FROM mst_item
            WHERE ITEM_ID = $V_ITEM_ID;   
	END IF;
  
  -- 1. 아이템 구매 조건 체크 (구매인 경우만) 
	IF($V_TRADE_CD = 1) THEN
		-- 1-2) 구매할 코인 및 골드가 있는지 체크
		SET $V_MY_MONEY= (select  CASE 
									WHEN $V_UNIT_CD = 1 THEN user_gold 
									WHEN $V_UNIT_CD = 2 THEN user_coin
									WHEN $V_UNIT_CD = 3 THEN user_point
									ELSE 0
								  End  
						    from user_detail
						   where user_account=$V_ACCOUNT);
		
        IF($V_MY_MONEY < $V_TRADE_AMT ) then
			SET $V_RESULT = -11;
			SET $V_RESULT_MSG = 'Lack of Money';
		END IF;
	END IF;
    
    -- 2. 사용자 아이템 정보 업데이트 (USER_ITEM)	
	IF ($V_RESULT = 0) THEN
		-- 중첩불가 아이템이면, 새로입력 
		IF ($V_ITEM_DUP_FLAG = 2) then 
			INSERT INTO user_item (user_account, item_id, item_cnt, item_usage, remain_time, check_flag ) 
			select 	$V_ACCOUNT 		as user_account
					,$V_ITEM_ID 	as item_id
					,$V_ITEM_CNT 	as item_cnt
					,2 				as item_usage
					,item_period 	as remain_time
					,2 				as check_flag
			  from mst_item
		     where item_id = $V_ITEM_ID;

			SET $V_ITEM_UNIQUEID = (SELECT LAST_INSERT_ID()) ;
		-- 중첩가능 
		ELSE
			-- 기간제 아이템 
			IF ($V_ITEM_PERIOD_FLAG = 1) THEN
				IF (SELECT COUNT(item_id) FROM user_item WHERE user_account = $V_ACCOUNT  AND item_id = $V_ITEM_ID) > 0 then -- 기존에 등록된 아이템이 있으면
					SET $V_EXIST_ITEM_CNT = (select IFNULL(item_cnt,0) from user_item where item_id=$V_ITEM_ID and user_account=$V_ACCOUNT);
						UPDATE 	user_item 
						   SET 	item_cnt = $V_EXIST_ITEM_CNT + $V_ADD_ITEM_CNT
								,check_flag= 2
								,remain_time = (remain_time + $V_ITEM_PERIOD)                             
								,end_dt = DATE_ADD(end_dt, INTERVAL $V_ITEM_PERIOD DAY)
								,last_mod_dt = now()
						 WHERE 	user_account = $V_ACCOUNT and item_id=$V_ITEM_ID;																	
						SET $V_ITEM_UNIQUEID = (SELECT item_uniqueID from user_item where user_account=$V_ACCOUNT and item_id = $V_ITEM_ID) ;
				ELSE 
					INSERT INTO user_item (user_account, item_id, item_cnt, item_usage, remain_time, check_flag, end_dt, make_dt, last_mod_dt ) 
					select 	$V_ACCOUNT 		as user_account
							,$V_ITEM_ID 	as item_id
							,$V_ITEM_CNT 	as item_cnt
							,2 				as item_usage
							,item_period 	as remain_time
							,2 				as check_flag
							,DATE_ADD(now(), INTERVAL item_period DAY) as end_dt
							,now()			as make_dt
							,now()			as last_mod_dt		
					  from 	mst_item
					 where 	item_id = $V_ITEM_ID;           
					SET $V_ITEM_UNIQUEID = (SELECT LAST_INSERT_ID()) ;
				END IF;
			-- 기간제 아이템 X
			ELSE
				IF (SELECT COUNT(item_id) FROM user_item WHERE user_account = $V_ACCOUNT  AND item_id = $V_ITEM_ID) > 0 then -- 기존에 등록된 아이템이 있으면
					SET $V_EXIST_ITEM_CNT = (select IFNULL(item_cnt,0) from user_item where item_id=$V_ITEM_ID and user_account=$V_ACCOUNT);
						UPDATE 	user_item 
						   SET 	item_cnt = $V_EXIST_ITEM_CNT + $V_ADD_ITEM_CNT
								,check_flag= 2
								,last_mod_dt = now()
						 WHERE 	user_account = $V_ACCOUNT and item_id=$V_ITEM_ID;																	
						SET $V_ITEM_UNIQUEID = (SELECT item_uniqueID from user_item where user_account=$V_ACCOUNT and item_id = $V_ITEM_ID) ;
				ELSE 
					INSERT INTO user_item (user_account, item_id, item_cnt, item_usage, remain_time, check_flag, end_dt, make_dt, last_mod_dt ) 
					select 	$V_ACCOUNT 		as user_account
							,$V_ITEM_ID 	as item_id
							,$V_ITEM_CNT 	as item_cnt
							,2 				as item_usage
                            ,item_period 	as remain_time
							,2 				as check_flag
                            ,DATE_ADD(now(), INTERVAL item_period DAY) as end_dt
							,now()			as make_dt
							,now()			as last_mod_dt		
					  from 	mst_item
					 where 	item_id = $V_ITEM_ID;           
					SET $V_ITEM_UNIQUEID = (SELECT LAST_INSERT_ID()) ;
				END IF;
            END IF;
		END IF;
	END IF;
       
	-- 3.사용자 상세정보 업데이트 (구매인 경우만) 
    IF($V_TRADE_CD = 1) THEN    
		IF ($V_RESULT = 0)  then
		-- 골드로 결제한 경우
			IF ($V_UNIT_CD = 1) then
				UPDATE user_detail SET user_gold = (user_gold - $V_TRADE_AMT ) WHERE user_account = $V_ACCOUNT ; 
			END IF;
		-- 캐쉬로 결제한 경우 
			IF ($V_UNIT_CD = 2) then
				UPDATE user_detail SET user_coin = (user_coin - $V_TRADE_AMT ) WHERE user_account = $V_ACCOUNT ;  
			END IF;
		-- 포인트로 결제한 경우
			IF ($V_UNIT_CD = 3) then
				UPDATE user_detail SET user_point = (user_point - $V_TRADE_AMT ) WHERE user_account = $V_ACCOUNT ;  
			END	IF;
		END IF;
	END IF;      

	-- 4.아이템 타입에 따른 처리 (골드인 경우 사용자 골드 충전)
	IF ($V_RESULT = 0) then
		SET $V_ITEM_TYPE = (select item_type FROM mst_item WHERE item_id = $V_ITEM_ID);
          
		IF($V_ITEM_TYPE = 12) then  -- 아이템타입이 골드면 
			UPDATE user_detail
               SET user_gold = user_gold +($V_ITEM_CNT * (select item_value from mst_item where item_id=$V_ITEM_ID) )
             WHERE user_account = $V_ACCOUNT ; 

			UPDATE user_item
			   SET item_usage =1, check_flag=1 	
			 WHERE item_uniqueID=$V_ITEM_UNIQUEID and user_account=$V_ACCOUNT and item_id=$V_ITEM_ID;
		END IF;
		
		IF($V_ITEM_TYPE = 91) then  -- 소모성아이템(금고제한)
			Call abn_MgmtItem_use ($V_ACCOUNT,$V_ITEM_UNIQUEID,$V_ITEM_CNT, $V_RESULT);
		END IF;
            
        IF($V_ITEM_TYPE = 121) then  -- 아이템타입이 세트아이템
			Call abn_mgmtSetItem (1,$V_ACCOUNT,$V_ITEM_ID,$V_ITEM_UNIQUEID,$V_RESULT);
		END IF;            
	END IF;

    -- 5.사용자 아이템 거래 및 결제 이력정보 업데이트
    /*
	IF ($V_RESULT = 0) then
		IF($V_TRADE_CD = 1) THEN 
			Call Log_BaseLog ($V_ACCOUNT,$V_ACCOUNT,3,1,1,$V_ITEM_ID,$V_ITEM_UNIQUEID,$V_UNIT_CD,$V_TRADE_AMT,$V_ITEM_CNT) ;
		END IF; 
		IF($V_TRADE_CD = 5 OR $V_TRADE_CD =  7) then
			Call Log_BaseLog ($V_ACCOUNT,$V_ACCOUNT,3,1,7,$V_ITEM_ID,$V_ITEM_UNIQUEID,null,null,null);
           END IF; 
	END IF; 
    */
    
	-- 6.사용자 공지 등록 (USER_NEW_NOTICE)		
    /*
	IF ($V_RESULT = 0) then
		IF (select count(item_id) from mst_item where item_id=$V_ITEM_ID and item_type not in (11,12,21,91,102)) > 0 then
			Call abn_MgmtUserNewNotice (1,$V_ACCOUNT, 7, 1, $V_RESULT_NOTICE);                
		END IF;
	END IF;
    */
	-- //////////// Update Item Check status ////////////
	IF($V_TRADE_CD = 8) THEN
		IF (select count(*) from user_item where user_account=$V_ACCOUNT and check_flag=2) > 0 then 
			UPDATE user_item
			   SET check_flag = 1
			 WHERE user_account = $V_ACCOUNT;
				 
			-- NEW Notice update
			CALL abn_MgmtUserNewNotice (1, $V_ACCOUNT, 7, 2, $V_RESULT);
		END IF;
	END IF;
END