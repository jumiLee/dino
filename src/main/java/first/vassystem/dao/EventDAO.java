package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;

@Repository("EventDAO")
public class EventDAO extends AbstractDAO {

	public ParamVO updateEventPayment(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("event.updateEventPayment", paramVO); 
	}
	
	public ParamVO updateTimeEvent(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("event.updateTimeEvent", paramVO); 
	}
}