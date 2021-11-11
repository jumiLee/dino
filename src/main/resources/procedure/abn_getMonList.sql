CREATE DEFINER=`edenweb`@`%` PROCEDURE `abn_getMonList`(
	$V_JOB_CODE		INT,	/*1:나의 몬스터 리스트, 2:도감조회 */
	$V_USER_ACCOUNT INT,	/* 나의계정 */
    $V_USER_MON_SN	INT 	/* monster SN */
)
BEGIN

	IF $V_JOB_CODE = 1 THEN
		if ($V_USER_MON_SN = 0) THEN 
			SELECT 	t2.mon_id as mon_id
					,t2.mon_nm as mon_nm
					,t2.mon_type as mon_type
					,t2.mon_max_lv as mon_max_lv
                    ,t2.mon_desc as mon_desc
					,t1.user_mon_sn as user_mon_sn
					,t1.mon_level as mon_level
					,t1.mon_exp as mon_exp
					,t1.mon_color_type as mon_color_type    
					,t1.create_dt as create_dt
					,t3.mct_id as mct_id
					,t3.mct_nm as mct_nm
                    ,f_getNeedExp(t1.user_account, t1.mon_id, t1.user_mon_sn) as mon_need_exp
			  FROM 	user_monster t1, mst_monster t2, mst_merchant t3
			 WHERE 	t1.mon_id = t2.mon_id
			   and 	t1.mct_id = t3.mct_id
			   and 	t1.user_account = $V_USER_ACCOUNT;		
		else
			SELECT 	t2.mon_id as mon_id
					,t2.mon_nm as mon_nm
					,t2.mon_type as mon_type
					,t2.mon_max_lv as mon_max_lv
                    ,t2.mon_desc as mon_desc
					,t1.user_mon_sn as user_mon_sn
					,t1.mon_level as mon_level
					,t1.mon_exp as mon_exp
					,t1.mon_color_type as mon_color_type    
					,t1.create_dt as create_dt
					,t3.mct_id as mct_id
					,t3.mct_nm as mct_nm
                    ,f_getNeedExp(t1.user_account, t1.mon_id, t1.user_mon_sn) as mon_need_exp
			  FROM 	user_monster t1, mst_monster t2, mst_merchant t3
			 WHERE 	t1.mon_id = t2.mon_id
			   and 	t1.mct_id = t3.mct_id
			   and 	t1.user_account = $V_USER_ACCOUNT
               and 	t1.user_mon_sn = $V_USER_MON_SN;
        end if;
	END IF;
    
    IF $V_JOB_CODE = 2 THEN
		select 	distinct t1.mon_id as mon_id
				,t1.mon_type as mon_type
				,t2.mon_level as mon_level
				,t1.mon_nm as mon_nm
				,t1.mon_desc as mon_desc
				,case when t2.mon_id is null then 2 else 1 end as check_flag
		  from mst_monster t1 
          left join user_monster t2 on t1.mon_id = t2.mon_id 
          and t2.user_account = $V_USER_ACCOUNT
		order by t1.mon_id;
        
        -- 도감 조회 후, monster new sign release
        Call abn_MgmtUserNewNotice (1,$V_USER_ACCOUNT, 4, 2);
    END IF;
END