CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_mgmtUserEvtPayment`(
	$V_JOB_TYPE			INT,	/* 1: 최초등록, 2:매일접속등록		*/
	$V_USER_ACCOUNT 	INT,	/* 사용자 계정		*/	
    $V_EVT_TYPE			INT,	/* 보상타입			*/
    $V_PAYMENT_TYPE			INT,	/* 결제사 타입			*/
    OUT $V_RESULT		INT 	/* 결과값			*/
)
BEGIN
	DECLARE $V_SEND_MSG VARCHAR(1000) CHARACTER SET utf8;
   	DECLARE $V_MSG_RESULT INT; 
    DECLARE $V_MSG NVARCHAR(1000); 
	DECLARE $V_SEND_COMMON_MSG VARCHAR(1000) CHARACTER SET utf8;
    
	DECLARE $V_SEND_COIN INT; DECLARE $V_EVT_DAY INT; DECLARE $V_REMAIN_DAY INT; DECLARE $V_COIN_AMT INT;
    SET $V_SEND_COIN= 20;
    SET $V_EVT_DAY = 28;
    SET $V_RESULT = 0;
    
-- 최초등록	
    IF ($V_JOB_TYPE = 1) then
		
		SET $V_SEND_COMMON_MSG = 'Thank you for buying the VIP30 item.';
			
		-- VIP30 상품 최초구매자
		IF (select count(user_account) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = 1 ) <=0 then	
			INSERT INTO USER_EVT_PAYMENT (user_account, evt_type, max_day_no, attend_day_no, make_dt, last_attend_dt)
			VALUES($V_USER_ACCOUNT, 1, $V_EVT_DAY, 1, now(), now());
                    
			SET $V_SEND_MSG = concat('VIP 30 Item-1st reward (Remain:' , ($V_EVT_DAY-1), 'days)');
		
        --  VIP30 상품 이용 완료자는 초기화                    	
        ELSE
			SET $V_REMAIN_DAY = (select (max_day_no - (datediff(now(),make_dt))) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = $V_EVT_TYPE);
            
			IF ( ($V_REMAIN_DAY <= 0) AND 
				 (select count(user_account) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = 1) > 0 ) then 
				UPDATE USER_EVT_PAYMENT 
				   SET max_day_no = $V_EVT_DAY, attend_day_no=1, make_dt=now(), last_attend_dt=now()
				 WHERE user_account = $V_USER_ACCOUNT and evt_type=1;
							 
				SET $V_SEND_MSG = concat('VIP 30 Item-1st reward (Remain:' ,($V_EVT_DAY-1), 'days)');
							 
			-- VIP30 상품 재구매자 
			ELSEIF (select count(user_account) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = 1 and max_day_no > attend_day_no) = 1 then 
				-- 잔여기간 연장 (기존잔여기간 + 28일)
				-- SET @cur_attned_day_no = (select attend_day_no from USER_EVT_PAYMENT where user_account = $V_USER_ACCOUNT and evt_type=1);
			
				UPDATE USER_EVT_PAYMENT
				   SET max_day_no = $V_EVT_DAY + $V_REMAIN_DAY, attend_day_no=1, last_attend_dt=now()
				 WHERE user_account = $V_USER_ACCOUNT and evt_type=1;
							 
				-- 기간내 재구매 시 180코인 즉시 지급
				SET $V_SEND_MSG = concat('VIP 30 Item-1st reward (Remain:' , ($V_EVT_DAY-1) + $V_REMAIN_DAY, 'days)');
							
			END IF;
		END IF;
                
		-- 결제상품 우편함으로 발송 
        SET $V_COIN_AMT = (select coin_amt from MST_CASH where cash_id = 8 and payment_type=$V_PAYMENT_TYPE);
		CALL abn_mgmtReceiveBox (3,$V_USER_ACCOUNT,null,0,5,$V_COIN_AMT,0, $V_SEND_COMMON_MSG, $V_MSG_RESULT,$V_MSG);  -- 180 캐시발송
		CALL abn_mgmtReceiveBox (3,$V_USER_ACCOUNT,null,0,5,$V_SEND_COIN,0, $V_SEND_MSG, $V_MSG_RESULT,$V_MSG);     -- 1회차 20캐시 발송  
        
        -- 발송로그 
        /*
        IF ($V_MSG_RESULT =0) then
			CALL Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT,9,1,0,5,510,$V_COIN_AMT,1,null);
            CALL Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT,9,1,0,5,510,$V_SEND_COIN,1,null);
		END IF;
		*/
    END IF;

-- 매일 등록    
    IF ($V_JOB_TYPE = 2) then
		IF (select count(user_account) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = $V_EVT_TYPE ) > 0 then
			
            SET $V_REMAIN_DAY = (select (max_day_no - (datediff(now(),make_dt))) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = $V_EVT_TYPE);
            
            IF(	$V_REMAIN_DAY > 0 	-- 잔여일이 남아있고, 
				AND (select count(user_account) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = $V_EVT_TYPE and DATE_FORMAT(last_attend_dt,'%Y%m%d') = DATE_FORMAT(now(),'%Y%m%d') ) = 0) then  -- 오늘 받은내역이 없으면, 
             
				UPDATE USER_EVT_PAYMENT
				   SET attend_day_no = (attend_day_no + 1), last_attend_dt = now()
				 where user_account=$V_USER_ACCOUNT and evt_type = $V_EVT_TYPE;
				
				
				SET @attend_day = (select attend_day_no from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = $V_EVT_TYPE);
				-- SET $V_REMAIN_DAY = (select (max_day_no - attend_day_no) from USER_EVT_PAYMENT where user_account=$V_USER_ACCOUNT and evt_type = $V_EVT_TYPE);
                -- 접속안하더라고 잔여일수는 계산됨
                
				IF (@attend_day = 2) then 
					SET $V_SEND_MSG = concat('VIP 30 Item ', @attend_day, 'nd reward (remain:' ,($V_REMAIN_DAY-1), 'days)');
                ELSEIF (@attend_day = 2) then 
					SET $V_SEND_MSG = concat('VIP 30 Item ', @attend_day, 'rd reward (remain:' ,($V_REMAIN_DAY-1), 'days)');
                ELSE 
					SET $V_SEND_MSG = concat('VIP 30 Item ', @attend_day, 'th reward (remain:' ,($V_REMAIN_DAY-1), 'days)');
                END IF;
                
				
				CALL abn_mgmtReceiveBox (3,$V_USER_ACCOUNT,null,0,5, $V_SEND_COIN, 0, $V_SEND_MSG, $V_MSG_RESULT,$V_MSG);      
                
                -- 발송로그 
                /*
                IF ($V_MSG_RESULT =0) then
					CALL Log_BaseLog ($V_USER_ACCOUNT,$V_USER_ACCOUNT,9,1,0,5,510,$V_SEND_COIN,1,null);
                END IF;
                */
			END IF;
        END IF;
    END IF;
END