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
import first.vassystem.packet.AchvListPacket;
import first.vassystem.packet.AchvMgmtPacket;
import first.vassystem.packet.HeaderPacket;
import first.vassystem.service.AchvService;
import first.vassystem.service.MemberService;

@RestController
public class AchvController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private AchvService achvService;
	
	@Autowired 
	private MemberService memberService;
	
	/* Achievement List */
	@RequestMapping(value="/achvList.do", produces = "application/json")
	@ResponseBody
	public AchvListPacket achvList(
			 @RequestParam int job_type
			,@RequestParam int user_account
			,@RequestParam String sid) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}	
				
		return achvService.getAchvList(job_type, user_account);
	}
	
	/* Achievement Reward */
	@RequestMapping(value="/mgmtAchvRwd.do", produces = "application/json")
	@ResponseBody
	public AchvMgmtPacket mgmtAchvRwd(
			 @RequestParam int job_type
			,@RequestParam int user_account
			,@RequestParam String sid
			,@RequestParam int achv_type
			,@RequestParam int achv_id) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}	
				
		return achvService.mgmtAchvRwd(job_type, user_account,achv_type,achv_id);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}