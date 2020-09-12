package first.vassystem.service;

import first.vassystem.packet.ItemListWithUserPacket;
import first.vassystem.packet.ItemMgmtPacket;
import first.vassystem.packet.ItemPacket;

public interface ShopService {

	/* Item List */
	ItemListWithUserPacket getItemList(int user_account) throws Exception;
	
	/* Buy Item   */
	ItemPacket buyItem(int user_account, int item_id, int item_cnt) throws Exception;
	
	/* Use Item   */
	ItemMgmtPacket useItem(int user_account, int item_unique_id, int item_cnt) throws Exception;
}