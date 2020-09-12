CREATE PROCEDURE `abn_MgmtUserDraw`(
	$V_USER_ACCOUNT     INT,  /* 사용자 계정 */
	$V_DRAW_ID          INT,  /* 가차 아이디 */
	$V_DRAW_TYPE_CD     INT   /* 가차타입코드 */
)
BEGIN
	DECLARE $V_DRAW_RWD_TYPE INT; DECLARE $V_DRAW_RWD_ID INT; DECLARE $V_DRAW_RWD_ID_CNT INT; DECLARE $V_DRAW_RWD_NM VARCHAR(20);
	DECLARE $V_RESULT INT;
	DECLARE $V_TUT_FLAG INT;		/* 사용자 튜툐리얼 완료여부 */
	DECLARE $V_UNIT_CD INT; DECLARE $V_PRICE INT; DECLARE $V_MY_PRICE INT; DECLARE $V_DRAW_CNT INT;
	DECLARE $V_DRAW_RWD_TYPE_CNT  INT ; /* 가차아이디 및 타입에 따른 보상 타입 개수 */
	DECLARE $V_ITEM_RESULT INT; DECLARE $V_ITEM_RESULT_MSG VARCHAR(100);
	DECLARE $V_RWD_RESULT INT ;
	DECLARE $V_FREE_DRAW_FLAG boolean;
	DECLARE nCnt INT DEFAULT 0;
    DECLARE $V_DRAW_RESULT JSON;
	DECLARE $V_REMAIN_SECOND INT;
    
    SET $V_RESULT = 0;  
	
    /* 뽑기권인 경우, draw_type_cd정보가 없이 올 수 있음. */
    IF ($V_DRAW_TYPE_CD = 0) then
		SET $V_DRAW_TYPE_CD = (select draw_type_cd from MST_DRAW where draw_id=$V_DRAW_ID);
    END IF;
  
	/* 뽑기 관련 변수 조회 */
	SELECT unit_cd, dis_price, draw_cnt into $V_UNIT_CD, $V_PRICE, $V_DRAW_CNT from MST_DRAW where draw_id = $V_DRAW_ID and draw_type_cd = $V_DRAW_TYPE_CD;
	
    IF($V_PRICE =0) THEN
		SET $V_FREE_DRAW_FLAG = TRUE;
	ELSE
		SET $V_FREE_DRAW_FLAG = FALSE;
    END IF;

    -- 유료뽑기인 경우에만 보유 금액 체크
    IF($V_FREE_DRAW_FLAG IS FALSE) THEN 
		SET $V_MY_PRICE = (SELECT case 
									when $V_UNIT_CD = 1 then user_gold  
									when $V_UNIT_CD = 2 then user_coin
									when $V_UNIT_CD = 3 then user_point
									else user_gold
								  end 	
							 FROM USER_DETAIL 
							WHERE user_account = $V_USER_ACCOUNT);			
		/* 1. 뽑기 가능한지 체크 */
		IF($V_PRICE > $V_MY_PRICE) then
			SET $V_RESULT = -11;  /* 금액부족 */
		END IF;
    END IF;
          
	-- 무료뽑기인 경우, 남은 시간 체크
    IF($V_RESULT = 0) Then
		IF($V_DRAW_TYPE_CD=2 AND $V_DRAW_ID = 6) THEN 
			call abn_mgmtUserTimeEvent(3, $V_USER_ACCOUNT, 2, $V_REMAIN_SECOND);
            
            IF($V_REMAIN_SECOND > 0 ) THEN
				SET $V_RESULT = -21  ; -- 무료뽑기 가능시간 아님
            END IF;            
		END IF;
    END IF;
    
	/* 2. 보상타입 결정 (가차 보상 타입이 여러개일 경우 랜덤으로 가차 타입 선택) */
	IF($V_RESULT = 0) then
		SET $V_DRAW_RWD_TYPE_CNT = (select count(draw_rwd_type) FROM MST_DRAW_REWARD WHERE draw_id =$V_DRAW_ID );
		
		/* 1-1) 등록된 보상 아이템이 없으면, (에러 상황이므로 -1 값을 리턴)   */
		IF ($V_DRAW_RWD_TYPE_CNT = 0) then
			SET $V_DRAW_RWD_TYPE = -1;
			SET $V_DRAW_RWD_ID   = -1;
		
		/* 1-2) 랜덤으로 가차 타입 선택 */
		ELSE 
			SET $V_DRAW_RWD_TYPE = (select draw_rwd_type FROM MST_DRAW_REWARD WHERE draw_id = $V_DRAW_ID ORDER BY RAND() limit 1) ;
		END IF;
	END IF;
  
  /* 3. 보상 결정 및 등록 처리 */
	IF($V_RESULT = 0) THEN
   
	-- draw_cnt 만큼 보상 등록  
		WHILE (nCnt <  $V_DRAW_CNT) DO
		/* 3-1) 보상 랜덤 추출 */
		    SELECT	draw_rwd_id, draw_rwd_cnt INTO $V_DRAW_RWD_ID, $V_DRAW_RWD_ID_CNT
			  FROM 	MST_DRAW_REWARD 
			 WHERE 	draw_id =$V_DRAW_ID 
			   AND 	draw_rwd_type = $V_DRAW_RWD_TYPE
			ORDER BY RAND() limit 1;       
			/* 3-2) 보상등록 */
			CALL abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_DRAW_RWD_TYPE, $V_DRAW_RWD_ID, $V_DRAW_RWD_ID_CNT, $V_RWD_RESULT);		
			
			-- return result setting
			IF (nCnt = 0) THEN
				SET $V_DRAW_RESULT = json_object('rwdType',$V_DRAW_RWD_TYPE,'rwdId',$V_DRAW_RWD_ID,'rwdName',f_getRwdName($V_DRAW_RWD_TYPE,$V_DRAW_RWD_ID,0));
			ELSE
				SET $V_DRAW_RESULT = JSON_ARRAY_APPEND ($V_DRAW_RESULT, '$', json_object('rwdType',$V_DRAW_RWD_TYPE,'rwdId',$V_DRAW_RWD_ID,'rwdName',f_getRwdName($V_DRAW_RWD_TYPE,$V_DRAW_RWD_ID,0)));
			END IF;
        
			Set nCnt = nCnt + 1;
        END WHILE;
		IF ($V_RWD_RESULT <> 0 ) then 
			SET $V_RESULT = -12;
		END IF;        
    END IF;
  	
	/* 4. 사용자 정보 업데이트  */
	IF($V_RESULT = 0) Then
		IF($V_FREE_DRAW_FLAG IS FALSE) THEN /*  결제금액이 0이 아닌경우만 사용자 골드/코인/포인트 업데이트 */
			IF($V_UNIT_CD = 1) then   /* 골드 사용 */
				UPDATE USER_DETAIL SET user_gold = (user_gold - $V_PRICE ) WHERE user_account = $V_USER_ACCOUNT ; 

			ELSEIF ($V_UNIT_CD = 2) then   /* 코인 사용 */
				UPDATE USER_DETAIL SET user_coin = (user_coin - $V_PRICE )   WHERE user_account = $V_USER_ACCOUNT ;  
					
			ELSEIF ($V_UNIT_CD = 3) then   /* 포인트 사용 */
				UPDATE USER_DETAIL SET user_point = (user_point - $V_PRICE ) WHERE user_account = $V_USER_ACCOUNT ;
			END IF;
		END IF;
	END IF; 
		
	-- 무료뽑기인 경우, 
    IF($V_RESULT = 0) Then
		IF($V_DRAW_TYPE_CD=2 AND $V_DRAW_ID = 6) THEN 
			call abn_mgmtUserTimeEvent(2, $V_USER_ACCOUNT, 2, $V_RESULT);
            Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT, 4, 1, $V_RESULT); 
		END IF;
    END IF;
	/* 5. 사용자 정보 업데이트 (가차 타입에 따라 회수 제공 및 가격할인을 적용하기 위한 작업-> 현재는 사용 안함) */
	/*
	IF ($V_RESULT = 0) THEN
		
	-- 4-1) 사용자 가차정보 업데이트  
		IF (SELECT count(user_account) FROM USER_DRAW WHERE user_account=$V_USER_ACCOUNT AND get_type=$V_DRAW_ID) > 0 then
			-- 사용자 가차 정보 업데이트
			UPDATE 	USER_DRAW 
			   SET 	check_flag = 1,-- 완료 
					check_dt   = NOW()
			WHERE user_account = $V_USER_ACCOUNT AND get_type = $V_DRAW_ID; 
        ELSE
			INSERT INTO USER_DRAW (user_account, get_type, check_flag, check_dt) VALUES ($V_USER_ACCOUNT, $V_DRAW_ID, 1, NOW());
		END IF;
	END IF;
	*/	     
	/* 6. 리턴할 값 처리 */
	-- SELECT 	$V_RESULT as result, $V_DRAW_RWD_TYPE as draw_rwd_type, $V_DRAW_RWD_ID as draw_rwd_id,
	-- 		f_getRwdName($V_DRAW_RWD_TYPE,$V_DRAW_RWD_ID,0) as draw_rwd_nm; 
    select  $V_DRAW_RESULT as result_json, $V_RESULT as result;
END