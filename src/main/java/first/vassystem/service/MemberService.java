package first.vassystem.service;

import first.common.util.UserLevelType;
import first.vassystem.packet.MemberInfoPacket;

public interface MemberService {
	
	/* login check */
	MemberInfoPacket loginCheck(String email, String pwd) throws Exception;
	
	/* register */
	MemberInfoPacket register(UserLevelType userLevel, String email, String pwd, String nickname) throws Exception;
	
	/* session check */
	int checkSession(int user_account, String sid);
}