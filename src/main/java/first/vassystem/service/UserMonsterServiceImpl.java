package first.vassystem.service;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.UserMonsterDAO;
import first.vassystem.packet.MonsterBookPacket;
import first.vassystem.packet.MonsterPacket;

@Service 
public class UserMonsterServiceImpl implements UserMonsterService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="UserMonsterDAO") 
	private UserMonsterDAO userMonsterDAO;
	
	private static final int MONSTER_LIST_SEARCH_JOB = 1;
	private static final int MONSTER_BOOK_SEARCH_JOB = 2;
	
	/**
	 * Get Monster Book List
	 */
	@Override
	public MonsterBookPacket getUserMonsterBookList(int user_account) throws Exception {
		
		MonsterBookPacket monsterBookPacket = new MonsterBookPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(MONSTER_BOOK_SEARCH_JOB);
		vo.setInParam02(user_account);
		vo.setInParam03(0);
		
		monsterBookPacket.userMonsterBookList = userMonsterDAO.selectUserMonsterList(vo);		
		monsterBookPacket.setHeader(user_account,resultCd,resultMsg);
		
		return monsterBookPacket;
	}
	
	/**
	 * Add Monster
	 */
	@Override
	public MonsterPacket addMonster(int user_account, int mon_id, int mct_id) throws Exception {
				
		int resultCd = 0;
		int user_mon_sn = 0;
		
	//Add User Monster
		ParamVO paramVO = new ParamVO(); 
		paramVO.setInParam01(user_account);
		paramVO.setInParam02(mon_id);
		paramVO.setInParam03(mct_id);
		
		userMonsterDAO.addMonster(paramVO);
		resultCd = paramVO.getOutParam01();
		user_mon_sn = paramVO.getOutParam02();
				
	//Get Monster Information		
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(MONSTER_LIST_SEARCH_JOB); 
		vo.setInParam02(user_account);
		vo.setInParam03(user_mon_sn);
		
		MonsterPacket monsterPacket = new MonsterPacket();
		monsterPacket.userMonsterList = userMonsterDAO.selectUserMonster(vo);
		monsterPacket.setHeader(user_account, resultCd, "");
				
		return monsterPacket;
	}
}