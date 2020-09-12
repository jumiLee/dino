CREATE PROCEDURE `Log_BaseLog`( 
	$V_ID           INT,  /* 작업주체아이디 (계정아이디, 캐릭터아이디디 등) */
    $V_TARGETID     INT,  /* 작업대상아이디 (길드아이디 등)*/
    $V_JOBCODE1     INT,  /* 작업구분코드*/
    $V_JOBCODE2     INT,  /* 작업상세1*/
    $V_JOBCODE3     INT,  /* 작업상세2*/
    $V_CONTENT1     INT,  /* 내용1 (주로 수량, 금액, 레벨이 들어감)*/
    $V_CONTENT2     BIGINT,  /* 내용2 (ITEMUNIQUEID 값이 들어감)*/
    $V_CONTENT3     INT,  /* 내용3*/
    $V_CONTENT4     INT,  /* 내용4*/
    $V_CONTENT5     INT   /* 내용5  */
)
BEGIN

	DECLARE $V_ERR_CODE INT default 0; 
    DECLARE $V_SERVER INT default 1;
    DECLARE $V_CHANNEL INT default 1;
  
  /* 1. 로그 DB에 해당 로그데이터 추가  Process
	INSERT INTO nb_gamelog.tbl_log_all (IssueDate, Server, Channel, ID, TargetID, JobCode1, JobCode2, JobCode3, content1, content2, content3, content4, content5)
    VALUES (NOW(), $V_SERVER, $V_CHANNEL, $V_ID, $V_TARGETID, $V_JOBCODE1, $V_JOBCODE2,$V_JOBCODE3, $V_CONTENT1,$V_CONTENT2,$V_CONTENT3,$V_CONTENT4,$V_CONTENT5);
    */
    INSERT INTO tbl_log_all (IssueDate, Server, Channel, ID, TargetID, JobCode1, JobCode2, JobCode3, content1, content2, content3, content4, content5)
    VALUES (NOW(), $V_SERVER, $V_CHANNEL, $V_ID, $V_TARGETID, $V_JOBCODE1, $V_JOBCODE2,$V_JOBCODE3, $V_CONTENT1,$V_CONTENT2,$V_CONTENT3,$V_CONTENT4,$V_CONTENT5);
END