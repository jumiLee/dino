package first.vassystem.dto;

import java.util.Date;

public class AchvList {
	public int achvType;			//����Ÿ��
	public int achvId;				//�������̵�
	public String achvTitle;		//���� ����
	public String achvContent;		//��������
	public int achvCompleteCnt;		//�޼�ȸ��
	public int achvRwdType;			//����Ÿ��
	public int achvRwdId;			//������̵�
	public int achvRwdSubId;		//���󼭺���̵�
	public String rwdName;			//�����
	public int achvCompleteFlag;	//�޼�����(1:�޼�, 2:�̴޼�)
	public int rwdRcvFlag;			//������ɿ���(1:����, 2:�̼���)
	public int achvCnt;				//�޼�ȸ��
	public Date achvCompleteDt;		//�޼��Ͻ�
	public Date rwdRcvDt;			//��������Ͻ�
}