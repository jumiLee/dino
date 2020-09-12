package first.common.util;

import lombok.Getter;

@Getter
public enum UserLevelType {

	GM(0,"game manager"),
	GENERAL(1,"general user"),
	GUEST(2,"guest"),
	AI(3,"AI");
		
	private final int code;
	private final String value;

	 private UserLevelType(int code, String value) {
		 this.code = code;
		 this.value = value;
	 }
}