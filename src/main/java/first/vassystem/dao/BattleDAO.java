package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;

@Repository("BattleDAO")
public class BattleDAO extends AbstractDAO {
	
	public ParamVO mgmtBattle(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("battle.mgmtBattleEnd", paramVO); 
	}
}