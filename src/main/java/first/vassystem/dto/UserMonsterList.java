package first.vassystem.dto;

import java.sql.Date;

public class UserMonsterList extends Monster{
	
	public int userMonSn;		//사용자 공룡 일련번호
	public int monLevel;		//사용자 공룡 레벨
	public int monExp;			//사용자 공룡 경험치
	public int needExp;			//레벨업을 위한 Max 경험치
	public int monColorType;	//적용색상타입
	public int merchantId; 		//offline zone id
	public String merchantNm;	//offline zone name
	public Date createDate;		//획득일자 
	public int checkFlag;		//획득여부(1:획득 o, 2:획득x)
}