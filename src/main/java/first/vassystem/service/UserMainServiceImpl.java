package first.vassystem.service;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.dao.UserItemDAO;
import first.vassystem.dao.UserMonsterDAO;
import first.vassystem.packet.UserDetailPacket;
import first.vassystem.packet.UserMainPacket;


@Service 
public class UserMainServiceImpl implements UserMainService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	@Resource(name="UserItemDAO") 
	private UserItemDAO userItemDAO; 
	
	@Resource(name="UserMonsterDAO") 
	private UserMonsterDAO userMonsterDAO;	
	
	/**
	 * main page
	 */
	@Override
	public UserMainPacket getUserMain(int user_account) throws Exception {
		
		UserMainPacket userMainPacket = new UserMainPacket();
		
		//user Detail info
		userMainPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		
		//new notice
		userMainPacket.userNotice = userInfoDAO.selectUserNotice(user_account);	
			
		//user monster info
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(1);
		vo.setInParam02(user_account);
		
		userMainPacket.userMonsterList = userMonsterDAO.selectUserMonsterList(vo);
								
		userMainPacket.setHeader(user_account);
		
		return userMainPacket;
	}
	
	/**
	 * user detail page 
	 */
	@Override
	public UserDetailPacket getUserDetail(int user_account) throws Exception {
		int resultCd = 0;
		String resultMsg = "";
		
		UserDetailPacket userDetailPacket = new UserDetailPacket();
				
		userDetailPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		userDetailPacket.setHeader(user_account, resultCd, resultMsg);
		
		return userDetailPacket;
	}
}
