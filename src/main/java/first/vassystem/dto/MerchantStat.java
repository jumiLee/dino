package first.vassystem.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * mst_merchant Class
 */
@Getter
@Setter
public class MerchantStat extends Merchant{
	public String mctAddr;	
	public String mctIcon; 
	public int monsterCount;
	public int userCount;
}