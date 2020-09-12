package first.vassystem.service;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.BattleDAO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.packet.BattleMgmtPacket;

@Service 
public class BattleServiceImpl implements BattleService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="BattleDAO") 
	private BattleDAO battleDAO; 
	
	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	@Autowired 
	private AchvService achvService;
	
	/**
	 * Update Battle Result
	 */
	@Override
	public BattleMgmtPacket mgmtBattle(int job_type, int user_account, int bat_room_no, int bat_point, int evt_point, int bat_result, int win_type) throws Exception {
		
		BattleMgmtPacket battleMgmtPacket = new BattleMgmtPacket();
		int resultCd = 0;
		String resultMsg = "";
				
		//Setting parameters (Ranking)
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(job_type);
		vo.setInParam02(user_account);
		vo.setInParam03(bat_room_no);
		vo.setInParam04(bat_point);
		vo.setInParam05(evt_point);
		vo.setInParam06(bat_result);
		vo.setInParam07(win_type);
		
		//call procedure
		battleDAO.mgmtBattle(vo);
		
		resultCd = vo.getOutParam01();
		
		//set return message
		switch(resultCd) {
		case -11:
			resultMsg = "Gold update error";
			break;
		case -12:
			resultMsg = "Ranking update error";
			break;
		}
				
		//Register user battle achievement (winÀÎ °æ¿ì¸¸)
		if(battleMgmtPacket.resultCd ==0) {
			applyUserAchv(user_account, win_type, bat_result);		
		}
		
		battleMgmtPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		battleMgmtPacket.setHeader(user_account,resultCd,resultMsg);
		
		return battleMgmtPacket;
	}
	
	private void applyUserAchv(int user_account, int win_type, int bat_result) throws Exception {
		int achv_id = 0;
		int achv_type = 3; //daily achievement
		
		//Âü¿©¿¡ ´ëÇÑ ¾÷Àû µî·Ï
		achvService.registerAchv(1, user_account, achv_type, 2, 1);
		
		//¶¯,±¤¶¯,38¶¯,¾ÏÇà¾î»ç ¾÷Àû µî·Ï 
		if(win_type !=0) {
			switch(win_type) {
			case 1:
				achv_id = 4;	//¶¯
				break;
			case 2:
				achv_id = 5;	//±¤¶¯
				break;
			case 3:
				achv_id = 6;	//38±¤¶¯
				break;
			case 4:
				achv_id = 7;	//¾ÏÇà¾î»ç
				break;
			}
		
			achvService.registerAchv(1, user_account, achv_type , achv_id, 1);
			//38±¤¶¯ ¾÷ÀûÀÎ °æ¿ì, ±¤¶¯ ¾÷Àûµµ °°ÀÌ Ã³¸®
			if(win_type == 3) achvService.registerAchv(1, user_account, achv_type, 5, 1);
		}
		
		//½Â¸®¿¡ ´ëÇÑ ¾÷Àû µî·Ï
		if(bat_result == 1) {
			for(int i=8; i<14 ; i++) {
				achvService.registerAchv(1, user_account, achv_type, i, 1);
			}
		}
	}
}
