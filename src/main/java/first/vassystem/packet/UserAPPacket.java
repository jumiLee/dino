package first.vassystem.packet;

import first.vassystem.dto.UserAP;

//T400
public class UserAPPacket extends HeaderPacket {
	
	/* resultCd
	 	-11: 보유 골드 있음
	 	-12: 충전가능회수 없음
	*/
	public UserAP userAP;	//충전가능회수정보
	public int amt;			//충전금액
	public int safeMoney;  	//금고머니
}