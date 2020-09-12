CREATE PROCEDURE `abn_MgmtAttend`( 
	IN $V_JOB			INT,	/* �۾��ڵ� (1: �⼮���, 2:������ɾ�����Ʈ)*/
	IN $V_USER_ACCOUNT	INT,	/* ����� ����	*/
    IN $V_ATTEND_TYPE	INT,	/* �⼮Ÿ��			*/
    IN $V_DAY_NO		INT,	/* �����Ϸù�ȣ	*/
    OUT $V_RESULT		INT 	/* �����				*/
)
BEGIN

/* �������� */
	DECLARE $V_EXIST_ATTEND_CNT INT;  /* �̹� ��ϵ� �⼮���� �� */
	DECLARE $V_RWD_TYPE INT;					/* ����Ÿ��		*/
	DECLARE $V_RWD_ID INT;						/* ������̵�	*/	
    DECLARE  $V_RWD_RCV_FLAG INT; 				/* ������ɿ��� */
	DECLARE $V_RWD_SUB_ID INT;				/* ���󼭺���̵�(�����ΰ�츸)	*/
	DECLARE	$V_RWD_RESULT INT;				/* �������ó�� ��� */
	DECLARE $V_MAX_ATTEND_CNT INT;		/* �� �⼮�� ��*/
	DECLARE $V_RECEIVE_MSG NVARCHAR(1000);
	DECLARE $V_RWD_NAME NVARCHAR(100); /* �̱�� ������ ��� ���*/
	DECLARE $V_MSG_RESULT_MSG NVARCHAR(1000);
	DECLARE $V_MSG_RESULT INT ;  /* �̱�� ������ ��� ���*/

/* ������ ��ȸ */	
	IF  $V_DAY_NO is null or $V_DAY_NO =0 THEN
		SET $V_MAX_ATTEND_CNT = (select COUNT(day_no) from MST_ATTEND where attend_type=$V_ATTEND_TYPE);
		SET $V_DAY_NO = (select IFNULL(MAX(day_no),0)+1 from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE)	;
	
	/* �⼮üũ�Ϸ� �� ������ �ʱ�ȭ */
		IF $V_MAX_ATTEND_CNT < $V_DAY_NO THEN
			DELETE FROM USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE;
			set $V_DAY_NO = 1;
		END IF;
	END IF;
	
	SET $V_EXIST_ATTEND_CNT = (select COUNT(user_account) from USER_ATTEND where user_account = $V_USER_ACCOUNT and attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO);
	SET $V_RESULT = 0;
	SET $V_RWD_RESULT = 0;
	
/* �⼮ ��� */
	IF $V_JOB = 1 THEN
		IF (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=1 and DATE_FORMAT(attend_date,'%Y%m%d')=DATE_FORMAT(NOW(),'%Y%m%d') ) = 0 THEN -- ���� �⼮�̷� ������,
			IF $V_EXIST_ATTEND_CNT = 0 THEN	/* �������ʵ��*/
				INSERT INTO USER_ATTEND (user_account, attend_type, attend_date, day_no, rwd_rcv_flag) VALUES($V_USER_ACCOUNT, $V_ATTEND_TYPE, NOW(), $V_DAY_NO, 2);
			ELSE
				SET $V_RESULT = -12 ;  /* �̹� ��� */ 
			END IF;
        END IF;
	END IF;
	
/* ������ɾ�����Ʈ */
	IF $V_JOB = 2 THEN
	
	/* ����������� �˻� */
		IF $V_EXIST_ATTEND_CNT = 0 THEN
			SET $V_RESULT = -21 ;		/* ��ϵ� �⼮���� ���� */
		END IF;
		
		IF $V_RESULT = 0 THEN
		
			SET $V_RWD_RCV_FLAG = (select rwd_rcv_flag from USER_ATTEND where user_account = $V_USER_ACCOUNT and attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO );
			
			IF  $V_RWD_RCV_FLAG = 1 THEN
				SET $V_RESULT = -22;  /* �̹� �������� */			
			END IF;
		END IF;
		
	/* ���� ���� */
		IF $V_RESULT = 0 THEN
			
			-- SELECT $V_RWD_TYPE = rwd_type, $V_RWD_ID = rwd_id, $V_RWD_SUB_ID = rwd_sub_id FROM MST_ATTEND WHERE attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO ;
            SELECT rwd_type, rwd_id, rwd_sub_id into $V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID FROM MST_ATTEND WHERE attend_type = $V_ATTEND_TYPE and day_no = $V_DAY_NO ;
			/* -- ��� ���������� �������� ���� 
			IF ($V_RWD_TYPE = 21) THEN	-- �̱�� ���� ����
				SET $V_RWD_NAME = (select cd_value_nm from MST_CODE where cd_column='rwd_type' and cd_value=$V_RWD_TYPE );
				SET $V_RECEIVE_MSG = CONCAT('[�⼮����] ' ,$V_RWD_NAME, '�� ���޵Ǿ����ϴ�.');
				CALL abn_mgmtReceiveBox (3, $V_USER_ACCOUNT, null,0,$V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RECEIVE_MSG, $V_MSG_RESULT, $V_MSG_RESULT_MSG);
			ELSE  -- �Ϲ� ���� ���� 
				CALL abn_mgmtCommonReward_out (1, $V_USER_ACCOUNT, $V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RWD_RESULT);
			END IF;
            */
            SET $V_RWD_NAME = (select f_getRwdName($V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID) );
			SET $V_RECEIVE_MSG = CONCAT('[Attendance] Please receive ' ,$V_RWD_NAME);
			CALL abn_mgmtReceiveBox (3, $V_USER_ACCOUNT, null,0,$V_RWD_TYPE, $V_RWD_ID, $V_RWD_SUB_ID, $V_RECEIVE_MSG, $V_MSG_RESULT, $V_MSG_RESULT_MSG);
			
		END IF;
		
	/* ���� ���� ��� ������Ʈ */
		IF $V_RESULT = 0 THEN
		
			UPDATE USER_ATTEND 
			   SET rwd_rcv_flag = 1 , rwd_rcv_date = NOW()
			 WHERE user_account = $V_USER_ACCOUNT
			   AND attend_type	= $V_ATTEND_TYPE
			   AND day_no		= $V_DAY_NO ;
		END	IF;
		
	END IF;
END