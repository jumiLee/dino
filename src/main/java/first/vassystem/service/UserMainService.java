package first.vassystem.service;

import first.vassystem.packet.UserDetailPacket;
import first.vassystem.packet.UserMainPacket;

public interface UserMainService {

	/* Main Page */
	UserMainPacket getUserMain(int user_account) throws Exception;

	/* Detail Page */
	UserDetailPacket getUserDetail(int user_account) throws Exception;
}