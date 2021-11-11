package first.vassystem.service;

import java.util.List;

import first.vassystem.dto.MerchantStat;
import first.vassystem.packet.MerchantInfoPacket;

public interface MerchantService {
	
	/* login check */
	MerchantInfoPacket loginCheck(String email, String pwd) throws Exception;	

	List<MerchantStat> merchantStat() throws Exception;
}