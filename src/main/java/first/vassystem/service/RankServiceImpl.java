package first.vassystem.service;

import java.util.Collections;
import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.RankDAO;
import first.vassystem.dto.RankList;
import first.vassystem.packet.RankPacket;


@Service 
public class RankServiceImpl implements RankService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="RankDAO") 
	private RankDAO rankDAO; 
	
	/**
	 * ·©Å·Á¶È¸
	 */
	@SuppressWarnings("unchecked")
	@Override
	public RankPacket getRank(int user_account, int rank_type) throws Exception {
		
		RankPacket rankPacket = new RankPacket();
		
		//Setting parameters (Ranking)
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(1);
		vo.setInParam02(rank_type);
		vo.setInParam03(user_account);
		
		//call procedure
		List<RankList> rankList = rankDAO.selecRankList(vo);
		
		if(rankList == null) {			
			rankList = (List<RankList>)Collections.EMPTY_LIST;
		}	
		rankPacket.rankList = rankList;
		
		//Setting parameters (My Ranking)
		ParamVO myo = new ParamVO(); 
		myo.setInParam01(3);
		myo.setInParam02(rank_type);
		myo.setInParam03(user_account);
			
		//call procedure
		RankList myRank = rankDAO.selecRank(myo);
		rankPacket.myPoint = myRank.point;
		rankPacket.myRank  = myRank.rank;
		
		return rankPacket;
	}
}
