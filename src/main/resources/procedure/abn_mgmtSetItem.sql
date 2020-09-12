CREATE PROCEDURE `abn_mgmtSetItem`(
	$V_JOB_TYPE			INT,	-- 1: ��Ʈ������ ���� & ���� 
    $V_USER_ACCOUNT 	INT,  	-- ����� ���� 
	$V_ITEM_ID 			INT,  	-- �����۾��̵� 
	$V_ITEM_UNIQUEID   	BIGINT, -- ������ ������ȣ
	OUT $V_RESULT      	INT
)
BEGIN
	
	DECLARE $V_RWD_RESULT INT; DECLARE $V_ITEM_RESULT_MSG NVARCHAR(50);
	DECLARE $V_RWD_TYPE INT; DECLARE $V_RWD_ID INT; DECLARE $V_RWD_SUB_ID INT;
    DECLARE $V_RWD_MSG			VARCHAR(100) CHARACTER SET utf8; 
    DECLARE $V_RWD_RESULG_MGS 	VARCHAR(100) CHARACTER SET utf8; 	
	DECLARE vRowCount INT DEFAULT 0;
	DECLARE cur_SetItemList CURSOR FOR SELECT rwd_type, rwd_id, rwd_sub_id FROM MGR_REWARD where rwd_category=9 and rwd_category_value= $V_ITEM_ID; 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vRowCount = 1; /* ������ ���� ��� ó�� */

	SET $V_RESULT = 0;

	IF ($V_JOB_TYPE = 1) then 
	
		OPEN cur_SetItemList;
		read_loop: loop
		FETCH cur_SetItemList INTO $V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID;
		
		IF (vRowCount = 1) then
			LEAVE read_loop;
		END IF;

	/* 1. ��Ʈ������ �� ���� ó�� */
		/* IF($V_RESULT = 0 AND  $V_RWD_TYPE <> 21) THEN */
		IF($V_RESULT = 0) THEN
			START transaction;
			/* 1) �������� */
            
				IF( $V_RWD_TYPE = 21 ) then -- �̱���� �޼��������� ����
					SET $V_RWD_MSG =(select cd_value_nm from MST_CODE where cd_column='system_message' and cd_value=2);
		
					Call abn_mgmtReceiveBox( 	3, 	-- �߼�
												$V_USER_ACCOUNT, 
												0, 
												0, -- sender account
												$V_RWD_TYPE,
												$V_RWD_ID, 
												$V_RWD_SUB_ID,
												$V_RWD_MSG, 
												$V_RWD_RESULT, 
												$V_RWD_RESULG_MGS );
                ELSE
					Call abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RWD_RESULT);
                END IF;    
				
				IF ($V_RWD_RESULT <> 0 ) then
					SET $V_RESULT = -11;
				END IF; 
					
							
				IF($V_RESULT <> 0 ) then
					ROLLBACK;
				ELSE
					COMMIT;
				END IF;
		END IF; /* End ($V_RESULT=0) */
				
		END LOOP read_loop;
		CLOSE cur_SetItemList;

	-- ������ ���ó�� 				
		IF ($V_RESULT  = 0 ) then
			Call abn_MgmtItem_use($V_USER_ACCOUNT,$V_ITEM_UNIQUEID, 1, $V_RESULT);
		END IF;

	END IF; /* end (job_type=1)*/

END