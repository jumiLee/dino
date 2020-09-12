package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.ItemList;

//T502
public class ItemListPacket extends HeaderPacket {
	
	public List<ItemList> itemList;	
}