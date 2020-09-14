package first.vassystem.service;

import first.vassystem.packet.MonsterBookPacket;
import first.vassystem.packet.MonsterPacket;

public interface UserMonsterService {

	/* Get Monster List  */
	MonsterBookPacket getUserMonsterList(int job_type_cd, int user_account) throws Exception;
	
	/* Add Monster  */
	MonsterPacket addMonster(int user_account, int mon_id, int mct_id) throws Exception;
}