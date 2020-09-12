package first.vassystem.dao;

import java.util.List;


import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.AttendList;

@Repository("AttendDAO")
public class AttendDAO extends AbstractDAO {

	@SuppressWarnings("unchecked") 
	public List<AttendList> selectAttendList(int user_account) throws Exception{ 
		return (List<AttendList>)selectList("attend.selectAttendList", user_account); 
	}
	
	public ParamVO attendGetReward(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("attend.mgmtAttend", paramVO); 
	}
}