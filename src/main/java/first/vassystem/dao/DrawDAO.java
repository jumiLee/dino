package first.vassystem.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.DrawShopList;
import first.vassystem.packet.DrawMgmtPacket;

@Repository("DrawDAO")
public class DrawDAO extends AbstractDAO {

	public DrawMgmtPacket mgmtDraw(ParamVO paramVO) throws Exception{ 
		return (DrawMgmtPacket)selectOne("draw.mgmtDraw", paramVO);
	}
	
	@SuppressWarnings("unchecked")
	public List<DrawShopList> getDrawList(ParamVO paramVO) throws Exception{ 
		return (List<DrawShopList>)selectList("draw.selectDrawList", paramVO);
	}
}