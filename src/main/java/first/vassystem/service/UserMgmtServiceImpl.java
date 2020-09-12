package first.vassystem.service;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.UserDetailMgmtDAO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.packet.UserAPPacket;
import first.vassystem.packet.UserMgmtResultPacket;


@Service 
public class UserMgmtServiceImpl implements UserMgmtService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	@Resource(name="UserDetailMgmtDAO") 
	private UserDetailMgmtDAO userDetailMgmtDAO; 
	/**
	 * free charge user safe 
	 */
	@Override
	public UserAPPacket freeChargeUserGold(int user_account) throws Exception {
		
		UserAPPacket userAPPacket = new UserAPPacket();
		int resultCd = 0;
		
		//call procedure
		userAPPacket = userInfoDAO.chargeUserGold(user_account);
		if(userAPPacket !=null) resultCd = userAPPacket.resultCd;
		
		//set return message
		switch(resultCd) {
		case -11:
			userAPPacket.resultMsg = "보유골드 있음";
			break;
		case -12:
			userAPPacket.resultMsg = "충전가능회수 모두 소진";
			break;
		}
				
		return userAPPacket;
	}
	
	/* AI update Gold */
	@Override 
	public UserMgmtResultPacket AIUpdateGold(int user_account, int change_amt) throws Exception{
		UserMgmtResultPacket userMgmtResultPacket = new UserMgmtResultPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		ParamVO param = new ParamVO(); 
		param.setInParam01(1);
		param.setInParam02(user_account);
		param.setInParam03(1);
		param.setInParam04(change_amt);
		
		userDetailMgmtDAO.mgmtUserProperty(param);
		resultCd= param.getOutParam01();	

		//set return message
		switch(resultCd) {
			case -11:
				resultMsg = "No such account";
				break;
			case -12:
				resultMsg = "It's not AI";
				break;
		}
		userMgmtResultPacket.setHeader(user_account,resultCd,resultMsg);		
		
		return userMgmtResultPacket;
	}
}
