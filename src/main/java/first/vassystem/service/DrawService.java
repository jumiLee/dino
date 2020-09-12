package first.vassystem.service;

import first.vassystem.packet.DrawListPacket;
import first.vassystem.packet.DrawMgmtPacket;

public interface DrawService {

	/* ªÃ±‚  */
	DrawMgmtPacket userDraw(int user_account, int draw_id, int draw_type_cd) throws Exception;
	
	/* ªÃ±‚¡∂»∏  */
	DrawListPacket getDrawList(int job_type_cd, int draw_type_cd, int draw_id) throws Exception;
}