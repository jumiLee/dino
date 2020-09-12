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
import first.vassystem.packet.RankPacket;
import first.vassystem.service.MemberService;
import first.vassystem.service.RankService;

@RestController
public class RankController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private RankService rankService;
	
	@Autowired 
	private MemberService memberService;
	
	/* ·©Å·Á¶È¸ */
	@RequestMapping(value="/getRank.do", produces = "application/json")
	@ResponseBody
	public RankPacket getRank(
			 @RequestParam int user_account
			,@RequestParam String sid
			,@RequestParam int rank_type
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}	
				
		return rankService.getRank(user_account, rank_type);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}