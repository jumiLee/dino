package first.vassystem.service;

import first.vassystem.packet.AchvListPacket;
import first.vassystem.packet.AchvMgmtPacket;

public interface AchvService {

	/* 업적조회  */
	AchvListPacket getAchvList(int job_type, int user_account) throws Exception;
	
	/* 업적보상받기  */
	AchvMgmtPacket mgmtAchvRwd(int job_type, int user_account,int achv_type, int achv_id) throws Exception;
	
	/* 업적등록  */
	int registerAchv(int job_type, int user_account,int achv_type, int achv_id, int achv_cnt) throws Exception;
}