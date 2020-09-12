package first.vassystem.controller;

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import first.common.exception.AccessDeniedException;
import first.common.util.ReturnType;
import first.vassystem.dto.InboxList;
import first.vassystem.packet.AttendListPacket;
import first.vassystem.packet.HeaderPacket;
import first.vassystem.packet.InboxMgmtPacket;
import first.vassystem.packet.InboxPacket;
import first.vassystem.service.InboxService;
import first.vassystem.service.MemberService;


@RestController
public class InBoxController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private InboxService inboxService;
	
	@Autowired 
	private MemberService memberService;
	@RequestMapping(value="/inboxList.do", produces = "application/json")
	@ResponseBody
	public InboxPacket inboxList(
			@RequestParam int user_account,
			@RequestParam String sid) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
				
		InboxPacket inboxPacket = new InboxPacket();
		List<InboxList> inboxList = inboxService.getInboxList(user_account);
		
		if(inboxList.size() ==0) {
			inboxPacket.resultMsg = "No Inbox List";
		}else {
			inboxPacket.inboxList =inboxList;
		}
	
		return inboxPacket;
	}
	
	@RequestMapping(value="/mgmtInbox.do", produces = "application/json")
	@ResponseBody
	public InboxMgmtPacket mgmtInbox(
			@RequestParam int user_account,
			@RequestParam int job_type,
			@RequestParam int rcvNo,
			@RequestParam String sid) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
				
		return inboxService.mgmtInbox(user_account, job_type, rcvNo);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}