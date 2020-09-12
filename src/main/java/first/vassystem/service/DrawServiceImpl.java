package first.vassystem.service;

import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.DrawDAO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.dto.DrawShopList;
import first.vassystem.packet.DrawListPacket;
import first.vassystem.packet.DrawMgmtPacket;


@Service 
public class DrawServiceImpl implements DrawService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="DrawDAO") 
	private DrawDAO drawDAO; 
	
	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	/**
	 * 뽑기
	 */
	@Override
	public DrawMgmtPacket userDraw(int user_account, int draw_id, int draw_type_cd) throws Exception {
		
		DrawMgmtPacket drawMgmtPacket = new DrawMgmtPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(user_account);
		vo.setInParam02(draw_id);
		vo.setInParam03(draw_type_cd);
		
		//call procedure
		drawMgmtPacket = drawDAO.mgmtDraw(vo);
		resultCd = drawMgmtPacket.result;
		
		//set return message
		switch(resultCd) {
		case -11:
			resultMsg = "Lack of Money";
			break;
		case -12:
			resultMsg = "reward error";
			break;
		case -21:
			resultMsg = "Free Draw isn't possible yet";
			break;
		}		
		drawMgmtPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		drawMgmtPacket.setHeader(user_account,resultCd,resultMsg);
		
		return drawMgmtPacket;
	}

	/**
	 * 뽑기리스트
	 */
	@Override
	public DrawListPacket getDrawList(int job_type_cd, int draw_type_cd, int draw_id) throws Exception{
		
		DrawListPacket drawListPacket = new DrawListPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(job_type_cd);
		vo.setInParam02(draw_type_cd);
		vo.setInParam03(draw_id);
				
		//call procedure
		List<DrawShopList> drawList = drawDAO.getDrawList(vo);
				
		if(drawList.size() ==0) {
			resultCd = -1;
			resultMsg = "No draw List";
		}else {
			drawListPacket.drawList =drawList;
		}
		drawListPacket.setHeader(0,resultCd,resultMsg);
		
		return drawListPacket;		
	}
}