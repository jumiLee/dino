package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.InboxList;

//T200
public class InboxPacket extends HeaderPacket {
	
	public List<InboxList> inboxList;	
	//����ڵ� - 0:���� , -1:������ ������ ����.
}