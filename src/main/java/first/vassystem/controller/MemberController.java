package first.vassystem.controller;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import first.common.util.UserLevelType;
import first.vassystem.packet.MemberInfoPacket;
import first.vassystem.service.MemberService;



@RestController
public class MemberController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private MemberService memberService;
	
	/* login check */
	@RequestMapping(value="/loginChk.do", produces = "application/json")
	@ResponseBody
	public MemberInfoPacket loginCheck(
			@RequestParam String email
			,@RequestParam String pwd
			) throws Exception {
		
		return memberService.loginCheck(email, pwd);
	}
	
	/* member register */
	@RequestMapping(value="/register.do", produces = "application/json")
	@ResponseBody
	public MemberInfoPacket register(
			@RequestParam String email
			,@RequestParam String pwd
			,@RequestParam String nickname
			) throws Exception {
		
		return memberService.register(UserLevelType.GENERAL, email, pwd, nickname);
	}
	
	/* AI register */
	@RequestMapping(value="/registerAI.do", produces = "application/json")
	@ResponseBody
	public MemberInfoPacket registerAI(
			@RequestParam String email
			,@RequestParam String pwd
			,@RequestParam String nickname
			) throws Exception {
		
		return memberService.register(UserLevelType.AI, email, pwd, nickname);
	}
}