package first.vassystem.service;

import java.util.Collections;
import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.InboxDAO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.dto.InboxList;
import first.vassystem.packet.InboxMgmtPacket;


@Service 
public class InboxServiceImpl implements InboxService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="InboxDAO") 
	private InboxDAO inboxDAO; 
	
	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	/**
	 * 출석이벤트 리스트 조회 
	 */
	@SuppressWarnings("unchecked")
	@Override
	public List<InboxList> getInboxList(int user_account) throws Exception {
		
		//출석보상리스트 조회
		List<InboxList> inboxList = inboxDAO.selectInboxList(user_account);
	
		if(inboxList == null) {			
			return (List<InboxList>)Collections.EMPTY_LIST;
		}	
		return inboxList;
	}
	
	/**
	 * 출석이벤트 등록 및 보상 업데이트
	 */
	@Override
	public InboxMgmtPacket mgmtInbox(int user_account, int job_type, int rcvNo) throws Exception {
		
		InboxMgmtPacket inboxMgmtPacket = new InboxMgmtPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(job_type);
		vo.setInParam02(user_account);
		vo.setInParam03(rcvNo);
		
		//call procedure
		inboxDAO.mgmtInbox(vo);
		
		//get procedure result
		resultCd = vo.getOutParam01();
		
		//set return message
		switch(resultCd) {
		case -11:
			resultMsg = "Not Exist Message No";
			break;
		case -12:
			resultMsg = "Already Received ";
			break;
		case -13:
			resultMsg = "Draw reward error";
			break;
		case -14:
			resultMsg = "DB Error while updating message status";
			break;
		case -21:
			resultMsg = "Bulk receive handling error";
			break;
		}
		
		inboxMgmtPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		inboxMgmtPacket.setHeader(user_account,resultCd,resultMsg);
	
		return inboxMgmtPacket;
	}
}
