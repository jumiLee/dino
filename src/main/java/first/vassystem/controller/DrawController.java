package first.vassystem.controller;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import first.common.exception.AccessDeniedException;
import first.common.util.ReturnType;
import first.vassystem.packet.DrawListPacket;
import first.vassystem.packet.DrawMgmtPacket;
import first.vassystem.packet.HeaderPacket;
import first.vassystem.service.DrawService;
import first.vassystem.service.InboxService;
import first.vassystem.service.MemberService;

@RestController
public class DrawController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private DrawService drawService;
	
	@Autowired 
	private InboxService inboxService;
	
	@Autowired 
	private MemberService memberService;
	
	/* 뽑기 */
	@RequestMapping(value="/userDraw.do", produces = "application/json")
	@ResponseBody
	public DrawMgmtPacket userDraw(
			 @RequestParam int user_account
			,@RequestParam String sid
			,@RequestParam int draw_id
			,@RequestParam int draw_type_cd
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
				
		return drawService.userDraw(user_account, draw_id,draw_type_cd);
	}
	
	/* 우편함 뽑기 */
	@RequestMapping(value="/userInBoxDraw.do", produces = "application/json")
	@ResponseBody
	public DrawMgmtPacket userInBoxDraw(
			 @RequestParam int user_account
			,@RequestParam String sid
			,@RequestParam int draw_id
			,@RequestParam int rcvNo
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
				
		//draw process
		DrawMgmtPacket drawMgmtPacket = new DrawMgmtPacket();
		drawMgmtPacket = drawService.userDraw(user_account, draw_id, 0);
		
		//inbox update
		if(drawMgmtPacket.drawList !=null) {
			inboxService.mgmtInbox(user_account, 1, rcvNo);
		}
		return drawMgmtPacket;
	}
	
	/* 뽑기조회 */
	@RequestMapping(value="/drawList.do", produces = "application/json")
	@ResponseBody
	public DrawListPacket drawList(
			 @RequestParam int job_type_cd
			,@RequestParam int draw_type_cd
			,@RequestParam int draw_id
			) throws Exception {
		
		return drawService.getDrawList(job_type_cd, draw_type_cd, draw_id);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}