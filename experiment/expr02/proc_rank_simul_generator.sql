DROP FUNCTION IF EXISTS rank_simul_generator (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(10), VARCHAR(3), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION rank_simul_generator (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramRankType VARCHAR(10),
paramMonthLast VARCHAR(3), -- 월별 통계 테이블의 분할 단위 마지막월수
paramMonths VARCHAR(3) -- 월별 통계 테이블의 분할 단위 수 (월수)
) RETURNS VOID AS $$
  DECLARE
    token VARCHAR(10)[]; 
    varWaku VARCHAR(100);
    varBetType VARCHAR(3);
  BEGIN
    -- 랭크 와꾸 패턴 취득
    -- 20200616 와꾸패턴은 제외시킨다. (결과가 너무 조밀하여 예측성이 약해져버린다.) boatstat에 적용
    varWaku := '0::text';
--    select into token string_to_array(paramRankType, '_')::VARCHAR(10)[];
--    if token[2] = '23' then
--      varWaku := 'substring(predict_rank123 from 2 for 2)';
--    elsif token[2] = '3' then
--      varWaku := 'substring(predict_rank123 from 3 for 1)';
--    elsif token[2] = '12' then
--      varWaku := 'substring(predict_rank123 from 1 for 2)';
--    elsif token[2] = '123' then
--      varWaku := 'substring(predict_rank123 from 1 for 3)';
--    elsif token[2] = '0' then
--      varWaku := '0::text';
--    elsif token[2] = '234' then
--      varWaku := 'substring(predict_rank123 from 2 for 3)';
--    elsif token[2] = '34' then
--      varWaku := 'substring(predict_rank123 from 3 for 2)';
--    elsif token[2] = '1234' then
--      varWaku := 'substring(predict_rank123 from 1 for 4)';
--    elsif token[2] = '4' then
--      varWaku := 'substring(predict_rank123 from 4 for 1)';
--    end if;

	-- 랭크타입 취득
	if left(paramRankType, 6) = 'norm1t' then 
	  varBetType := '1T';
	elsif left(paramRankType, 6) = 'norm2f' then 
	  varBetType := '2F';
	elsif left(paramRankType, 6) = 'norm2t' then 
	  varBetType := '2T';
	elsif left(paramRankType, 6) = 'norm3f' then 
	  varBetType := '3F';
	elsif left(paramRankType, 6) = 'norm3t' then 
	  varBetType := '3T';
	elsif left(paramRankType, 7) = 'form2t2' then 
	  varBetType := '2T';
	elsif left(paramRankType, 7) = 'form3t4' then 
	  varBetType := '3T';
	elsif left(paramRankType, 7) = 'form3t8' then 
	  varBetType := '3T';
	end if;
    
	if substring(paramRankType from 1 for 4) = 'norm' then
	  perform tool_generate_rank_ext_monthly(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, varWaku, paramMonthLast, paramMonths);
	elseif substring(paramRankType from 1 for 4) = 'form' then
	  perform tool_generate_rank_ext_monthly_form(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, varWaku, paramMonthLast, paramMonths);
	end if;
	
  END;
$$ LANGUAGE plpgsql;

truncate rank_ext;
truncate rank_ext_monthly;
truncate rank_ext_hit;
truncate rank_ext_metric;
truncate rank_result_form;
truncate rank_result_hity;
truncate rank_result_form_hity;

select coutn(*) from rank_ext;
select coutn(*) from rank_ext_monthly;


-- 월별통계 시뮬레이션용 20200620
-- rank_ext생성시 기간보다 이후에 대해서만 실행해야한다. (ym > paramMonthLast)
DROP FUNCTION IF EXISTS tool_generate_rank_ext_monthly (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION tool_generate_rank_ext_monthly (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramBetType VARCHAR(3),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100), -- ex) substring(predict_rank123 from 2 for 2)
paramMonthLast VARCHAR(3), -- 월별 통계 테이블의 분할 단위 마지막월수
paramMonths VARCHAR(3) -- 월별 통계 테이블의 분할 단위 
) RETURNS VOID AS $$
  DECLARE
    varMonths int;
    varMonthLast int;
  BEGIN
  	varMonths := cast(paramMonths as int);
  	varMonthLast := cast(paramMonthLast as int);
  	
	---------------------------------------------
	-- 월별통계
		  -- substring(ymd from 1 for 6) ym,
	raise info 'insert rank_ext_monthly';
	delete from rank_ext_monthly where description = paramDescription and ranktype = paramRankType and ym::int > varMonthLast;
	
    EXECUTE format ('
		insert into rank_ext_monthly
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
			  description, bettype, bet_kumiban, pattern, ''%s'' ranktype, %s waku, 
			  ( (ntile(%s) over(partition by description, bettype, bet_kumiban, pattern, %s order by ymd, sime)) + %s )::text ym,
			  hity, betamt, hitamt, (hitamt - betamt) incomeamt,
			  description || ''+'' || bettype || ''+'' || bet_kumiban || ''+'' || pattern || ''+'' || ''%s'' || ''+'' || %s extkey
			from rank_result
			where description = ''%s''
			  and bettype = ''%s''
			  and ymd >= ''%s'' and ymd <= ''%s'' 
		) tmp, rank_ext ext
		where tmp.extkey = ext.extkey
		group by tmp.description, tmp.bettype, tmp.bet_kumiban, tmp.pattern, tmp.ranktype, tmp.waku, tmp.ym, tmp.extkey
		order by description, bettype, bet_kumiban, pattern, ranktype, waku, ym::int, extkey
	' , paramRankType, paramWaku, varMonths, paramWaku, varMonthLast, paramRankType, paramWaku
	  , paramDescription, paramBetType, paramFromYmd, paramToYmd
    );
	
  END;
