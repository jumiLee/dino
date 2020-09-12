CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_getUserScore`(
	$V_USER_ACCOUNT	INT /*나의 계정*/
)
BEGIN

	DECLARE $V_TODAY_TOT_CNT INT;
    DECLARE $V_TODAY_WIN_CNT INT;
    DECLARE $V_TODAY_LOSE_CNT INT;
    DECLARE $V_TODAY_GOLD INT;
    
    DECLARE $V_TOT_CNT INT;
    DECLARE $V_TOT_WIN_CNT INT;
    DECLARE $V_TOT_LOSE_CNT INT;
    
    DECLARE $V_CNT2 INT;
    DECLARE $V_WIN_CNT2 INT;
    DECLARE $V_LOSE_CNT2 INT;
    
    DECLARE $V_CNT3 INT;
    DECLARE $V_WIN_CNT3 INT;
    DECLARE $V_LOSE_CNT3 INT;
    
    DECLARE $V_RANK INT;
    
    -- 오늘의 기록 정로 (from tbl_log_all)
    select 	sum(t1.gold) as today_gold
			,sum(t1.win_cnt) as today_win_cnt
			,sum(t1.lose_cnt) as today_lose_cnt
			,sum(t1.win_cnt) + sum(t1.lose_cnt) as today_total_cnt
            INTO $V_TODAY_GOLD, $V_TODAY_WIN_CNT, $V_TODAY_LOSE_CNT, $V_TODAY_TOT_CNT
	from (
	select 	 case when jobCode1 = 2 and jobCode2=1 then content1 else 0 end as gold
			,case when jobCode1 = 4 and content1 = 1 then 1 else 0 end win_cnt
			,case when jobCode1 = 4 and content1 = 2 then 1 else 0 end lose_cnt
	  from tbl_log_all
	where JobCode1 = 2 or JobCode1 = 4
	  and id = $V_USER_ACCOUNT
	  and DATE_FORMAT(issueDate,'%Y%m%d')=DATE_FORMAT(NOW(),'%Y%m%d')
	) t1;
    
    -- 현재랭킹
    SET $V_RANK = (select user_rank from user_score where user_account=$V_USER_ACCOUNT and score_type=1);
    -- 전적 기록 정로 (from tbl_log_Bat)
    /*
	select  sum(ifnull(win_cnt_2,0)+ifnull(lose_cnt_2,0)+ifnull(win_cnt_3,0)+ifnull(lose_cnt_3,0)) as total_cnt
			,sum(ifnull(win_cnt_2,0)+ifnull(win_cnt_3,0)) as total_win_cnt
			,sum(ifnull(lose_cnt_2,0)+ifnull(lose_cnt_3,0)) as total_lose_cnt
			,sum(ifnull(win_cnt_2,0)+ifnull(lose_cnt_2,0)) 
            ,sum(win_cnt_2)
            ,sum(lose_cnt_2)
            ,sum(ifnull(win_cnt_3,0)+ifnull(lose_cnt_3,0)) 
			,sum(win_cnt_3)
            ,sum(lose_cnt_3)
            ,sum(tot_user_rank)
			INTO $V_TOT_CNT, $V_TOT_WIN_CNT, $V_TOT_LOSE_CNT
            ,$V_CNT2, $V_WIN_CNT2, $V_LOSE_CNT2
            ,$V_CNT3, $V_WIN_CNT3, $V_LOSE_CNT3
            ,$V_RANK
	from (
	select 	case when score_type = 2 then (win_cnt)   else 0 end as win_cnt_2,
			case when score_type = 2 then (lose_cnt)  else 0 end as lose_cnt_2,
			case when score_type = 3 then (win_cnt)   else 0 end as win_cnt_3,
			case when score_type = 3 then (lose_cnt)  else 0 end as lose_cnt_3,
			case when score_type = 1 then (user_rank) else 0 end as tot_user_rank
	from user_score 
	where user_account=$V_USER_ACCOUNT
	) t1 ;
*/
	select  sum(ifnull(win_cnt_2,0)+ifnull(lose_cnt_2,0)+ifnull(win_cnt_3,0)+ifnull(lose_cnt_3,0)) as total_cnt
			,sum(ifnull(win_cnt_2,0)+ifnull(win_cnt_3,0)) as total_win_cnt
			,sum(ifnull(lose_cnt_2,0)+ifnull(lose_cnt_3,0)) as total_lose_cnt
			,sum(ifnull(win_cnt_2,0)+ifnull(lose_cnt_2,0)) 
            ,sum(win_cnt_2)
            ,sum(lose_cnt_2)
            ,sum(ifnull(win_cnt_3,0)+ifnull(lose_cnt_3,0)) 
			,sum(win_cnt_3)
            ,sum(lose_cnt_3)
			INTO $V_TOT_CNT, $V_TOT_WIN_CNT, $V_TOT_LOSE_CNT
            ,$V_CNT2, $V_WIN_CNT2, $V_LOSE_CNT2
            ,$V_CNT3, $V_WIN_CNT3, $V_LOSE_CNT3            
	from (
	select 	case when JobCode2 = 2 and content1 =1 then 1 else 0 end as win_cnt_2,
			case when JobCode2 = 2 and content1 =2 then 1 else 0 end as lose_cnt_2,
			case when JobCode2 = 3 and content1 =1 then 1 else 0 end as win_cnt_3,
			case when JobCode2 = 3 and content1 =2 then 1 else 0 end as lose_cnt_3
		from tbl_log_bat 
	where ID=$V_USER_ACCOUNT
	) t1 ;
	
     select	$V_TODAY_GOLD 		as today_total_gold
			,$V_TODAY_TOT_CNT 	as today_total_bat_cnt
            ,$V_TODAY_WIN_CNT 	as today_total_win_cnt
            ,$V_TODAY_LOSE_CNT 	as today_total_lose_cnt
			,$V_TOT_CNT 		as total_bat_cnt
            ,$V_TOT_WIN_CNT 	as total_win_cnt
            ,$V_TOT_LOSE_CNT 	as total_lose_cnt
            ,$V_CNT2			as total_bat_cnt2
            ,$V_WIN_CNT2 		as total_win_cnt2
            ,$V_LOSE_CNT2 		as total_lose_cnt2
            ,$V_CNT3 			as total_bat_cnt3
            ,$V_WIN_CNT3 		as total_win_cnt3
            ,$V_LOSE_CNT3		as total_lose_cnt3
            ,$V_RANK 			as user_rank
            ;
END