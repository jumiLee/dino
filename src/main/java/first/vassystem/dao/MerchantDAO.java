package first.vassystem.dao;

import org.springframework.stereotype.Repository;

import first.common.dao.AbstractDAO;
import first.common.util.ParamVO;
import first.vassystem.dto.Merchant;

@Repository("MerchantDAO")
public class MerchantDAO extends AbstractDAO {

	public Merchant selectMerchant(ParamVO paramVO) throws Exception{ 
		return (Merchant) selectOne("merchant.selectMerchant", paramVO); 
	}
}