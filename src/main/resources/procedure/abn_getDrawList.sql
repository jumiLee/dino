CREATE PROCEDURE `abn_getDrawList`(
	$V_JOB_CODE			INT,	-- 1:�Ϲ���ȸ
    $V_DRAW_TYPE_CD 	INT,	-- ����Ÿ���ڵ� 
    $V_DRAW_ID			INT		-- �������̵�
	  
)
BEGIN
	IF($V_JOB_CODE = 1) THEN
		IF($V_DRAW_ID = 0) THEN
			select 	t1.draw_id, t1.draw_type_cd, t1.draw_nm, t1.unit_cd, t1.draw_price, t1.dis_price, t1.draw_desc, t1.img_no
			  from 	MST_DRAW t1
			 where 	DATE_FORMAT(now(), '%Y%m%d') between DATE_FORMAT(start_dt, '%Y%m%d') and DATE_FORMAT(end_dt, '%Y%m%d') /*  ���� �� ������ ���� ����    */
			   and 	t1.draw_type_cd= $V_DRAW_TYPE_CD               
			order by view_order;
		ELSE 
			select 	t1.draw_id, t1.draw_type_cd, t1.draw_nm, t1.unit_cd, t1.draw_price, t1.dis_price, t1.draw_desc, t1.img_no
			  from 	MST_DRAW t1
			 where 	DATE_FORMAT(now(), '%Y%m%d') between DATE_FORMAT(start_dt, '%Y%m%d') and DATE_FORMAT(end_dt, '%Y%m%d') /*  ���� �� ������ ���� ����    */
			   and 	t1.draw_type_cd= $V_DRAW_TYPE_CD
               and	t1.draw_id = $V_DRAW_ID
			order by view_order;
        END IF;
	END IF;
END