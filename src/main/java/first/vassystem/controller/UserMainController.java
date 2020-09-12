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
import first.vassystem.packet.UserDetailPacket;
import first.vassystem.packet.UserMainPacket;
import first.vassystem.service.MemberService;
import first.vassystem.service.UserMainService;


@RestController
public class UserMainController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private UserMainService userMainService;
	
	@Autowired 
	private MemberService memberService;
	
	@RequestMapping(value="/userMain.do", produces = "application/json")
	@ResponseBody
	public UserMainPacket userMain(
			@RequestParam int user_account
			//,@RequestParam String sid
		 ) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, "") == 0) {
			throw new AccessDeniedException();
		}		
		
		UserMainPacket userMainPacket = new UserMainPacket();
		userMainPacket = userMainService.getUserMain(user_account);
		
		return userMainPacket;
	}
	
	@RequestMapping(value="/userDetail.do", produces = "application/json")
	@ResponseBody
	public UserDetailPacket userDetail(@RequestParam int user_account) throws Exception {
		
		UserDetailPacket userDetailPacket = new UserDetailPacket();
		userDetailPacket = userMainService.getUserDetail(user_account);
		
		return userDetailPacket;
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
    public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}