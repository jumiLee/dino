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
import first.vassystem.packet.MonsterBookPacket;
import first.vassystem.packet.MonsterPacket;
import first.vassystem.service.UserMonsterService;


@RestController
public class UserMonsterController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private UserMonsterService userMonsterService;
	
	/*
	 * My Monster Book
	 */
	@RequestMapping(value="/userMonsterBook.do", produces = "application/json")
	@ResponseBody
	public MonsterBookPacket userMonsterBook(
			 @RequestParam int user_account) throws Exception {
				
		return userMonsterService.getUserMonsterBookList(user_account);
	}
	
	/* Add Monster */
	@RequestMapping(value="/addMonster.do", produces = "application/json")
	@ResponseBody
	public MonsterPacket addMonster(
			 @RequestParam int user_account
			,@RequestParam int mon_id
			,@RequestParam int mct_id	//merchant id
			) throws Exception {
		
		return userMonsterService.addMonster(user_account, mon_id, mct_id);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}