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
import first.vassystem.packet.ItemListWithUserPacket;
import first.vassystem.packet.ItemPacket;
import first.vassystem.packet.MonsterPacket;
import first.vassystem.service.MemberService;
import first.vassystem.service.ShopService;

@RestController
public class ShopController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private ShopService shopService;
	
	@Autowired 
	private MemberService memberService;
	
	/* Get Item List */
	@RequestMapping(value="/itemList.do", produces = "application/json")
	@ResponseBody
	public ItemListWithUserPacket itemList(@RequestParam int user_account) throws Exception {
		
		return shopService.getItemList(user_account);
	}
	
	/* Buy Item */
	@RequestMapping(value="/buyItem.do", produces = "application/json")
	@ResponseBody
	public ItemPacket buyItem(
			 @RequestParam int user_account
			//,@RequestParam String sid
			,@RequestParam int item_id
			,@RequestParam int item_cnt
			) throws Exception {
		
		//session check
		/*
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
		*/		
		return shopService.buyItem(user_account, item_id, item_cnt);
	}
	
	/* Use Item */
	@RequestMapping(value="/useItem.do", produces = "application/json")
	@ResponseBody
	public MonsterPacket useItem(
			 @RequestParam int user_account
			,@RequestParam int mon_id
			,@RequestParam int user_mon_sn
			,@RequestParam int item_unique_id
			) throws Exception {
		
		//session check
		/*
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
		*/			
		return shopService.useItem(user_account, mon_id, user_mon_sn, item_unique_id);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}