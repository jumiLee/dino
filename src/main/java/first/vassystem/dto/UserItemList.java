package first.vassystem.dto;

import java.sql.Date;

public class UserItemList extends ItemList{
	
	public int itemUniqueId;	//item unique id
	public int remainTime;		//item remain Period
	public Date makeDate;		//item make date
	public Date endDate;		//item end date
	public Date lastDate;		//item last update date
	public int itemUsage;		//1:사용중, 2:사용중X
}