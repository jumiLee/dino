package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.DrawList;
import first.vassystem.dto.UserDetail;

//T300
public class DrawMgmtPacket extends HeaderPacket {	
	
	public UserDetail userDetail;	//user detail info 	
	
	public List<DrawList> drawList;	
	
	public int result;
}