package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;

@Repository("UserDetailMgmtDAO")
public class UserDetailMgmtDAO extends AbstractDAO {

	//Change AI Gold 
	public ParamVO mgmtUserProperty(ParamVO paramVO) { 
		return (ParamVO) selectOne("mgmtUserDetail.mgmtUserProperty", paramVO); 
	}
}