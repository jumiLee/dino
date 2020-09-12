package first.vassystem.dto;

/**
 * 사용자 랭킹관련 상세정보 Class
 */
public class UserScore {
	public int today_total_gold;		//오늘획득머니
	public int today_total_bat_cnt;		//오늘참여배틀 회수
	public int today_total_win_cnt; 	//오늘 승회수
	public int today_total_lose_cnt;	//오늘 패회수
	public int total_bat_cnt; 			//참여배틀 회수
	public int total_win_cnt; 			//승회수
	public int total_lose_cnt; 			//패회수
	public int total_bat_cnt2; 			//참여배틀 회수(2장)
	public int total_win_cnt2; 			//승회수(2장)
	public int total_lose_cnt2; 		//패회수(2장)
	public int total_bat_cnt3; 			//참여배틀 회수(3장)
	public int total_win_cnt3; 			//승회수(3장)
	public int total_lose_cnt3; 		//패회수(3장)
	public int user_rank; 				//유저랭킹
}