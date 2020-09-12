package first.vassystem.service;

import first.vassystem.packet.UserAPPacket;
import first.vassystem.packet.UserMgmtResultPacket;

public interface UserMgmtService {

	/* free charge */
	UserAPPacket freeChargeUserGold(int user_account) throws Exception;
	
	/* AI update Gold */
	UserMgmtResultPacket AIUpdateGold(int user_account, int change_amt) throws Exception;
}