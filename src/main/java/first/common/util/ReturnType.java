package first.common.util;

import lombok.Getter;

@Getter
public enum ReturnType {

	SUCESS(0,"success"),
	FAIL(-1,"general fail"),
	SIDNOTMATCHED(-11,"sid is not matched ");
	
	
	private final int code;
	private final String value;

	 private ReturnType(int code, String value) {
		 this.code = code;
		 this.value = value;
	 }
}
