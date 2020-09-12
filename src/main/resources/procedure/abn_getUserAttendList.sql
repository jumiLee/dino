CREATE PROCEDURE `abn_getUserAttendList`(
	$V_JOB				INT,	/* 작업코드 (1: 출석전체정보 조회, 2:보상수령업데이트)*/
	$V_ATTEND_TYPE		INT,	/* 출석타입			*/      
    $V_USER_ACCOUNT		INT,	/* 사용자 계정	*/
    $V_DAY_NO			INT		/* 일자일련번호	*/ 
)
BEGIN
	DECLARE	$V_TODAY_ATTEND_FLAG INT;	/* 오늘출책여부				*/
	DECLARE $V_RWD_RCV_FLAG INT;		/* 보상수령여부				*/
	DECLARE $V_RWD_DAY_NO INT;			/* 보상수령안한일수		*/
	DECLARE $V_RWD_RESULT INT;			/* 보상수령결과				*/
	
	SET $V_RWD_RCV_FLAG = (select COUNT(user_account) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE and rwd_rcv_flag=2 );
	
	IF ($V_RWD_RCV_FLAG > 0) then
		SET $V_RWD_DAY_NO = (select max(day_no) from USER_ATTEND where user_account=$V_USER_ACCOUNT and attend_type=$V_ATTEND_TYPE and rwd_rcv_flag=2);
	END IF;
	
	
	IF($V_JOB = 1) then
		/* 출석 데이터 조회 */
		SELECT  t1.day_no, t1.rwd_type, t1.rwd_id, IFNULL(t1.rwd_sub_id,0) rwd_sub_id, IFNULL(t2.rwd_rcv_flag,0) rwd_rcv_flag,
				f_getRwdName (t1.rwd_type, t1.rwd_id,t1.rwd_sub_id) as rwd_nm
                ,if($V_RWD_DAY_NO=t1.day_no,true,false) as today_no
		  from (select * from MST_ATTEND where attend_type=$V_ATTEND_TYPE) t1 left outer join USER_ATTEND t2 
		    on  t1.attend_type = t2.attend_type and t1.day_no = t2.day_no 
		   and t2.user_account=$V_USER_ACCOUNT;
		    
		/* 조회 후 보상수령처리 */ 
		IF ($V_RWD_RCV_FLAG > 0  ) Then
			Call abn_MgmtAttend (2,$V_USER_ACCOUNT,$V_ATTEND_TYPE,$V_RWD_DAY_NO,$V_RWD_RESULT); /*보상수령*/
		END IF;
	END IF;
	
END