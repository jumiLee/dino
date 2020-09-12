package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.vassystem.dto.UserAP;

@Repository("UserAPDAO")
public class UserAPDAO extends AbstractDAO {

	public UserAP selectUserAP(int user_account) throws Exception{ 
		return (UserAP)selectOne("userAP.selectUserAP", user_account); 
	}
}