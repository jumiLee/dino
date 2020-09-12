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
import first.vassystem.packet.ItemListPacket;
import first.vassystem.packet.ItemMgmtPacket;
import first.vassystem.packet.ShopListPacket;
import first.vassystem.service.MemberService;
import first.vassystem.service.ShopService;

@RestController
public class ShopController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private ShopService shopService;
	
	@Autowired 
	private MemberService memberService;
	
	/* 유료상점조회 */
	@RequestMapping(value="/shopList.do", produces = "application/json")
	@ResponseBody
	public ShopListPacket shopList(
			@RequestParam int device_type
			,@RequestParam int payment_type
			) throws Exception {
		
		return shopService.getShopList(device_type, payment_type);
	}
	
	/* 상점조회 */
	@RequestMapping(value="/shopListByCategory.do", produces = "application/json")
	@ResponseBody
	public ItemListPacket shopListByCategory(
			@RequestParam int shop_category
			) throws Exception {
		
		return shopService.getShopListByCategory(shop_category);
	}
	
	/* 아이템 구매 */
	@RequestMapping(value="/buyItem.do", produces = "application/json")
	@ResponseBody
	public ItemMgmtPacket buyItem(
			 @RequestParam int user_account
			,@RequestParam String sid
			,@RequestParam int item_id
			,@RequestParam int item_cnt
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
				
		return shopService.buyItem(user_account, item_id, item_cnt);
	}
	
	/* 아이템 사용 */
	@RequestMapping(value="/useItem.do", produces = "application/json")
	@ResponseBody
	public ItemMgmtPacket useItem(
			 @RequestParam int user_account
			,@RequestParam String sid
			,@RequestParam int item_unique_id
			,@RequestParam int item_cnt
			) throws Exception {
		
		//session check
		if(memberService.checkSession(user_account, sid) == 0) {
			throw new AccessDeniedException();
		}
				
		return shopService.useItem(user_account, item_unique_id, item_cnt);
	}
	
	@ExceptionHandler(value = AccessDeniedException.class)  
	public HeaderPacket nfeHandler(AccessDeniedException e){  
		HeaderPacket headerPacket = new HeaderPacket(); 
		headerPacket.setHeader(0, ReturnType.SIDNOTMATCHED.getCode(), ReturnType.SIDNOTMATCHED.getValue());
		
		return headerPacket;
    }  
}