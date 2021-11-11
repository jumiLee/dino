package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.Member;

@Repository("MemberDAO")
public class MemberDAO extends AbstractDAO {

	public Member selectMember(ParamVO paramVO) throws Exception{ 
		return (Member) selectOne("member.selectMember", paramVO); 
	}
	
	public Member registerMember(ParamVO paramVO) throws Exception{ 
		return (Member) selectOne("member.registerMember", paramVO); 
	}
}