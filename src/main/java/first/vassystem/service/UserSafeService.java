package first.vassystem.service;

import first.vassystem.packet.UserSafePacket;

public interface UserSafeService {

	/* Get user safe info  */
	UserSafePacket getUserSafeInfo(int user_account) throws Exception;
	
	/* update user safe */
	UserSafePacket mgmtUserSafe(int user_account, int safe_job_type, int money) throws Exception;
}