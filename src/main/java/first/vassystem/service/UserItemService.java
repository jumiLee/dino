package first.vassystem.service;

import first.vassystem.dto.UserItemList;
import first.vassystem.packet.UserItemListPacket;

public interface UserItemService {

	/* 사용자 아이템 조회  */
	UserItemListPacket getUserItemList(int job_type_cd, int user_account) throws Exception;
	
	/* 사용자 기간제 아이템 업데이트  */
	int updateUserPeriodItem(int user_account, UserItemList userItem) throws Exception;
}