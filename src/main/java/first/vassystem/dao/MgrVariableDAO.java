package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;

@Repository("MgrVariableDAO")
public class MgrVariableDAO extends AbstractDAO {

	public int selectVariableValue(ParamVO paramVO) throws Exception{ 
		return (int)selectOne("mgrVariable.selectVariableValue", paramVO); 
	}
}