$$ LANGUAGE plpgsql;

select tool_generate_rank_ext_monthly('0001', '20160101', '20200531', '2T', 'norm2t_3', '0', '0', '100');


-- 월별통계 시뮬레이션용 20200620
-- rank_ext생성시 기간보다 이후에 대해서만 실행해야한다. (ym > paramMonthLast)
DROP FUNCTION IF EXISTS tool_generate_rank_ext_monthly_form (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION tool_generate_rank_ext_monthly_form (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramBetType VARCHAR(3),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100), -- ex) substring(predict_rank123 from 2 for 2)
paramMonthLast VARCHAR(3), -- 월별 통계 테이블의 분할 단위 마지막월수
paramMonths VARCHAR(3) -- 월별 통계 테이블의 분할 단위 
) RETURNS VOID AS $$
  DECLARE
    varMonths int;
    varMonthLast int;
  BEGIN
  	varMonths := cast(paramMonths as int);
  	varMonthLast := cast(paramMonthLast as int);
  	
	---------------------------------------------
	-- 월별 통계
	raise info 'insert rank_ext_monthly';
	delete from rank_ext_monthly where description = paramDescription and ranktype = paramRankType and ym::int > varMonthLast;
	
    EXECUTE format ('
		insert into rank_ext_monthly
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
			  description, bettype, bet_kumiban, pattern, ''%s'' ranktype, %s waku, 
			  ( (ntile(%s) over(partition by description, bettype, bet_kumiban, pattern, %s order by ymd, sime)) + %s )::text ym,
			  hity, betamt, hitamt, (hitamt - betamt) incomeamt,
			  description || ''+'' || bettype || ''+'' || bet_kumiban || ''+'' || pattern || ''+'' || ''%s'' || ''+'' || %s extkey
			from rank_result_form
			where description = ''%s'' and ranktype = ''%s''
			  and bettype = ''%s''
			  and ymd >= ''%s'' and ymd <= ''%s'' 
		) tmp, rank_ext ext
		where tmp.extkey = ext.extkey
		group by tmp.description, tmp.bettype, tmp.bet_kumiban, tmp.pattern, tmp.ranktype, tmp.waku, tmp.ym, tmp.extkey
		order by description, bettype, bet_kumiban, pattern, ranktype, waku, ym::int, extkey
	' , paramRankType, paramWaku, varMonths, paramWaku, varMonthLast, paramRankType, paramWaku
	  , paramDescription, paramRankType, paramBetType, paramFromYmd, paramToYmd
    );
    
  END;
$$ LANGUAGE plpgsql;

