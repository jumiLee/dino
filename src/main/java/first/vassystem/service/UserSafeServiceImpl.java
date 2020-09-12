package first.vassystem.service;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.dao.UserSafeDAO;
import first.vassystem.dto.UserSafe;
import first.vassystem.packet.UserSafePacket;


@Service 
public class UserSafeServiceImpl implements UserSafeService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="UserSafeDAO") 
	private UserSafeDAO userSafeDAO; 
	
	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
		
	/**
	 * Get user safe info
	 */
	@Override
	public UserSafePacket getUserSafeInfo(int user_account) throws Exception {

		UserSafe userSafe = new UserSafe();
		UserSafePacket userSafePacket = new UserSafePacket();
		
		userSafe = userSafeDAO.selectUserSafeInfo(user_account);
		
		if (userSafe != null) {
			userSafePacket.userSafe = userSafe;
		}
		userSafePacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		userSafePacket.setHeader(user_account);		
		
		return userSafePacket;
	}
	
	/**
	 * update user safe
	 */
	@Override
	public UserSafePacket mgmtUserSafe(int user_account, int safe_job_type, int money) throws Exception {
		
		UserSafePacket userSafePacket = new UserSafePacket();
		int resultCd = 0;
		String resultMsg = "";
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(safe_job_type);
		vo.setInParam02(user_account);
		vo.setInParam03(money);
		
		//call procedure
		userSafeDAO.mgmtUserSafe(vo);
		
		//get procedure result
		resultCd = vo.getOutParam01();
		
		//set return message
		switch(resultCd) {
		case -11:
			resultMsg = "입금액 > 보유액 ";
			break;
		case -12:
			resultMsg = "입금최대치 초과";
			break;
		case -13:
			resultMsg = "출금액 > 금고보유액";
			break;
		}
		
		userSafePacket.userSafe = userSafeDAO.selectUserSafeInfo(user_account);
		userSafePacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		userSafePacket.setHeader(user_account,resultCd,resultMsg);		
		
		return userSafePacket;
	}
}
