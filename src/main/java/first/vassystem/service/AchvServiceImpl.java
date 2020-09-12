package first.vassystem.service;

import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.AchvDAO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.dto.AchvList;
import first.vassystem.packet.AchvListPacket;
import first.vassystem.packet.AchvMgmtPacket;

@Service 
public class AchvServiceImpl implements AchvService {

	Logger log = Logger.getLogger(this.getClass());
	
	@Resource(name="AchvDAO") 
	private AchvDAO achvDAO; 
	
	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	/**
	 * 업적조회
	 */
	@Override
	public AchvListPacket getAchvList(int job_type, int user_account) throws Exception {
		
		AchvListPacket achvListPacket = new AchvListPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(user_account);
		vo.setInParam02(job_type);
		
		//call procedure
		List<AchvList> achvList = achvDAO.getAchvList(vo);
		
		if(achvList.size() ==0 ) {			
			resultCd = -1;
			resultMsg = "No achv items";			
		}else {
			achvListPacket.achvList = achvList;
		}
		achvListPacket.setHeader(user_account, resultCd, resultMsg);
		
		return achvListPacket;
	}
	
	/* 업적보상받기  */
	@Override
	public AchvMgmtPacket mgmtAchvRwd(int job_type, int user_account,int achv_type, int achv_id) throws Exception {
		AchvMgmtPacket achvListPacket = new AchvMgmtPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(job_type);
		vo.setInParam02(user_account);
		vo.setInParam03(achv_type);
		vo.setInParam04(achv_id);
				
		//call procedure
		achvDAO.mgmtAchvRwd(vo);
		
		//get procedure result
		resultCd  = vo.getOutParam01();
		resultMsg = vo.getOutStrParam01();		
				
		achvListPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		achvListPacket.setHeader(user_account,resultCd,resultMsg);
		
		return achvListPacket;
	}
	
	/* 업적등록*/
	@Override
	public int registerAchv(int job_type, int user_account,int achv_type, int achv_id, int achv_cnt) throws Exception{
		int result=0;
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(job_type);
		vo.setInParam02(user_account);
		vo.setInParam03(achv_type);
		vo.setInParam04(achv_id);
		vo.setInParam05(achv_cnt);
		
		//call procedure
		achvDAO.registerUserAchv(vo);
		
		result = vo.getOutParam01();
		
		return result;
	}
}