package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.AttendList;

//T100
public class AttendListPacket extends HeaderPacket {
	
	public List<AttendList> attendList;	
}