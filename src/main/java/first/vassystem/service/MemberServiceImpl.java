package first.vassystem.service;

import javax.annotation.Resource;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.common.util.UserLevelType;
import first.vassystem.dao.MemberDAO;
import first.vassystem.dao.UserInfoDAO;
import first.vassystem.dto.Member;
import first.vassystem.packet.MemberInfoPacket;

@Service 
public class MemberServiceImpl implements MemberService {

	Logger log = Logger.getLogger(this.getClass());
	
	@Resource(name="MemberDAO") 
	private MemberDAO memberDAO; 

	@Resource(name="UserInfoDAO") 
	private UserInfoDAO userInfoDAO; 
	
	/**
	 * login check
	 */
	@Override
	public MemberInfoPacket loginCheck(String email, String pwd) throws Exception {
		
		MemberInfoPacket loginCheckPacket = new MemberInfoPacket();
		Member member = new Member();
		int resultCd = 0;
		String resultMsg = "";
		int user_account = 0;
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInStrParam01(email);
		
		//call procedure
		member = memberDAO.selectMember(vo);
				
		//set return message
		if(member != null) {
			if (!pwd.equals(member.pwd)) {
				resultCd = -12;
				resultMsg = "wrong password";
			}else {
				user_account = member.account;			
				loginCheckPacket.userDetail = userInfoDAO.selectUserDetail(user_account);
				loginCheckPacket.sid = genSessionId(user_account);
			}
		}else {
			resultCd = -11;
			resultMsg = "No member exist";
		}		
		loginCheckPacket.setHeader(user_account, resultCd, resultMsg);
		
		//login log and update
		if(resultCd == 0) {
			//call procedure for log
			memberDAO.memberLog(user_account);
		}
				
		return loginCheckPacket;
	}	
	
	/* register */
	@Override
	public MemberInfoPacket register(UserLevelType userLevel, String email, String pwd, String nickname) throws Exception{
		MemberInfoPacket loginCheckPacket = new MemberInfoPacket();
		int resultCd = 0;
		String resultMsg = "";
		int user_account= 0;
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(userLevel.getCode());
		vo.setInStrParam01(email);
		vo.setInStrParam02(pwd);
		vo.setInStrParam03(nickname);
				
		//call procedure
		memberDAO.registerMember(vo);
		resultCd = vo.getOutParam02();
		
		if(resultCd == 0) {
			user_account = vo.getOutParam01();
			loginCheckPacket.userDetail = userInfoDAO.selectUserDetail(user_account);	
			loginCheckPacket.sid = genSessionId(user_account);
		}else {
		//set return message
			switch(resultCd) {
			case -11:
				resultMsg = "사용중인 이메일";
				break;
			case -12:
				resultMsg = "사용중인 닉네임";
				break;
			}
		}
		
		loginCheckPacket.setHeader(user_account, resultCd, resultMsg);
		
		return loginCheckPacket;
	}
	
	/**
	 * session check
	 */
	@Override
	public
	int checkSession(int user_account, String sid) {
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInStrParam01(sid);
		vo.setInParam01(user_account);
				
		//return userInfoDAO.selectUserBySid(vo);
		return 1; //현재 사용하지 않는 기능
	}
	
	/**
	 * get sessionId
	 */
	private String genSessionId(int user_account) {
		
		if(user_account == 0) {
			return StringUtils.EMPTY;
		}
		
		String sid ="";
		sid = RandomStringUtils.randomAlphanumeric(10);
		sid = sid + user_account;
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInStrParam01(sid);
		vo.setInParam01(user_account);
				
		userInfoDAO.updatSid(vo);
		
		return sid;
	}
}