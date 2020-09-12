package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.DrawShopList;

//T302
public class DrawListPacket extends HeaderPacket {	
	
	public List<DrawShopList> drawList;	
}