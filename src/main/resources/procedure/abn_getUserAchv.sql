CREATE PROCEDURE `abn_getUserAchv`(
	$V_JOB_TYPE			INT,	-- 1: 업적리스트조회
    $V_USER_ACCOUNT 	INT,  	-- 사용자 계정 
    $V_ACHV_TYPE		INT,	-- 업적타입
    $V_ACHV_ID			INT		-- 업적아이디
)
BEGIN
	/* 1. 업적리스트 조회 */
	IF ($V_JOB_TYPE = 1) Then
		IF ($V_ACHV_TYPE = 5 or $V_ACHV_TYPE = 7 or $V_ACHV_TYPE = 9) Then /* PVP, 무한대전, 월드보스 랭킹보상은 우편함으로 지급. 여기서는 리스트만 보여줌 */
		
			IF ($V_ACHV_ID is null) Then
				select 	achv_type, achv_id, achv_title, achv_content, achv_complete_cnt, achv_rwd_type, achv_rwd_id, achv_rwd_sub_id, 
						'' rwd_name, 
						2 as achv_complete_flag, 2 as rwd_rcv_flag, 0 as achv_cnt, '' as achv_complete_dt, '' as rwd_rcv_dt, '' as achv_upd_dt
				  from MST_ACHIEVEMENT 
				 where achv_type=$V_ACHV_TYPE
				   and DATE_FORMAT(achv_apply_fr_dt,'%Y-%m-%d %H') <= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
				   and DATE_FORMAT(achv_apply_to_dt,'%Y-%m-%d %H') >= DATE_FORMAT(NOW(),'%Y-%m-%d %H');				
			ELSE
				select 	achv_type, achv_id, achv_title, achv_content, achv_complete_cnt, achv_rwd_type, achv_rwd_id, achv_rwd_sub_id, 
						'' rwd_name, 
						2 as achv_complete_flag, 2 as rwd_rcv_flag, 0 as achv_cnt, '' as achv_complete_dt, '' as rwd_rcv_dt, '' as achv_upd_dt
				 from MST_ACHIEVEMENT 
			    where achv_type=$V_ACHV_TYPE and achv_id= $V_ACHV_ID
                  and DATE_FORMAT(achv_apply_fr_dt,'%Y-%m-%d %H') <= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
				   and DATE_FORMAT(achv_apply_to_dt,'%Y-%m-%d %H') >= DATE_FORMAT(NOW(),'%Y-%m-%d %H');
			END IF; 
		ELSE
			IF ($V_ACHV_ID is null) then
				select 	t1.achv_type, t1.achv_id, 
						concat(t1.achv_title ,'(', IFNULL(t2.achv_cnt,0), '/' , t1.achv_complete_cnt ,')') as achv_title, 
						t1.achv_content, t1.achv_complete_cnt, t1.achv_rwd_type, t1.achv_rwd_id, t1.achv_rwd_sub_id,
						f_getRwdName (t1.achv_rwd_type, t1.achv_rwd_id,t1.achv_rwd_sub_id) as rwd_name,
						IFNULL(t2.achv_complete_flag,2) as achv_complete_flag, 
						IFNULL(t2.rwd_rcv_flag,2) as rwd_rcv_flag, 
						IFNULL(t2.achv_cnt,0) as achv_cnt,
						DATE_FORMAT(t2.achv_complete_dt, '%H:%i:%s') as achv_complete_dt, 
						DATE_FORMAT(t2.rwd_rcv_dt, '%H:%i:%s') as rwd_rcv_dt, 
						t2.achv_upd_dt,
                        case when t2.achv_complete_flag=1 and t2.rwd_rcv_flag=2 then 0 else 1 end as sort
				  from MST_ACHIEVEMENT t1 left outer join USER_ACHIEVEMENT t2
					on t1.achv_type = t2.achv_type and t1.achv_id = t2.achv_id and t2.user_account = $V_USER_ACCOUNT						
				 where t1.achv_type=$V_ACHV_TYPE 						 
				   and DATE_FORMAT(achv_apply_fr_dt,'%Y-%m-%d %H') <= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
				   and DATE_FORMAT(achv_apply_to_dt,'%Y-%m-%d %H') >= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
				order by sort, achv_title;
			ELSE
				select 	t1.achv_type, t1.achv_id, 
						concat(t1.achv_title ,'(', IFNULL(t2.achv_cnt,0), '/' , t1.achv_complete_cnt ,')') as achv_title, 
						t1.achv_content, t1.achv_complete_cnt, t1.achv_rwd_type, t1.achv_rwd_id, t1.achv_rwd_sub_id, 
						f_getRwdName (t1.achv_rwd_type, t1.achv_rwd_id,t1.achv_rwd_sub_id) as rwd_name,
						IFNULL(t2.achv_complete_flag,2) as achv_complete_flag, 
						IFNULL(t2.rwd_rcv_flag,2) as rwd_rcv_flag, 
						IFNULL(t2.achv_cnt,0) as achv_cnt,
						DATE_FORMAT(t2.achv_complete_dt, '%H:%i:%s') as achv_complete_dt, 
						DATE_FORMAT(t2.rwd_rcv_dt, '%H:%i:%s') as rwd_rcv_dt, 
						t2.achv_upd_dt	,
                        case when t2.achv_complete_flag=1 and t2.rwd_rcv_flag=2 then 0 else 1 end as sort
				from MST_ACHIEVEMENT t1 left outer join USER_ACHIEVEMENT t2
				  on t1.achv_type = t2.achv_type and t1.achv_id = t2.achv_id and t2.user_account = $V_USER_ACCOUNT
				 and DATE_FORMAT(achv_apply_fr_dt,'%Y-%m-%d %H') <= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
				 and DATE_FORMAT(achv_apply_to_dt,'%Y-%m-%d %H') >= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
			   where t1.achv_type=$V_ACHV_TYPE and t1.achv_id= $V_ACHV_ID
				 and DATE_FORMAT(achv_apply_fr_dt,'%Y-%m-%d %H') <= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
				 and DATE_FORMAT(achv_apply_to_dt,'%Y-%m-%d %H') >= DATE_FORMAT(NOW(),'%Y-%m-%d %H')
				order by sort, achv_title;
			END IF;			 
		END IF;
	END	IF; /* end (job_type=1) */		
END