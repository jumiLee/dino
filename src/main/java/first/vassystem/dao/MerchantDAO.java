package first.vassystem.dao;

import java.util.List;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.Merchant;
import first.vassystem.dto.MerchantStat;

@Repository("MerchantDAO")
public class MerchantDAO extends AbstractDAO {

	public Merchant selectMerchant(ParamVO paramVO) throws Exception{ 
		return (Merchant) selectOne("merchant.selectMerchant", paramVO); 
	}
	
	@SuppressWarnings("unchecked") 
	public List<MerchantStat> selectMerchantStat() throws Exception{ 
		return (List<MerchantStat>) selectList("merchant.selectMerchantStat"); 
	}
}