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
import first.vassystem.packet.UserAPPacket;
import first.vassystem.packet.UserMgmtResultPacket;
import first.vassystem.service.MemberService;
import first.vassystem.service.UserMgmtService;

@RestController
public class UserMgmtController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private MemberService memberService;
	
	@Autowired 
	private UserMgmtService userMgmtService;
	
	//무료골드충전
	@RequestMapping(value="/freeChargeUserGold.do", produces = "application/json")
	@ResponseBody
	public UserAPPacket freeChargeUserGold(
			@RequestParam int user_account,
			@RequestParam String sid
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
			
		return userMgmtService.freeChargeUserGold(user_account);
	}
	
	//AI update game money
	@RequestMapping(value="/AIUpdateGold.do", produces = "application/json")
	@ResponseBody
	public UserMgmtResultPacket AIUpdateGold(
				@RequestParam int user_account,	//AI account
				@RequestParam String sid,
				@RequestParam int change_amt	//바꿀 Gold 금액
				) throws Exception {
			
			//session check
			if(memberService.checkSession(user_account, sid) == 0) {
				throw new AccessDeniedException();
			}
				
			return userMgmtService.AIUpdateGold(user_account, change_amt);
		}
		
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}