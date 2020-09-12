package first.vassystem.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.RankList;

@Repository("RankDAO")
public class RankDAO extends AbstractDAO {

	@SuppressWarnings("unchecked")
	public List<RankList> selecRankList(ParamVO paramVO) throws Exception{ 
		return (List<RankList>)selectList("rank.selecRankList", paramVO); 
	}
	
	public RankList selecRank(ParamVO paramVO) throws Exception{ 
		return (RankList)selectOne("rank.selecRankList", paramVO); 
	}
}