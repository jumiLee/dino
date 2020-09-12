package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.InboxList;

//T200
public class InboxPacket extends HeaderPacket {
	
	public List<InboxList> inboxList;	
	//결과코드 - 0:성공 , -1:우편함 데이터 없음.
}