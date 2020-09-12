package first.vassystem.dao;

import java.util.List;


import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.ItemList;
import first.vassystem.dto.ShopList;

@Repository("ShopDAO")
public class ShopDAO extends AbstractDAO {

	@SuppressWarnings("unchecked") 
	public List<ShopList> selectShopList(ParamVO paramVO) throws Exception{ 
		return (List<ShopList>)selectList("shop.selectShopList",paramVO); 
	}
	
	@SuppressWarnings("unchecked")
	public List<ItemList> selectItemListByCategory(int shop_category) throws Exception{ 
		return (List<ItemList>)selectList("shop.selectItemListByCategory", shop_category); 
	}
	
	public ParamVO buyItem(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("shop.mgmtItem", paramVO); 
	}
	
	public ParamVO useItem(ParamVO paramVO) throws Exception{ 
		return (ParamVO) selectOne("shop.useItem", paramVO); 
	}
}