CREATE PROCEDURE `Log_BaseLog`( 
	$V_ID           INT,  /* �۾���ü���̵� (�������̵�, ĳ���;��̵�� ��) */
    $V_TARGETID     INT,  /* �۾������̵� (�����̵� ��)*/
    $V_JOBCODE1     INT,  /* �۾������ڵ�*/
    $V_JOBCODE2     INT,  /* �۾���1*/
    $V_JOBCODE3     INT,  /* �۾���2*/
    $V_CONTENT1     INT,  /* ����1 (�ַ� ����, �ݾ�, ������ ��)*/
    $V_CONTENT2     BIGINT,  /* ����2 (ITEMUNIQUEID ���� ��)*/
    $V_CONTENT3     INT,  /* ����3*/
    $V_CONTENT4     INT,  /* ����4*/
    $V_CONTENT5     INT   /* ����5  */
)
BEGIN

	DECLARE $V_ERR_CODE INT default 0; 
    DECLARE $V_SERVER INT default 1;
    DECLARE $V_CHANNEL INT default 1;
  
  /* 1. �α� DB�� �ش� �α׵����� �߰�  Process
	INSERT INTO nb_gamelog.tbl_log_all (IssueDate, Server, Channel, ID, TargetID, JobCode1, JobCode2, JobCode3, content1, content2, content3, content4, content5)
    VALUES (NOW(), $V_SERVER, $V_CHANNEL, $V_ID, $V_TARGETID, $V_JOBCODE1, $V_JOBCODE2,$V_JOBCODE3, $V_CONTENT1,$V_CONTENT2,$V_CONTENT3,$V_CONTENT4,$V_CONTENT5);
    */
    INSERT INTO tbl_log_all (IssueDate, Server, Channel, ID, TargetID, JobCode1, JobCode2, JobCode3, content1, content2, content3, content4, content5)
    VALUES (NOW(), $V_SERVER, $V_CHANNEL, $V_ID, $V_TARGETID, $V_JOBCODE1, $V_JOBCODE2,$V_JOBCODE3, $V_CONTENT1,$V_CONTENT2,$V_CONTENT3,$V_CONTENT4,$V_CONTENT5);
END