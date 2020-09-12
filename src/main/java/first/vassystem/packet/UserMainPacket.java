package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.UserDetail;
import first.vassystem.dto.UserMonsterList;
import first.vassystem.dto.UserNotice;

//T000
public class UserMainPacket extends HeaderPacket{
	
	public UserDetail userDetail;	//user detail info 
		
	public UserNotice userNotice;	//new flag
	
	public List<UserMonsterList> userMonsterList; // my dinosaurs info
}