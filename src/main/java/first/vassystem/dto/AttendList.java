package first.vassystem.dto;

public class AttendList {
	public int dayNo;		//출석일수
	public int rwdType;		//보상타입
	public int rwdId;		//보상아이디
	public int rwdRcvFlag;	//보상수령여부
	public String rwdName;	//보상명
	public int todayNo;		//오늘여부 (0:false, 1:true)
}