CREATE PROCEDURE `abn_mgmtUserTimeEvent`(
	$V_JOB_TYPE 		INT,	-- 1:main 무료가차 활성화를 위한 new notice update , 2:user_evt_payment update, 3:무료뽑기 가능 시간 체크 
	$V_USER_ACCOUNT 	INT,	-- 사용자 계정
    $V_EVT_TYPE			INT,	-- 이벤트타입 (2:30분 무료가차)
    OUT $V_REMAIN_SECOND INT 	-- 남은시간
)
BEGIN
	
    DECLARE $V_EVT_DAY INT;     
    DECLARE $V_ATTEND_DAY_NO INT;
    DECLARE $V_REMAIN_TIME INT; -- 다음활성화까지 남은 시간
    DECLARE $V_INTERVAL INT; -- 마지막 접속시간과의 간격
    DECLARE $V_MAX_TIME INT; -- 체크간격
    DECLARE $V_NOTICE_TYPE INT ;
    DECLARE $V_RESULT INT ;
    
    SET $V_EVT_DAY = 1800; -- 최초 시간 간격 30분
	SET $V_ATTEND_DAY_NO = 1; -- 최초 1회
    SET $V_NOTICE_TYPE = 4; 
    SET $V_RESULT = 0;
    SET $V_REMAIN_SECOND = 0;
    
    IF($V_JOB_TYPE = 1) THEN 
		IF((select  count(user_account) from USER_EVT_PAYMENT 
			 where	user_account = $V_USER_ACCOUNT
               and 	evt_type = $V_EVT_TYPE
               and	TIMESTAMPDIFF(SECOND, last_attend_dt,now()) <  max_day_no ) > 0) THEN
               
			SET $V_REMAIN_SECOND = (select $V_EVT_DAY - TIMESTAMPDIFF(SECOND, last_attend_dt,now()) from USER_EVT_PAYMENT where	user_account = $V_USER_ACCOUNT and evt_type = $V_EVT_TYPE); 
         ELSE
			SET $V_REMAIN_SECOND = 0;
             -- notice 등록
			Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT, $V_NOTICE_TYPE, 2, $V_RESULT); 
         END IF;
    END IF;
        
    IF($V_JOB_TYPE = 2) THEN 
        IF((select count(user_account) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type=$V_EVT_TYPE) = 0) then 
			INSERT INTO USER_EVT_PAYMENT (user_account, evt_type, max_day_no, attend_day_no, make_dt, last_attend_dt)
			VALUES($V_USER_ACCOUNT, $V_EVT_TYPE, $V_EVT_DAY, $V_ATTEND_DAY_NO, now(), now());
        ELSE
			UPDATE 	USER_EVT_PAYMENT 
			   SET 	max_day_no = $V_EVT_DAY	-- interval을 점점 늘리고 싶으면 여기 수정.
					,attend_day_no= (attend_day_no + 1)
					,make_dt = now()
					,last_attend_dt = now()
			 WHERE 	user_account = $V_USER_ACCOUNT 
               and 	evt_type=$V_EVT_TYPE;		
		END IF; 
    END IF;    
    
    IF($V_JOB_TYPE = 3) THEN
		SET $V_REMAIN_SECOND = (select $V_EVT_DAY - TIMESTAMPDIFF(SECOND, last_attend_dt,now()) from USER_EVT_PAYMENT where	user_account = $V_USER_ACCOUNT and evt_type = $V_EVT_TYPE); 
    END IF;
END