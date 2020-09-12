CREATE DEFINER=`edenweb`@`%` PROCEDURE `gm_mgmtUserProperty`(
	$V_JOB_TYPE 	INT, 	-- 1:update
    $V_USER_ACCOUNT INT,	-- 나의계정
    $V_UNIT_CD 		INT, 	-- 비용타입 (1 : user_gold  / 2 : user_coin/ 3 : then user_point)
    $V_CHANGE_AMT	INT,	-- 바꿀 금액
    OUT $V_RESULT	INT		-- 결과값
)
BEGIN
    DECLARE $V_USE_TYPE	INT;
    DECLARE $V_CUR_AMT INT;
    DECLARE $V_AMT_DIFF INT;
    DECLARE $V_MODI_JOB_TYPE INT;
    DECLARE $V_OUT_RESULT INT;
    
	SET $V_RESULT = 0;
	SET $V_USE_TYPE = 5; -- AI충전
    
	IF($V_JOB_TYPE = 1) then
		-- AI인지 체크 
        IF (select count(user_account) from mst_user where user_account=$V_USER_ACCOUNT and user_level=3) = 0  then 
			SET $V_RESULT = -1; -- 계정에 해당하는 AI 없음
        END IF;
		
        IF ($V_RESULT = 0) THEN
			SET $V_CUR_AMT = (select 
								case 
									when $V_UNIT_CD = 1 then user_gold
									when $V_UNIT_CD = 2 then user_coin
									when $V_UNIT_CD = 3 then user_point
								end as amt
							   from user_detail
							  where user_account=$V_USER_ACCOUNT );
			
            SET $V_AMT_DIFF = ($V_CHANGE_AMT - $V_CUR_AMT);   
            
            IF($V_AMT_DIFF > 0) THEN
				SET $V_MODI_JOB_TYPE = 2; -- 1: 사용, 2:획득
            ELSEIF($V_AMT_DIFF < 0) THEN
				SET $V_MODI_JOB_TYPE = 1;
            END IF;
            
            IF ($V_AMT_DIFF <> 0 ) THEN
				Call abn_mgmtUserProperty ($V_MODI_JOB_TYPE , $V_USER_ACCOUNT, $V_USE_TYPE, 1 , abs($V_AMT_DIFF) , $V_OUT_RESULT);
			END IF;
        END IF;
    END IF;
END