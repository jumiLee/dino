package first.vassystem.service;

import first.vassystem.packet.RankPacket;

public interface RankService {

	/* ·©Å·Á¶È¸  */
	RankPacket getRank(int user_account, int rank_type) throws Exception;
}