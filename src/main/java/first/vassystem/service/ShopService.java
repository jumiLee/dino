package first.vassystem.service;

import first.vassystem.packet.ItemListPacket;
import first.vassystem.packet.ItemListWithUserPacket;
import first.vassystem.packet.ItemMgmtPacket;
import first.vassystem.packet.ShopListPacket;

public interface ShopService {

	/* Item List */
	ItemListWithUserPacket getItemList(int user_account) throws Exception;
	
	/* ���������ȸ  */
	ShopListPacket getShopList(int device_type,int payment_type) throws Exception;
	
	/* ī�װ��� ������ȸ   */
	ItemListPacket getShopListByCategory(int shop_category) throws Exception;
	
	/* ������ ����   */
	ItemMgmtPacket buyItem(int user_account, int item_id, int item_cnt) throws Exception;
	
	/* ������ ���   */
	ItemMgmtPacket useItem(int user_account, int item_unique_id, int item_cnt) throws Exception;
}