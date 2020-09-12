package first.vassystem.service;

import java.util.List;

import first.vassystem.dto.InboxList;
import first.vassystem.packet.InboxMgmtPacket;

public interface InboxService {

	/* 수신함 리스트 조회  */
	List<InboxList> getInboxList(int user_account) throws Exception;
	
	/* 수신함 업데이트 */
	InboxMgmtPacket mgmtInbox(int user_account, int job_type, int rcvNo) throws Exception;
	
}