package first.vassystem.service;

import first.vassystem.dto.UserItemList;
import first.vassystem.packet.UserItemListPacket;

public interface UserItemService {

	/* ����� ������ ��ȸ  */
	UserItemListPacket getUserItemList(int job_type_cd, int user_account) throws Exception;
	
	/* ����� �Ⱓ�� ������ ������Ʈ  */
	int updateUserPeriodItem(int user_account, UserItemList userItem) throws Exception;
}