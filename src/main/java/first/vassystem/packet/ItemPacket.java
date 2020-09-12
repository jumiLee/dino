package first.vassystem.packet;

import first.vassystem.dto.ItemList;

public class ItemPacket extends HeaderPacket {
	
	public ItemList itemList;	
	
	public int itemUniqueID;
}