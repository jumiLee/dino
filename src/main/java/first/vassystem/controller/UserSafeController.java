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
import first.vassystem.packet.HeaderPacket;
import first.vassystem.packet.UserSafePacket;
import first.vassystem.service.MemberService;
import first.vassystem.service.UserSafeService;


@RestController
public class UserSafeController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private UserSafeService userSafeService;
	
	@Autowired 
	private MemberService memberService;
	
	@RequestMapping(value="/userSafeInfo.do", produces = "application/json")
	@ResponseBody
	public UserSafePacket userSafeInfo(
			@RequestParam int user_account,
			@RequestParam String sid) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}	
				
		return userSafeService.getUserSafeInfo(user_account);
	}
	
	@RequestMapping(value="/userSafeMgmt.do", produces = "application/json")
	@ResponseBody
	public UserSafePacket userSafeMgmt(
			@RequestParam int user_account,
			@RequestParam String sid,
			@RequestParam int safe_job_type,
			@RequestParam int money
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
		
		return userSafeService.mgmtUserSafe(user_account, safe_job_type, money);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}