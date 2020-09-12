package first.vassystem.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.UserMonsterList;

@Repository("UserMonsterDAO")
public class UserMonsterDAO extends AbstractDAO {

	public UserMonsterList selectUserMonster(int user_account) { 
		return (UserMonsterList) selectOne("monster.selectUserDetail", user_account); 
	}
	
	@SuppressWarnings("unchecked")
	public List<UserMonsterList> selectUserMonsterList(ParamVO paramVO) throws Exception{ 
		return (List<UserMonsterList>)selectList("monster.selectUserMonsterList", paramVO); 
	}
}