package first.vassystem.service;

import first.vassystem.packet.BattleMgmtPacket;

public interface BattleService {

	/* ·©Å·Á¶È¸  */
	BattleMgmtPacket mgmtBattle(int job_type, int user_account, int bat_room_no, int bat_point, int evt_point, int bat_result, int win_type) throws Exception;
}