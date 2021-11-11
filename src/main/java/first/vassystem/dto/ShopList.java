package first.vassystem.dto;

public class ShopList {
	public int cashId;		//상품아이디
	public int cashTypeCd;	//금액타입(1:$, 2:won)
	public int cashAmt;		//상품금액
	public int cashDisAmt;	//상품할인금액
	public int coinAmt;		//충전금액
	public String coinNm;	//상품명
	public String coinDesc;	//상품설명
	public String prodId;	//상품등록아이디
	public int deviceType;	//디바이스타입 (1:AOS, 2:IOS)
	public int prodImgNo;	//상품이미지
}