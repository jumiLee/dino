package first.vassystem.service;

import first.vassystem.packet.RankPacket;

public interface RankService {

	/* ��ŷ��ȸ  */
	RankPacket getRank(int user_account, int rank_type) throws Exception;
}