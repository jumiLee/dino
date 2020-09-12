CREATE PROCEDURE `abn_mgmtUserPeriodItem`(
	$V_USER_ACCOUNT 	INT	-- ����� ����	
    ,$V_ITEM_UNIQUEID	BIGINT
    ,$V_V_ITEM_ID		INT
    ,OUT $V_RESULT		INT 	-- �����
)
BEGIN	
    DECLARE $V_REMAIN_DAY  INT;	-- ������ �ܿ�����
	SET $V_RESULT =0;
    
-- �ܿ����� üũ
    SET  $V_REMAIN_DAY = (select DATEDIFF(end_dt, now()) from user_item where item_uniqueID = $V_ITEM_UNIQUEID );
    
    IF ($V_REMAIN_DAY < 0) THEN -- �ܿ����� ������ ������ ���� ó��
		SET $V_REMAIN_DAY= 0;
    END IF;
    
-- ����� ���������� ������Ʈ 
	UPDATE 	user_item
	   SET 	remain_time = $V_REMAIN_DAY
			,last_mod_dt = now()
	 WHERE 	item_uniqueID = $V_ITEM_UNIQUEID ;
END