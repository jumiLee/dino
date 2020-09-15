package first.vassystem.controller;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import first.vassystem.packet.MerchantInfoPacket;
import first.vassystem.service.MerchantService;



@RestController
public class MerchantController {
	
	Logger log = Logger.getLogger(this.getClass());
	
	@Autowired 
	private MerchantService merchantService;
	
	/* login check */
	@RequestMapping(value="/mctLoginChk.do", produces = "application/json")
	@ResponseBody
	public MerchantInfoPacket mctLoginCheck(
			@RequestParam String email
			,@RequestParam String pwd
			) throws Exception {
		
		return merchantService.loginCheck(email, pwd);
	}	
}