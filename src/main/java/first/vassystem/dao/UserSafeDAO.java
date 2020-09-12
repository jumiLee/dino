package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.UserSafe;

@Repository("UserSafeDAO")
public class UserSafeDAO extends AbstractDAO {

	public UserSafe selectUserSafeInfo(int user_account) throws Exception{ 
		return (UserSafe)selectOne("userSafe.selectUserSafe", user_account); 
	}
	
	public UserSafe mgmtUserSafe(ParamVO paramVO) throws Exception{ 
		return (UserSafe) selectOne("userSafe.mgmtUserSafe", paramVO); 
	}
}