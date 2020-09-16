CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_AddUserMonster`(
	$V_USER_ACCOUNT 	INT
    ,$V_MON_ID       	INT 
    ,$V_MCT_ID			INT 
    ,OUT $V_RESULT		INT	/* 결과값*/
    ,OUT $V_USER_MON_SN	INT /* 새로 등록될 포획한 몬스터의 일련번호 */
)
BEGIN
	
    DECLARE $V_NOTICE_RESULT INT;
    
    SET $V_RESULT = 0;
    SET $V_USER_MON_SN = 0;
    SET $V_NOTICE_RESULT = 0;
    
	/* 1. 내 몬스터 정보 확인 (USER_MONSTER)  */
		SET $V_USER_MON_SN = (select ifnull((max(user_mon_sn) + 1 ),1) FROM user_monster WHERE user_account = $V_USER_ACCOUNT);
        
	/* 2. 내 몬스터로 등록 (USER_MONSTER, MST_MONSTER) */
		INSERT INTO user_monster (user_account ,mon_id ,user_mon_sn ,mon_level ,mon_exp ,mon_color_type ,mct_id ,create_dt, last_mod_dt) 
		SELECT 	$V_USER_ACCOUNT  	as user_account, 
				$V_MON_ID          	as mon_id, 
				$V_USER_MON_SN		as user_mon_sn, 
				1		           	as mon_level, 
				0                  	as mon_exp, 
				0             		as mon_color_type, 
                $V_MCT_ID			as mct_id,
				now()				as create_dt,
				now()		   		as last_mod_dt
		  FROM mst_monster
		 WHERE mon_id = $V_MON_ID;  
		
		IF ( ROW_COUNT() = 0 ) then 
			SET $V_RESULT = -1; 
		ELSE 
        /* 사용자 공지 등록 (USER_NEW_NOTICE) */
			Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT, 4, 1);
		END IF;
END