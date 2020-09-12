package first.vassystem.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.AchvList;

@Repository("AchvDAO")
public class AchvDAO extends AbstractDAO {
	
	@SuppressWarnings("unchecked") 
	public List<AchvList> getAchvList(ParamVO paramVO) throws Exception{ 
		return (List<AchvList>)selectList("achv.getAchvList", paramVO); 
	}
	
	public ParamVO mgmtAchvRwd(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("achv.getAchvRwd", paramVO); 
	}
	
	public ParamVO registerUserAchv(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("achv.registerUserAchv", paramVO); 
	}
}