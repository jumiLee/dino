package first.vassystem.service;

import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.ShopDAO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.dto.ItemList;
import first.vassystem.dto.ShopList;
import first.vassystem.packet.ItemListPacket;
import first.vassystem.packet.ItemListWithUserPacket;
import first.vassystem.packet.ItemMgmtPacket;
import first.vassystem.packet.ShopListPacket;


@Service 
public class ShopServiceImpl implements ShopService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="ShopDAO") 
	private ShopDAO shopDAO; 
	
	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	private static final int ITEM_BUY = 1;
	
	/* Item List */
	@Override
	public ItemListWithUserPacket getItemList(int user_account) throws Exception {
		
		ItemListWithUserPacket itemListWithUserPacket = new ItemListWithUserPacket();
		
		//Get Item List 
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(1);
		
		List<ItemList> itemList = shopDAO.selectItemList(vo);
		
		if(itemList.size() ==0 ) {			
			itemListWithUserPacket.resultCd = -1;
			itemListWithUserPacket.resultMsg = "No item!";
		}else {
			itemListWithUserPacket.itemList = itemList;
		}
		
		//Get User Detail Info
		itemListWithUserPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		
		return itemListWithUserPacket;
	}
	
	/**
	 * ���������ȸ
	 */
	@Override
	public ShopListPacket getShopList(int device_type,int payment_type) throws Exception {
		
		ShopListPacket shopListPacket = new ShopListPacket();
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(device_type);
		vo.setInParam02(payment_type);
		
		List<ShopList> shopList = shopDAO.selectShopList(vo);
	
		if(shopList.size() ==0 ) {			
			shopListPacket.resultCd = -1;
			shopListPacket.resultMsg = "No shop item!";
		}else {
			shopListPacket.shopList = shopList;
		}
		return shopListPacket;
	}
	
	/* ī�װ��� ������ȸ   */
	@Override
	public ItemListPacket getShopListByCategory(int shop_category) throws Exception {
		
		ItemListPacket itemListPacket = new ItemListPacket();
		
		List<ItemList> itemList = shopDAO.selectItemListByCategory(shop_category);
		
		if(itemList.size() ==0 ) {			
			itemListPacket.resultCd = -1;
			itemListPacket.resultMsg = "No item!";
		}else {
			itemListPacket.itemList = itemList;
		}
		
		return itemListPacket;
	}
	
	/* ������ ����   */
	@Override
	public ItemMgmtPacket buyItem(int user_account, int item_id, int item_cnt) throws Exception {
		
		ItemMgmtPacket itemMgmtPacket = new ItemMgmtPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(ITEM_BUY);	//����
		vo.setInParam02(user_account);
		vo.setInParam03(item_id);
		vo.setInParam04(item_cnt);
		
		shopDAO.buyItem(vo);		
		
		resultCd = vo.getOutParam01();
		resultMsg = vo.getOutStrParam01();
		
		itemMgmtPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		itemMgmtPacket.setHeader(user_account,resultCd,resultMsg);
		
		return itemMgmtPacket;
	}
	
	/* ������ ���   */
	@Override
	public ItemMgmtPacket useItem(int user_account, int item_unique_id, int item_cnt) throws Exception {
		
		ItemMgmtPacket itemMgmtPacket = new ItemMgmtPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(user_account);
		vo.setInParam02(item_unique_id);
		vo.setInParam03(item_cnt);
		
		shopDAO.useItem(vo);		
		
		resultCd = vo.getOutParam01();
		
		switch(resultCd) {
		case -21:
			resultMsg = "Lack of item";
			break;
		case -22:
			resultMsg = "No such item";
			break;
		case -23:
			resultMsg = "expired item";
			break;
		}
		
		itemMgmtPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
		itemMgmtPacket.setHeader(user_account,resultCd,resultMsg);
		
		return itemMgmtPacket;
	}
}
