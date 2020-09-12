package first.vassystem.packet;

import java.util.List;

import first.vassystem.dto.RankList;

//T801
public class RankPacket extends HeaderPacket {	
	
	public List<RankList> rankList;	
	
	public int myRank;
	public int myPoint;
	
}