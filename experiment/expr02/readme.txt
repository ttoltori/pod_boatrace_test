분석을 위해서는 아래의 실행순서대로 배치파일이 실행되어야한다. 

1. rank_model_generator.bat
2. rank_result_generator.bat
3. rank_result_form_generator.bat
4. rank_result_hity_generator.bat
5. rank_ext_generator.bat

		
		select
	  	  tmp.description, tmp.bettype, tmp.bet_kumiban, tmp.pattern, tmp.ranktype, tmp.waku, tmp.ym,
		  sum(1) betcnt,
		  sum(tmp.hity) hitcnt,
		  sum(tmp.betamt) betamt,
		  sum(tmp.hitamt) hitamt,
		  sum(tmp.incomeamt) incomeamt,
		  (sum(tmp.hity)::float / sum(1)::float)::numeric(7,2) hitrate,
		  (sum(tmp.hitamt)::float / sum(tmp.betamt)::float)::numeric(7,2) incomerate,
		  ((sum(tmp.hitamt) - sum(tmp.betamt)) / sum(1)) avg_incomeamt,
		  tmp.extkey
		from (
			select 
			  description, bettype, bet_kumiban, pattern, 'norm1t_23' ranktype, substring(predict_rank123 from 2 for 2) waku, 
			  (ntile(4) over(partition by description, bettype, bet_kumiban, pattern, substring(predict_rank123 from 2 for 2) order by ymd, sime))::text ym,
			  hity, betamt, hitamt, (hitamt - betamt) incomeamt,
			  description || '+' || bettype || '+' || bet_kumiban || '+' || pattern || '+' || 'norm1t_23' || '+' || substring(predict_rank123 from 2 for 2) extkey
			from rank_result
			where description = '0003'
			  and bettype = '1T'
			  and ymd >= '20170101' and ymd <= '20170331' 
		) tmp, rank_ext ext
		where tmp.extkey = ext.extkey
		group by tmp.description, tmp.bettype, tmp.bet_kumiban, tmp.pattern, tmp.ranktype, tmp.waku, tmp.ym, tmp.extkey
		order by description, bettype, bet_kumiban, pattern, ranktype, waku, ym::int, extkey;
		