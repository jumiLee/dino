package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.ItemList;
import first.vassystem.dto.UserDetail;

//T003
public class ItemListWithUserPacket extends HeaderPacket {
	
	public List<ItemList> itemList;	
	
	public UserDetail userDetail;
}