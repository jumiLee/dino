CREATE PROCEDURE `abn_mgmtUserPeriodItem`(
	$V_USER_ACCOUNT 	INT	-- 사용자 계정	
    ,$V_ITEM_UNIQUEID	BIGINT
    ,$V_V_ITEM_ID		INT
    ,OUT $V_RESULT		INT 	-- 결과값
)
BEGIN	
    DECLARE $V_REMAIN_DAY  INT;	-- 아이템 잔여일자
	SET $V_RESULT =0;
    
-- 잔여일자 체크
    SET  $V_REMAIN_DAY = (select DATEDIFF(end_dt, now()) from user_item where item_uniqueID = $V_ITEM_UNIQUEID );
    
    IF ($V_REMAIN_DAY < 0) THEN -- 잔여일이 없으면 아이템 만료 처리
		SET $V_REMAIN_DAY= 0;
    END IF;
    
-- 사용자 아이템정보 업데이트 
	UPDATE 	user_item
	   SET 	remain_time = $V_REMAIN_DAY
			,last_mod_dt = now()
	 WHERE 	item_uniqueID = $V_ITEM_UNIQUEID ;
END