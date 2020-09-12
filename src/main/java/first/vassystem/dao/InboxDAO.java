package first.vassystem.dao;

import java.util.List;


import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.InboxList;

@Repository("InboxDAO")
public class InboxDAO extends AbstractDAO {

	@SuppressWarnings("unchecked") 
	public List<InboxList> selectInboxList(int user_account) throws Exception{ 
		return (List<InboxList>)selectList("inbox.selectInboxList", user_account); 
	}
	
	public ParamVO mgmtInbox(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("inbox.mgmtInbox", paramVO); 
	}
}