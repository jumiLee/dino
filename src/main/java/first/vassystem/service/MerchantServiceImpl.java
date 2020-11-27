package first.vassystem.service;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;
import first.common.util.ParamVO;
import first.vassystem.dao.MerchantDAO;
import first.vassystem.dto.Merchant;
import first.vassystem.dto.MerchantStat;
import first.vassystem.packet.MerchantInfoPacket;

@Service 
public class MerchantServiceImpl implements MerchantService {

	Logger log = Logger.getLogger(this.getClass());
	
	@Resource(name="MerchantDAO") 
	private MerchantDAO merchantDAO; 
	
	/**
	 * login check
	 */
	@Override
	public MerchantInfoPacket loginCheck(String email, String pwd) throws Exception {
		
		MerchantInfoPacket merchantInfoPacket = new MerchantInfoPacket();
		Merchant merchant = new Merchant();
		int resultCd = 0;
		String resultMsg = "";
		int user_account = 0; //Merchant 정보에는 필요하지 않음.
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInStrParam01(email);
		
		//call procedure
		merchant = merchantDAO.selectMerchant(vo);
				
		//set return message
		if(merchant != null) {
			if (!pwd.equals(merchant.mctPwd)) {
				resultCd = -12;
				resultMsg = "wrong password";
			}
		}else {
			resultCd = -11;
			resultMsg = "No Merchant exist";
		}		
		merchantInfoPacket.merchant = merchant;
		merchantInfoPacket.setHeader(user_account, resultCd, resultMsg);		
				
		return merchantInfoPacket;
	}	
	
	@Override
	public List<MerchantStat> merchantStat() throws Exception {
		
		List<MerchantStat> merchantStat = merchantDAO.selectMerchantStat();
		
		if(merchantStat.size() == 0) {	
			return new ArrayList<MerchantStat>();
		}
		return merchantStat;
	}	
}