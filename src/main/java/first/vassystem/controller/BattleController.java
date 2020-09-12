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
import first.vassystem.packet.BattleMgmtPacket;
import first.vassystem.packet.HeaderPacket;
import first.vassystem.service.BattleService;
import first.vassystem.service.MemberService;

@RestController
public class BattleController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private BattleService battleService;
	
	@Autowired 
	private MemberService memberService;
	
	/* Update Battle Result */
	@RequestMapping(value="/mgmtBattle.do", produces = "application/json")
	@ResponseBody
	public BattleMgmtPacket mgmtBattle(
			 @RequestParam int job_type
			,@RequestParam int user_account
			,@RequestParam String sid
			,@RequestParam int bat_room_no
			,@RequestParam int bat_point
			,@RequestParam int evt_point
			,@RequestParam int bat_result
			,@RequestParam int win_type
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}	
				
		return battleService.mgmtBattle(job_type, user_account, bat_room_no, bat_point, evt_point, bat_result, win_type);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}