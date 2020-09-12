package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.UserNotice;
import first.vassystem.dto.UserScore;
import first.vassystem.packet.UserAPPacket;
import first.vassystem.dto.UserDetail;

@Repository("UserInfoDAO")
public class UserInfoDAO extends AbstractDAO {

	public UserDetail selectUserDetail(int user_account) { 
		return (UserDetail) selectOne("userMain.selectUserDetail", user_account); 
	}
	
	public UserNotice selectUserNotice(int user_account) throws Exception{ 
		return (UserNotice) selectOne("userMain.selectUserNotice", user_account); 
	}
	
	public int selectUserAttend(int user_account) throws Exception{ 
		return (Integer) selectOne("userMain.selectUserAttend", user_account); 
	}
	
	public UserScore selectUserScore(int user_account) throws Exception{ 
		return (UserScore) selectOne("userMain.selectUserScore", user_account); 
	}
	
	public int updatSid(ParamVO paramVO) { 
		return (Integer) update("userMain.updateSid", paramVO); 
	}
	
	public int selectUserBySid(ParamVO paramVO) { 
		return (Integer) selectOne("userMain.selectUserBySid", paramVO); 
	}
	
	// charge free gold to user
	public UserAPPacket chargeUserGold(int user_account) { 
		return (UserAPPacket) selectOne("userMain.chargeUserGold", user_account); 
	}
}