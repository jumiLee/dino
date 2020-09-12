package first.vassystem.service;

import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.UserItemDAO;

import first.vassystem.dto.UserItemList;
import first.vassystem.packet.UserItemListPacket;

@Service 
public class UserItemServiceImpl implements UserItemService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="UserItemDAO") 
	private UserItemDAO userItemDAO; 
	
	/**
	 * User Item List
	 */
	@Override
	public UserItemListPacket getUserItemList(int job_type_cd, int user_account) throws Exception {
		
		UserItemListPacket userItemListPacket = new UserItemListPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(job_type_cd);
		vo.setInParam02(user_account);
		
		List<UserItemList> userItemList = userItemDAO.selectUserItemList(vo);
		
		if(userItemList.size() ==0) {
			resultCd = 0;
			resultMsg = "No Item!";
		}else {
			userItemListPacket.userItemList =userItemList;
		}
		
		userItemListPacket.setHeader(user_account,resultCd,resultMsg);
		
		return userItemListPacket;
	}
	
	/**
	 * 기간제 아이템 업데이트
	 */
	@Override
	public int updateUserPeriodItem(int user_account, UserItemList userItemt) throws Exception {
		
		int resultCd = 0;
		
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(user_account);
		vo.setInParam02(userItemt.itemUniqueId);
		vo.setInParam03(userItemt.itemId);
		
		userItemDAO.updateUserPeriodItem(vo);
		resultCd = vo.getOutParam01();
		
		return resultCd;
	}
}