package first.vassystem.service;

import first.vassystem.packet.AttendListPacket;
import first.vassystem.packet.AttendRewardPacket;

public interface EventService {

	/* �⼮�̺�Ʈ ����Ʈ ��ȸ  */
	AttendListPacket getAttendList(int user_account) throws Exception;
	
	/* �⼮�̺�Ʈ ���� ������Ʈ */
	AttendRewardPacket attendGetReward(int user_account, int job_type, int attend_type, int day_no) throws Exception;
	
}