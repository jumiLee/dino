package first.vassystem.service;

import first.vassystem.packet.AttendListPacket;
import first.vassystem.packet.AttendRewardPacket;

public interface EventService {

	/* 출석이벤트 리스트 조회  */
	AttendListPacket getAttendList(int user_account) throws Exception;
	
	/* 출석이벤트 보상 업데이트 */
	AttendRewardPacket attendGetReward(int user_account, int job_type, int attend_type, int day_no) throws Exception;
	
}