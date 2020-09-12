package first.vassystem.service;

import java.util.List;

import first.vassystem.dto.InboxList;
import first.vassystem.packet.InboxMgmtPacket;

public interface InboxService {

	/* ������ ����Ʈ ��ȸ  */
	List<InboxList> getInboxList(int user_account) throws Exception;
	
	/* ������ ������Ʈ */
	InboxMgmtPacket mgmtInbox(int user_account, int job_type, int rcvNo) throws Exception;
	
}