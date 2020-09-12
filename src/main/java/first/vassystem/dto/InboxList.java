package first.vassystem.dto;

public class InboxList {
	public int rcvNo;
	public int senderAccount;	//보낸사람계정 (관리자 보상등에 활용하기 위해)
	public int rwdType;			//보상타입
	public int rwdId;			//보상아이디
	public String rwdName;		//보상명
	public int remainDay;		//남은기간
}