----------------  이하 임시작업용 20200803 삭제할 것 ---------------------
DROP FUNCTION IF EXISTS tool_generate_rank_ext_monthly (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION tool_generate_rank_ext_monthly (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramBetType VARCHAR(3),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100), -- ex) substring(predict_rank123 from 2 for 2)
paramMonthLast VARCHAR(3), -- 월별 통계 테이블의 분할 단위 마지막월수
paramMonths VARCHAR(3) -- 월별 통계 테이블의 분할 단위 
) RETURNS VOID AS $$
  DECLARE
    varMonths int;
    varMonthLast int;
  BEGIN
  	varMonths := cast(paramMonths as int);
  	varMonthLast := cast(paramMonthLast as int);
  	
	---------------------------------------------
	-- 월별통계
		  -- substring(ymd from 1 for 6) ym,
	raise info 'insert rank_ext_monthly';
	delete from rank_ext_monthly where description = paramDescription and ranktype = paramRankType and ym::int > varMonthLast;
	
    EXECUTE format ('
		insert into rank_ext_monthly
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
			  description, bettype, bet_kumiban, pattern, ''%s'' ranktype, %s waku, 
			  ( (ntile(%s) over(partition by description, bettype, bet_kumiban, pattern, %s order by ymd, sime)) + %s )::text ym,
			  hity, betamt, hitamt, (hitamt - betamt) incomeamt,
			  description || ''+'' || bettype || ''+'' || bet_kumiban || ''+'' || pattern || ''+'' || ''%s'' || ''+'' || %s extkey
			from rank_result
			where description = ''%s''
			  and bettype = ''%s''
			  and ymd >= ''%s'' and ymd <= ''%s'' 
		) tmp
		group by tmp.description, tmp.bettype, tmp.bet_kumiban, tmp.pattern, tmp.ranktype, tmp.waku, tmp.ym, tmp.extkey
		order by description, bettype, bet_kumiban, pattern, ranktype, waku, ym::int, extkey
	' , paramRankType, paramWaku, varMonths, paramWaku, varMonthLast, paramRankType, paramWaku
	  , paramDescription, paramBetType, paramFromYmd, paramToYmd
    );
	
  END;
$$ LANGUAGE plpgsql;

select tool_generate_rank_ext_monthly('0001', '20160101', '20200531', '2T', 'norm2t_3', '0', '0', '100');


-- 월별통계 시뮬레이션용 20200620
-- rank_ext생성시 기간보다 이후에 대해서만 실행해야한다. (ym > paramMonthLast)
DROP FUNCTION IF EXISTS tool_generate_rank_ext_monthly_form (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION tool_generate_rank_ext_monthly_form (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramBetType VARCHAR(3),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100), -- ex) substring(predict_rank123 from 2 for 2)
paramMonthLast VARCHAR(3), -- 월별 통계 테이블의 분할 단위 마지막월수
paramMonths VARCHAR(3) -- 월별 통계 테이블의 분할 단위 
) RETURNS VOID AS $$
  DECLARE
    varMonths int;
    varMonthLast int;
  BEGIN
  	varMonths := cast(paramMonths as int);
  	varMonthLast := cast(paramMonthLast as int);
  	
	---------------------------------------------
	-- 월별 통계
	raise info 'insert rank_ext_monthly';
	delete from rank_ext_monthly where description = paramDescription and ranktype = paramRankType and ym::int > varMonthLast;
	
    EXECUTE format ('
		insert into rank_ext_monthly
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
			  description, bettype, bet_kumiban, pattern, ''%s'' ranktype, %s waku, 
			  ( (ntile(%s) over(partition by description, bettype, bet_kumiban, pattern, %s order by ymd, sime)) + %s )::text ym,
			  hity, betamt, hitamt, (hitamt - betamt) incomeamt,
			  description || ''+'' || bettype || ''+'' || bet_kumiban || ''+'' || pattern || ''+'' || ''%s'' || ''+'' || %s extkey
			from rank_result_form
			where description = ''%s'' and ranktype = ''%s''
			  and bettype = ''%s''
			  and ymd >= ''%s'' and ymd <= ''%s'' 
		) tmp
		group by tmp.description, tmp.bettype, tmp.bet_kumiban, tmp.pattern, tmp.ranktype, tmp.waku, tmp.ym, tmp.extkey
		order by description, bettype, bet_kumiban, pattern, ranktype, waku, ym::int, extkey
	' , paramRankType, paramWaku, varMonths, paramWaku, varMonthLast, paramRankType, paramWaku
	  , paramDescription, paramRankType, paramBetType, paramFromYmd, paramToYmd
    );
    
  END;
$$ LANGUAGE plpgsql;
