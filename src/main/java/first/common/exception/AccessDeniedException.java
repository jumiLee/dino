package first.common.exception;

public class AccessDeniedException extends Exception{ 
	 
	private static final long serialVersionUID = 1L;
	public AccessDeniedException() {}
	public AccessDeniedException(String msg) {
		super(msg);
	}
}