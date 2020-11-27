package first.vassystem.dto;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

/**
 * mst_merchant Class
 */
@Getter
@Setter
public class Merchant {
	public int mctId;
	public String mctName;	
	public String mctEmail; 
	public String mctPwd;
	public String mct_desc;
	public Date createDate;
	public Date lastModifyDate;
}