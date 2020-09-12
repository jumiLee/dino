CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_BattleEnd`(
	$V_JOB_TYPE			INT,	-- 작업코드 (2:2장, 3:3장, 4:evemt)
    $V_USER_ACCOUNT   	INT,	-- 사용자 계정
    $V_BAT_ROOM_NO    	INT,	-- 서버에서 생성하는 room No.
    $V_BAT_POINT		INT,	-- 승패에 따른 획득포인트 -> 승패 계산결과 사용자 총 포인트 (추가보너스 포함)
    $V_EVT_POINT		INT,	-- 추가 보너스 포인트
    $V_BAT_RESULT		INT,  	-- 승패
    OUT $V_RESULT		INT 	-- 결과값      
)
BEGIN
	DECLARE $V_RANK_RESULT INT;
    DECLARE $V_BAT_TYPE INT;
	DECLARE $V_CUR_POINT INT;    
    DECLARE $V_GET_POINT INT;
    
	SET $V_RESULT = 0;
	SET $V_CUR_POINT = (select user_gold from user_detail where user_account=$V_USER_ACCOUNT);
	SET $V_GET_POINT = ($V_BAT_POINT - $V_CUR_POINT);

	-- Gold 지급 처리 
	SET @V_USE_TYPE = $V_JOB_TYPE; -- 추후 재정의 될 수 있음.
	Call abn_mgmtUserProperty(2, $V_USER_ACCOUNT, @V_USE_TYPE, 1, $V_GET_POINT, $V_RESULT );
	
	IF ($V_RESULT <> 0 ) THEN 
		SET $V_RESULT = -11;
	End if;
		
	-- Ranking update
	IF($V_RESULT = 0) THEN
		IF($V_EVT_POINT > 0) THEN
			-- 이벤트 랭킹
			Call abn_mgmtUserRank (1,$V_USER_ACCOUNT, $V_JOB_TYPE, $V_EVT_POINT, $V_BAT_RESULT, $V_RANK_RESULT);

			IF ($V_RANK_RESULT <> 0 ) THEN
				SET $V_RESULT = -12;
			End if;
        END IF;
	END IF;
    
	-- 로그 
	IF($V_RESULT = 0)  THEN
		IF($V_JOB_TYPE =2 ) THEN
			SET $V_BAT_TYPE =2;
		ELSEIF ($V_JOB_TYPE =3 ) THEN
			SET $V_BAT_TYPE =3;
		END IF;        
		CALL Log_BaseLog ($V_USER_ACCOUNT, $V_USER_ACCOUNT, 2,1, 1, $V_BAT_TYPE, $V_GET_POINT, null, null, null); -- 골드득실 로그
		CALL Log_BaseLog ($V_USER_ACCOUNT, $V_USER_ACCOUNT, 4,$V_BAT_TYPE,0, $V_BAT_RESULT, null, null, null, null); -- 승패 로그
	END IF;
		
END