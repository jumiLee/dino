package first.vassystem.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.UserMonsterList;

@Repository("UserMonsterDAO")
public class UserMonsterDAO extends AbstractDAO {

	public UserMonsterList selectUserMonster(ParamVO paramVO) { 
		return (UserMonsterList) selectOne("monster.selectUserMonsterList", paramVO); 
	}
	
	@SuppressWarnings("unchecked")
	public List<UserMonsterList> selectUserMonsterList(ParamVO paramVO) throws Exception{ 
		return (List<UserMonsterList>)selectList("monster.selectUserMonsterList", paramVO); 
	}
	
	public ParamVO addMonster(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("monster.addUserMonster", paramVO); 
	}
}