package first.vassystem.controller;

import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import first.vassystem.dto.MerchantStat;
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
	
	/* Merchant Detail List */
	@RequestMapping(value="/merchantList.do")
	public ModelAndView merchantStat(Model model) throws Exception {
				
		List<MerchantStat> merchantList =  merchantService.merchantStat();

		return new ModelAndView ("merchantList", "list", merchantList);
	}
}