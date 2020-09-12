package first.vassystem.dto;

import java.util.Date;

public class AchvList {
	public int achvType;			//업적타입
	public int achvId;				//업적아이디
	public String achvTitle;		//업적 제목
	public String achvContent;		//업적내용
	public int achvCompleteCnt;		//달성회수
	public int achvRwdType;			//보상타입
	public int achvRwdId;			//보상아이디
	public int achvRwdSubId;		//보상서브아이디
	public String rwdName;			//보상명
	public int achvCompleteFlag;	//달성여부(1:달성, 2:미달성)
	public int rwdRcvFlag;			//보상수령여부(1:수령, 2:미수령)
	public int achvCnt;				//달성회수
	public Date achvCompleteDt;		//달성일시
	public Date rwdRcvDt;			//보상수령일시
}