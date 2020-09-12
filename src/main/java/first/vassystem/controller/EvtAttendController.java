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
import first.vassystem.packet.AttendListPacket;
import first.vassystem.packet.AttendRewardPacket;
import first.vassystem.packet.HeaderPacket;
import first.vassystem.service.EventService;
import first.vassystem.service.MemberService;


@RestController
public class EvtAttendController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private EventService eventService;
	
	@Autowired 
	private MemberService memberService;
	
	@RequestMapping(value="/attendList.do", produces = "application/json")
	@ResponseBody
	public AttendListPacket attend(
			@RequestParam int user_account, 
			@RequestParam String sid) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}	
				
		return eventService.getAttendList(user_account);
	}
	
	@RequestMapping(value="/attendGetRwd.do", produces = "application/json")
	@ResponseBody
	public AttendRewardPacket attendGetRwd(@RequestParam int user_account,
			@RequestParam int job_type,
			@RequestParam int attend_type,
			@RequestParam int day_no) throws Exception {
		
		AttendRewardPacket attendRwdPacket = new AttendRewardPacket();
		attendRwdPacket = eventService.attendGetReward(user_account, job_type, attend_type, day_no);
	
		return attendRwdPacket;
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}