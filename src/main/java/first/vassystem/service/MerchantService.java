package first.vassystem.service;

import first.vassystem.packet.MerchantInfoPacket;

public interface MerchantService {
	
	/* login check */
	MerchantInfoPacket loginCheck(String email, String pwd) throws Exception;	
}