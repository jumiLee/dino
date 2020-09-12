CREATE PROCEDURE `abn_getUserAttendList`(
	$V_JOB				INT,	/* �۾��ڵ� (1: �⼮��ü���� ��ȸ, 2:������ɾ�����Ʈ)*/
	$V_ATTEND_TYPE		INT,	/* �⼮Ÿ��			*/      
    $V_USER_ACCOUNT		INT,	/* ����� ����	*/
    $V_DAY_NO			INT		/* �����Ϸù�ȣ	*/ 
)
BEGIN
	DECLARE	$V_TODAY_ATTEND_FLAG INT;	/* ������å����				*/
	DECLARE $V_RWD_RCV_FLAG INT;		/* ������ɿ���				*/
	DECLARE $V_RWD_DAY_NO INT;			/* ������ɾ����ϼ�		*/
	DECLARE $V_RWD_RESULT INT;			/* ������ɰ��				*/
	
	SET $V_RWD_RCV_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE and rwd_rcv_flag=2 );
	
	IF ($V_RWD_RCV_FLAG > 0) then
		SET $V_RWD_DAY_NO = (select max(day_no) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE and rwd_rcv_flag=2);
	END IF;
	
	
	IF($V_JOB = 1) then
		/* �⼮ ������ ��ȸ */
		SELECT  t1.day_no, t1.rwd_type, t1.rwd_id, IFNULL(t1.rwd_sub_id,0) rwd_sub_id, IFNULL(t2.rwd_rcv_flag,0) rwd_rcv_flag,
				f_getRwdName (t1.rwd_type, t1.rwd_id,t1.rwd_sub_id) as rwd_nm
                ,if($V_RWD_DAY_NO=t1.day_no,true,false) as today_no
		  from (select * from MST_ATTEND where attend_type=$V_ATTEND_TYPE) t1 left outer join USER_ATTEND t2 
		    on  t1.attend_type = t2.attend_type and t1.day_no = t2.day_no 
		   and t2.user_account=$V_USER_ACCOUNT;
		    
		/* ��ȸ �� �������ó�� */ 
		IF ($V_RWD_RCV_FLAG > 0  ) Then
			Call abn_MgmtAttend (2,$V_USER_ACCOUNT,$V_ATTEND_TYPE,$V_RWD_DAY_NO,$V_RWD_RESULT); /*�������*/
		END IF;
	END IF;
	
END