CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_AddMonExp`(
	$V_USER_ACCOUNT INT,  	/*유저정보*/
	$V_MON_ID INT,		  	/*몬스터 ID*/
	$V_MON_SN INT,		  	/*몬스터 번호*/
	$V_EXP INT,			    /*증가될 경험치*/
	OUT $V_RESULT	INT 	/*레벨업 여부  (0:LevelUp X, 1:LevelUp O, -1:더이상 레벨업 할 수 없음)*/
)
BEGIN
	
	DECLARE $V_NEW_MON_EXP INT;   	/*증가된 경험치						*/
	DECLARE $V_NEW_MON_LEVEL INT; 	/*변경될 레벨							*/
	DECLARE $V_ESS_MON_EXP INT;   	/*필요 경험치							*/	
	DECLARE $V_NEW_ITEM_ID INT;   	/*레벨업에 따른 획득ITEM	*/
	DECLARE	$V_MON_MAX_LV	INT;	/*몬스터 max level				*/
	DECLARE $V_MON_LV	INT;		/*현재 몬스터 레벨				*/
	DECLARE $V_MON_EXP	INT;		/*현재 몬스터 경험치			*/
	DECLARE $V_BOOK_RESULT INT;		/*도감만랩업데이트 결과		*/
	DECLARE $V_RESULT_ITEM INT; 
	DECLARE $V_RESULT_ITEM_MSG VARCHAR(100);
	DECLARE $V_ACHV_RESULT INT; DECLARE $V_RESULT_NOTICE INT;

	SET $V_RESULT  = 0;	/*levelup X */
	SET $V_ACHV_RESULT =0;
	SET $V_RESULT_NOTICE =0;

	/* 현재몬스터 레벨, 경험치, 스텟정보 및 최대레벨값 조회 */
		SET $V_MON_MAX_LV = (select mon_max_lv from mst_monster where mon_id=$V_MON_ID);
		SELECT mon_level, mon_exp  into $V_MON_LV, $V_MON_EXP
		  FROM user_monster where user_account=$V_USER_ACCOUNT and mon_id=$V_MON_ID and user_mon_sn=$V_MON_SN;

					
 	/* 현재 경험치로 변경될 레벨, 경험치 정보 조회 */	
 		IF($V_MON_LV = $V_MON_MAX_LV) Then  /* 이미 만랩에 도달한 경우엔 경험치만 증가 -> 경험치도 오르지 않도록 수정 */
			SET $V_NEW_MON_EXP = $V_MON_EXP ; 
	 		SET $V_NEW_MON_LEVEL = $V_MON_LV; 
 		ELSE
 		
			SET $V_NEW_MON_EXP = $V_EXP + $V_MON_EXP; 
 			SET $V_NEW_MON_LEVEL = $V_MON_LV; 
 			
			SELECT EXP, item_id into $V_ESS_MON_EXP, $V_NEW_ITEM_ID FROM mst_level WHERE level_type=2 and level = $V_MON_LV+1;

			WHILE ($V_NEW_MON_EXP >= $V_ESS_MON_EXP) DO	/* 추가된 경험치가 레벨업에 도달하는 동안 */
				SET $V_RESULT = 1;	/*levelup O */
				IF($V_NEW_MON_LEVEL < $V_MON_MAX_LV) Then /* 최대레벨 도달이면, STOP */
					/* 레벨업 보상아이템이 있는경우 지급 */
 					IF ($V_NEW_ITEM_ID <> 0	) THEN
						CALL abn_MgmtItem_out (7, $V_USER_ACCOUNT, $V_NEW_ITEM_ID, 1, 0, $V_RESULT_ITEM, $V_RESULT_ITEM_MSG);
					END IF;
					
					/* 레벨업 후 다음 레벨업 체크를 위해 */					  							
					SET $V_NEW_MON_LEVEL = $V_NEW_MON_LEVEL+1; 
 					SET $V_NEW_MON_EXP	 = ($V_NEW_MON_EXP - $V_ESS_MON_EXP); 
 					SET $V_ESS_MON_EXP   = (select EXP FROM mst_level WHERE level_type=2 and level = $V_NEW_MON_LEVEL+1);
 				END IF;	                
                               
 			END WHILE;
		END If;
	
	/* 1. 몬스터 정보 업데이트  */		
		IF($V_RESULT = 1) Then /* 레벨업 한 경우 */
			UPDATE user_monster 
  			   SET mon_exp = $V_NEW_MON_EXP
				  ,mon_level = $V_NEW_MON_LEVEL
                  ,last_mod_dt=now()
  			 WHERE user_account = $V_USER_ACCOUNT
  			   AND mon_id = $V_MON_ID
			   AND user_mon_sn = $V_MON_SN;			
		ELSE
			UPDATE user_monster 
  			   SET mon_exp = $V_NEW_MON_EXP 
				  ,last_mod_dt=now()
  			 WHERE user_account = $V_USER_ACCOUNT
  			   AND mon_id = $V_MON_ID
			   AND user_mon_sn = $V_MON_SN;
		END IF;
	
	/* 몬스터 최대 경험치 도달 시 도감 업데이트 */				
	IF($V_NEW_MON_LEVEL = $V_MON_MAX_LV) Then /* 몬스터 레벨 최대치 도달 */
		
		SET $V_RESULT = -1;
		
		UPDATE user_monster 
  		   SET mon_exp = 0
  		 WHERE user_account = $V_USER_ACCOUNT
  		   AND mon_id = $V_MON_ID
		   AND user_mon_sn = $V_MON_SN;
	END If;
END