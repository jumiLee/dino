package first.vassystem.service;

import first.vassystem.packet.ItemListPacket;
import first.vassystem.packet.ItemMgmtPacket;
import first.vassystem.packet.ShopListPacket;

public interface ShopService {

	/* 유료상점조회  */
	ShopListPacket getShopList(int device_type,int payment_type) throws Exception;
	
	/* 카테고리별 상점조회   */
	ItemListPacket getShopListByCategory(int shop_category) throws Exception;
	
	/* 아이템 구매   */
	ItemMgmtPacket buyItem(int user_account, int item_id, int item_cnt) throws Exception;
	
	/* 아이템 사용   */
	ItemMgmtPacket useItem(int user_account, int item_unique_id, int item_cnt) throws Exception;
}