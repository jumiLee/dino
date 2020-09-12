package first.vassystem.packet;

public class HeaderPacket{
	
	public int resultCd = 0;				//result code
	public String resultMsg = "Success";	//result Message
	public int account;
	
	public void setHeader(int account, int resultCd, String resultMsg) {
		this.resultCd = resultCd;
		this.account = account;
		this.resultMsg = resultMsg;
	}

	public void setHeader(int account) {
		this.account = account;
	}
}