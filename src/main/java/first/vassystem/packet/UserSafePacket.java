package first.vassystem.packet;

import first.vassystem.dto.UserDetail;
import first.vassystem.dto.UserSafe;

//T400
public class UserSafePacket extends HeaderPacket {
	
	public UserDetail userDetail;	//user detail info 	
	
	public UserSafe userSafe;
}