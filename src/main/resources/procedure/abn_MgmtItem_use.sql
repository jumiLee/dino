CREATE PROCEDURE `abn_MgmtItem_use`(
	 $V_ACCOUNT        	INT		-- 사용자 계정
    ,$V_ITEM_UNIQUE_ID 	BIGINT 	-- 아이템 고유번호
    ,$V_ITEM_CNT       	INT		-- 아이템 개수 (거래코드가 사용인 경우엔 (-) 값을 등록)      
    ,OUT $V_RESULT		INT
)
BEGIN
	DECLARE $V_ITEM_ID		 INT;	
	DECLARE $V_ITEM_TYPE	 INT;			
    DECLARE $V_ITEM_VALUE	 INT;			
	DECLARE $V_MY_ITEM_CNT	 INT;
    DECLARE $V_ITEM_PERIOD_FLAG INT;
	
    SET $V_RESULT =0;
	
-- 사용가능한 아이템인지 체크
	SET $V_ITEM_ID = (select item_id from USER_ITEM where item_uniqueID=$V_ITEM_UNIQUE_ID);	
	SELECT item_type, item_value, item_period_flag INTO $V_ITEM_TYPE, $V_ITEM_VALUE , $V_ITEM_PERIOD_FLAG
	  FROM MST_ITEM 
	 WHERE item_id = $V_ITEM_ID;
        
    -- 사용하려는 아이템 개수가 보유한 개수보다 많으면 
	IF (select count(item_cnt) from USER_ITEM where user_account =$V_ACCOUNT and item_uniqueID=$V_ITEM_UNIQUE_ID) > 0 then
		SET $V_MY_ITEM_CNT = (select item_cnt from USER_ITEM where user_account =$V_ACCOUNT and item_uniqueID=$V_ITEM_UNIQUE_ID);
		IF($V_MY_ITEM_CNT < $V_ITEM_CNT ) then  
			SET $V_RESULT = -21;	
		END if;
	ELSE 
		SET $V_RESULT = -22; -- 존재하지 않는 아이템
	END if;
		
	-- 기간제 아이템이면, 기간만료 체크 
    IF($V_ITEM_PERIOD_FLAG = 1) THEN 
		if (select count(item_uniqueId) from user_item where user_account=$V_ACCOUNT and item_uniqueID=$V_ITEM_UNIQUE_ID and end_dt >= now() ) <= 0 then
			SET $V_RESULT = -23; -- 기간만료아이템
        end if;
    END IF;
    
	IF($V_RESULT = 0) THEN
    -- 사용자 아이템 정보 업데이트
		IF($V_ITEM_PERIOD_FLAG = 1) THEN 
			-- 기존 아이템 사용중 해제
             update user_item t1, mst_item t2
              set t1.item_usage=2 
				  ,last_mod_dt = now()
			where t1.item_id = t2.item_id
              and t1.user_account = $V_ACCOUNT
              and t2.item_type=$V_ITEM_TYPE;            
            -- 신규 아이템 사용중 처리
			UPDATE USER_ITEM 
			   SET item_usage = 1
				  ,last_mod_dt = now()
			 WHERE user_account = $V_ACCOUNT and item_uniqueID=$V_ITEM_UNIQUE_ID;
		ELSE
			UPDATE USER_ITEM 
			   SET item_cnt = (item_cnt-$V_ITEM_CNT)
				  ,last_mod_dt = now()
			 WHERE user_account = $V_ACCOUNT and item_uniqueID=$V_ITEM_UNIQUE_ID;
        END IF;
        
    -- item type에 대한 처리
    	IF($V_ITEM_TYPE = 91) then -- 금고제한
			update user_safe 
			   set safe_limit= $V_ITEM_VALUE
			 where user_account=$V_ACCOUNT;
		END IF;
        
        IF($V_ITEM_TYPE=61) then -- 캐릭터 설정
			update mst_user 
               set user_img = $V_ITEM_ID
			where user_account=$V_ACCOUNT;
        END IF;
	END IF;
	
	/* 아이템 사용 로그 */
    /*
	IF($V_RESULT = 0) then
		Call Log_BaseLog ($V_ACCOUNT,$V_ACCOUNT,3,3,0,$V_ITEM_ID,$V_ITEM_UNIQUE_ID,null,null,null);
	END IF;
	*/
END