package first.vassystem.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.UserItemList;

@Repository("UserItemDAO")
public class UserItemDAO extends AbstractDAO {

	@SuppressWarnings("unchecked") 
	public List<UserItemList> selectUserItemList(ParamVO paramVO) throws Exception{ 
		return (List<UserItemList>)selectList("item.selectUserItemList", paramVO); 
	}
	
	public ParamVO updateUserPeriodItem(ParamVO paramVO) throws Exception{ 
		return (ParamVO)selectOne("item.updateUserPeriodItem", paramVO); 
	}
}