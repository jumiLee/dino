package first.vassystem.service;

import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import first.common.util.ParamVO;
import first.vassystem.dao.AttendDAO;
import first.vassystem.dto.AttendList;
import first.vassystem.packet.AttendListPacket;
import first.vassystem.packet.AttendRewardPacket;


@Service 
public class EventServiceImpl implements EventService {

	Logger log = Logger.getLogger(this.getClass());

	@Resource(name="AttendDAO") 
	private AttendDAO attendDAO; 	
	
	/**
	 * 출석리스트 조회
	 */
	@Override
	public AttendListPacket getAttendList(int user_account) throws Exception {
		
		AttendListPacket attendListPacket = new AttendListPacket();
		int resultCd = 0;
		String resultMsg = "";
		
		//출석리스트
		List<AttendList> attendList = attendDAO.selectAttendList(user_account);
	
		if(attendList.size() ==0) {
			resultCd = -1;
			resultMsg = "No Attend Event Date";
		}else {
			attendListPacket.attendList =attendList;
		}
		
		attendListPacket.setHeader(user_account,resultCd,resultMsg);
		
		return attendListPacket;
	}
	
	/**
	 * 출석 보상
	 */
	@Override
	public AttendRewardPacket attendGetReward(int user_account, int job_type, int attend_type, int day_no) throws Exception {
		
		AttendRewardPacket attendRewardPacket = new AttendRewardPacket();
		
		//Setting parameters
		ParamVO vo = new ParamVO(); 
		vo.setInParam01(job_type);
		vo.setInParam02(user_account);
		vo.setInParam03(attend_type);
		vo.setInParam04(day_no);
		
		//call procedure
		attendDAO.attendGetReward(vo);
		
		//get procedure result
		attendRewardPacket.resultCd = vo.getOutParam01();
		
		//set return message
		switch(attendRewardPacket.resultCd) {
		case -12:
			attendRewardPacket.resultMsg = "�̹� ���";
			break;
		case -21:
			attendRewardPacket.resultMsg = "��ϵ� �⼮���� ���� ";
			break;
		case -22:
			attendRewardPacket.resultMsg = "Already Received";
			break;
		}
		
		return attendRewardPacket;
	}
}
