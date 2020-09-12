package first.vassystem.service;

import first.vassystem.packet.AchvListPacket;
import first.vassystem.packet.AchvMgmtPacket;

public interface AchvService {

	/* ������ȸ  */
	AchvListPacket getAchvList(int job_type, int user_account) throws Exception;
	
	/* ��������ޱ�  */
	AchvMgmtPacket mgmtAchvRwd(int job_type, int user_account,int achv_type, int achv_id) throws Exception;
	
	/* �������  */
	int registerAchv(int job_type, int user_account,int achv_type, int achv_id, int achv_cnt) throws Exception;
}