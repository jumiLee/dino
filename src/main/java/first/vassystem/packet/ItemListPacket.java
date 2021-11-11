package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.ItemList;

public class ItemListPacket extends HeaderPacket {
	
	public List<ItemList> itemList;	
	
	public int itemUniqueID;
}