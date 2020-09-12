CREATE PROCEDURE `abn_mgmtCommonReward_out`(
	  $V_JOB_TYPE		INT,	/* 1: 보상처리		*/
      $V_USER_ACCOUNT 	INT,	/* 사용자 계정		*/	
      $V_RWD_TYPE		INT,	/* 보상타입			*/
      $V_RWD_ID			INT,	/* 보상아이디		*/   
      $V_RWD_SUB_ID		INT,	/* 보상서브아이디	*/    
      OUT $V_RESULT		INT 	/* 결과값			*/
)
BEGIN
/* 변수정의*/ 
	DECLARE $V_RESULT_ITEM INT;
	DECLARE $V_RESULT_ITEM_MSG VARCHAR(100);
    DECLARE $V_ITEM_CNT INT; 
    DECLARE $V_TRE_CNT INT; DECLARE i INT DEFAULT 1;  -- 보석추가 관련
	DECLARE $V_EXIST_RWD_ID INT;
	DECLARE $V_RECEIVE_MSG VARCHAR(1000) CHARACTER SET utf8; DECLARE $V_MSG_RESULT INT; DECLARE $V_MSG_RESULT_MSG VARCHAR(1000) ;
	DECLARE $V_RESULT_RWD INT; 

/* 변수초기화*/ 
	SET $V_RESULT = 0;
	SET $V_RESULT_ITEM = 0;
	SET $V_RESULT_ITEM_MSG = '';
	SET $V_EXIST_RWD_ID =0;
	SET $V_RESULT_RWD = 0;

/* 1. 공통 보상 처리 */ 
	IF ($V_JOB_TYPE = 1) THEN
		
        /* 1-1. 아이템 보상 */
		IF($V_RWD_TYPE = 1) THEN
		
			/* 아이템 정보 조회 */
				SET $V_EXIST_RWD_ID = (select COUNT(item_id) from MST_ITEM where item_id = $V_RWD_ID);
				IF ($V_EXIST_RWD_ID = 0)  THEN
					SET $V_RESULT = -11;	/* 없는 아이템 */ 
				END  IF;
                IF ($V_RWD_SUB_ID = 0) then
					SET $V_ITEM_CNT= 1;
                ELSE
					SET $V_ITEM_CNT = $V_RWD_SUB_ID; -- 아이템인 경우엔 $V_RWD_SUB_ID에 아이템 개수를 보냄
				END IF;
			
			/* 아이템 추가	*/	
				IF($V_RESULT = 0 ) THEN
					Call abn_MgmtItem_out (5, $V_USER_ACCOUNT, $V_RWD_ID, $V_ITEM_CNT , 0, $V_RESULT_ITEM , $V_RESULT_ITEM_MSG);
					IF ($V_RESULT_ITEM <> 0) then
						SET $V_RESULT = -12	;
					End if;
				END IF;	
		END  IF;
        
		/* 1-4. Money 보상 */				
		IF($V_RWD_TYPE = 4) then
				UPDATE USER_DETAIL
				  SET user_gold = user_gold + $V_RWD_ID
				 WHERE user_account = $V_USER_ACCOUNT ;
							
				IF(ROW_COUNT() = 0 ) then 
					SET $V_RESULT = -41	;
				end if;
				
		END IF;
			
		/* 1-5. 캐쉬 보상 */				
		IF($V_RWD_TYPE = 5) then
		
				UPDATE USER_DETAIL
				  SET user_coin = user_coin + $V_RWD_ID
				 WHERE user_account = $V_USER_ACCOUNT;
				 
			SET @rc = (SELECT ROW_COUNT() );
				IF(@rc = 0 ) then 
					SET $V_RESULT = -51	;
				end if;
		END IF;
			
		/* 1-6. 포인트 보상 */				
		IF($V_RWD_TYPE = 6)  then
		
				UPDATE USER_DETAIL
				  SET user_point = user_point + $V_RWD_ID
				 WHERE user_account = $V_USER_ACCOUNT;
				 
				IF(ROW_COUNT() = 0 ) then 
					SET $V_RESULT = -61	;
				end if;
		END IF;				
		
		
		/*1-21. 뽑기권일 경우 우편함으로 지급 */
		IF($V_RWD_TYPE = 21 ) then
		
			SET $V_RECEIVE_MSG = '보상이 지급되었습니다.';
			Call abn_mgmtReceiveBox (3, $V_USER_ACCOUNT, null,0,$V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RECEIVE_MSG, $V_MSG_RESULT, $V_MSG_RESULT_MSG);
			
		END IF;
		
		 
	END IF; /* end job_code=1 */
END