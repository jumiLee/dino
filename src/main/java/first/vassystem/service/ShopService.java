package first.vassystem.service;

import first.vassystem.packet.ItemListWithUserPacket;
import first.vassystem.packet.ItemPacket;
import first.vassystem.packet.MonsterPacket;

public interface ShopService {

	/* Item List */
	ItemListWithUserPacket getItemList(int user_account) throws Exception;
	
	/* Buy Item   */
	ItemPacket buyItem(int user_account, int item_id, int item_cnt) throws Exception;
	
	/* Use Item   */
	MonsterPacket useItem(int user_account, int mon_id, int user_mon_sn, int item_unique_id) throws Exception;
}