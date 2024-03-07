DROP FUNCTION IF EXISTS rank_ext_generator_norm (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION rank_ext_generator_norm (
paramDescription VARCHAR(10), 
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100), -- ex) substring(predict_rank123 from 2 for 2)
paramMonths VARCHAR(3), -- 월별 통계 테이블의 분할 단위 수 (월수)
paramMinBetcnt VARCHAR(3) -- 최소 베팅수
) RETURNS VOID AS $$
  DECLARE
    varDays int;
    varBetType VARCHAR(3);
  BEGIN

	-- 기간안의 날짜수 취득
	select into varDays cast(paramToYmd::date - paramFromYmd::date as int);
	
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
	end if;
  
	-- 기본 통계
	perform sub_generate_rank_ext(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, paramWaku, paramMonths, paramMinBetcnt);
	
	-- 월별통계
	perform sub_generate_rank_ext_monthly(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, paramWaku, paramMonths);
	
	-- 전체 적중금액들에 대해 평균편차내 적중금액이 차지하는 비율 (수익안정성과 비례) 을 취득하기 위한 데이터
	-- 삭제 20200620 > 별로 참조 안하고 있으며 제외되는 패턴이 생겨버린다.
	-- perform sub_generate_rank_ext_hit(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, paramWaku);
	
	-- 전체 월별투표회수들에 대해 평균편차내 투표회수의 월이 차지하는 비율(투표안정성과비례)을 취득하기 위한 데이터
	-- 느림 perform sub_generate_rank_ext_bet(paramDescription, paramRankType);

	-- 확장통계
	perform sub_generate_rank_ext_metric(paramDescription, paramRankType, varDays);
	
  END;
$$ LANGUAGE plpgsql;

select rank_ext_generator_norm('0003', '20170101', '20170331', 'norm1t_23', 'substring(predict_rank123 from 2 for 2)', '4');
select count(*) from rank_ext_metric where ranktype = 'norm1t_23';

select rank_ext_generator_norm('0003', '20170801', '20171231', 'norm2f_12', 'substring(predict_rank123 from 1 for 2)');
select count(*) from rank_ext_metric where ranktype = 'norm2f_12';

select rank_ext_generator_norm('0003', '20170801', '20171231', 'norm2t_3', 'substring(predict_rank123 from 3 for 1)');
select count(*) from rank_ext_metric where ranktype = 'norm2t_3';

select rank_ext_generator_norm('0003', '20170801', '20171231', 'norm3f_123', 'predict_rank123');
select count(*) from rank_ext_metric where ranktype = 'norm3f_123';

select rank_ext_generator_norm('0003', '20170801', '20171231', 'norm3t_0', '0::text');
select count(*) from rank_ext_metric where ranktype = 'norm3t_0';

DROP FUNCTION IF EXISTS sub_generate_rank_ext (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION sub_generate_rank_ext (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramBetType VARCHAR(3),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100), -- ex) substring(predict_rank123 from 2 for 2)
paramMonths VARCHAR(3), -- 월별 통계 테이블의 분할 단위 수 (월수)
paramMinBetcnt VARCHAR(3) -- 최소 베팅수
) RETURNS VOID AS $$
  DECLARE
    varMonths int;
    varMinBetcnt int;
    varMinHitrate float;
    varMinIncomerate float;
  BEGIN
  
  	varMonths := cast(paramMonths as int);
  	varMinBetcnt := cast(paramMinBetcnt as int);
  	
  	-- 20200616 제외되는 패턴이 없도록 조건해제 boatstat에 적용
  	-- 20200705 최소한 분할단위기간만큼의 베팅수는 있어야 하므로 월분할단위갯수를 최소베팅수로 제한한다
  	-- 20200706 최소betcnt가 이후의 slope산출에 중대한 변수가 된다.
  	varMinBetcnt := cast(paramMinBetcnt as int);
  	-- varMinBetcnt := varMonths;
  	-- varMinBetcnt := 0;
  	varMinIncomerate := 0;
  	varMinHitrate := 0;
  	
  	-- 분석기간이 아닌 실험기간인 경우는 분석기간에서 추출된 extkey로 누락되는 일이 없도록 범위를 훨씬 넓게 잡기위해서.
  	-- if cast(paramFromYmd as int) >= 2019 then
  	--  varMinIncomerate := 0;
  	--else
  	--  varMinIncomerate := 0.9;
  	--end if;
	---------------------------------------------
	-- 기본 통계
	raise info 'insert rank_ext';
	delete from rank_ext where description = paramDescription and ranktype = paramRankType;
	
    EXECUTE format ('
		insert into rank_ext
		select
			*
		from
		(
			select 
			  description, bettype, bet_kumiban, pattern, ''%s'' ranktype, %s waku, 
			  sum(1) betcnt,
			  sum(hity) hitcnt,
			  sum(betamt) betamt,
			  sum(hitamt) hitamt,
			  sum(hitamt) - sum(betamt) incomeamt, 
			  (sum(hity)::float / sum(1)::float)::numeric(7,2) hitrate,
			  (sum(hitamt)::float / sum(betamt)::float)::numeric(7,2) incomerate,
			  %s bet_months,
			  count(distinct ymd) bet_days,
			  description || ''+'' || bettype || ''+'' || bet_kumiban || ''+'' || pattern || ''+'' || ''%s'' || ''+'' || %s extkey
			from rank_result
			where description = ''%s''
			  and ymd >= ''%s'' and ymd <= ''%s'' 
			  and bettype = ''%s''
			group by description, bettype, bet_kumiban, pattern, waku
			order by description, bettype, bet_kumiban, pattern, waku
		) tmp
		where hitrate >= %s and incomerate >= %s and betcnt >= %s 
	' , paramRankType, paramWaku, varMonths, paramRankType, paramWaku
	  , paramDescription, paramFromYmd, paramToYmd, paramBetType, varMinHitrate, varMinIncomerate, varMinBetcnt
    );
  END;
$$ LANGUAGE plpgsql;

select sub_generate_rank_ext('0003', '20170101', '20170331', '1T', 'norm1t_23', 'substring(predict_rank123 from 2 for 2)', '4', '10');
select count(*) from rank_ext;

-- 월별통계
DROP FUNCTION IF EXISTS sub_generate_rank_ext_monthly (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3));
CREATE OR REPLACE FUNCTION sub_generate_rank_ext_monthly (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramBetType VARCHAR(3),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100), -- ex) substring(predict_rank123 from 2 for 2)
paramMonths VARCHAR(3) -- 월별 통계 테이블의 분할 단위 수 (월수)
) RETURNS VOID AS $$
  DECLARE
    varMonths int;
  BEGIN
  	varMonths := cast(paramMonths as int);
  	
	---------------------------------------------
	-- 월별통계
		  -- substring(ymd from 1 for 6) ym,
	raise info 'insert rank_ext_monthly';
	delete from rank_ext_monthly where description = paramDescription and ranktype = paramRankType;
	
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
			  (ntile(%s) over(partition by description, bettype, bet_kumiban, pattern, %s order by ymd, sime))::text ym,\d 
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
	' , paramRankType, paramWaku, varMonths, paramWaku, paramRankType, paramWaku
	  , paramDescription, paramBetType, paramFromYmd, paramToYmd
    );
	
  END;
$$ LANGUAGE plpgsql;


select sub_generate_rank_ext_monthly('0011', '20190101', '20190830', '2T', 'norm2t_3', '0', '8');
select count(*) from rank_ext_monthly;


-- 적중금액 메트릭 준비 데이터
-- 20200620 사용제외
DROP FUNCTION IF EXISTS sub_generate_rank_ext_hit (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100));
CREATE OR REPLACE FUNCTION sub_generate_rank_ext_hit (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramBetType VARCHAR(3),
paramRankType VARCHAR(10),
paramWaku VARCHAR(100) -- ex) substring(predict_rank123 from 2 for 2)
) RETURNS VOID AS $$
  DECLARE
  BEGIN
	---------------------------------------------
	-- 전체 적중금액들에 대해 평균편차내 적중금액이 차지하는 비율 (수익안정성과 비례) 을 취득하기 위한 데이터
	raise info 'insert rank_ext_hit';
	delete from rank_ext_hit where description = paramDescription and ranktype = paramRankType;
	
    EXECUTE format ('
		insert into rank_ext_hit
		select
		  res.description, res.bettype, res.bet_kumiban, res.pattern, ''%s'' ranktype, tmp.waku, 
		  tmp.avg_hitamt avg_hitamt,
		  tmp.dev_hitamt dev_hitamt,
		  tmp.min_hitamt min_hitamt,
		  tmp.max_hitamt max_hitamt,
		  sum(case when hitamt >= (avg_hitamt-dev_hitamt) and hitamt <= (avg_hitamt+dev_hitamt) then hitamt else 0 end) indev_hitamt,
	  	  extkey
		from rank_result_hity res, 
		(
			select
			  tmp2.description, tmp2.bettype, tmp2.bet_kumiban, tmp2.pattern, tmp2.waku,
			  avg(tmp2.hitamt)::int avg_hitamt,
			  stddev_pop(tmp2.hitamt)::int dev_hitamt,
			  min(tmp2.hitamt) min_hitamt,
			  max(tmp2.hitamt) max_hitamt,
			  tmp2.extkey
			from
			( 
				select
				  description, bettype, bet_kumiban, pattern, %s waku, hitamt,  
				  (description || ''+'' || bettype || ''+'' || bet_kumiban || ''+'' || pattern || ''+'' || ''%s'' || ''+'' || %s) extkey
				from rank_result_hity
				where description = ''%s''
				  and ymd >= ''%s'' and ymd <= ''%s'' 
				  and bettype = ''%s''
			) tmp2, rank_ext ext
			where tmp2.extkey = ext.extkey
			group by tmp2.description, tmp2.bettype, tmp2.bet_kumiban, tmp2.pattern, tmp2.waku, tmp2.extkey
			order by description, bettype, bet_kumiban, pattern, waku
		) tmp
		where res.description = ''%s''
		  and res.ymd >= ''%s'' and res.ymd <= ''%s'' 
		  and res.description = tmp.description and res.bettype = tmp.bettype and res.bet_kumiban = tmp.bet_kumiban 
		  and res.pattern = tmp.pattern 
		  and %s = tmp.waku
		group by res.description, res.bettype, res.bet_kumiban, res.pattern, 
		tmp.waku, tmp.avg_hitamt, tmp.dev_hitamt, tmp.min_hitamt, tmp.max_hitamt, tmp.extkey
	' , paramRankType, paramWaku, paramRankType, paramWaku
	  , paramDescription, paramFromYmd, paramToYmd, paramBetType
	  , paramDescription, paramFromYmd, paramToYmd
	  , paramWaku
    );
	
  END;
$$ LANGUAGE plpgsql;

select sub_generate_rank_ext_hit('0003', '20170101', '20170331', '1T', 'norm1t_23', 'substring(predict_rank123 from 2 for 2)');
select count(*) from rank_ext_hit;



-- 투표회수 메트릭 준비 데이터
-- !!!사용제외
DROP FUNCTION IF EXISTS sub_generate_rank_ext_bet (VARCHAR(10), VARCHAR(10));
CREATE OR REPLACE FUNCTION sub_generate_rank_ext_bet (
paramDescription VARCHAR(10),
paramRankType VARCHAR(10)
) RETURNS VOID AS $$
  DECLARE
  BEGIN
	---------------------------------------------
	-- 전체 월별투표회수들에 대해 평균편차내 투표회수의 월이 차지하는 비율(투표안정성과비례)을 취득하기 위한 데이터
	raise info 'insert rank_ext_bet';
	delete from rank_ext_bet where description = paramDescription and ranktype = paramRankType;
	insert into rank_ext_bet
	select
	  mon.description, mon.bettype, mon.bet_kumiban, mon.pattern, mon.ranktype, mon.waku, 
	  tmp.avg_betcnt avg_betcnt,
	  tmp.dev_betcnt dev_betcnt,
	  tmp.min_betcnt min_betcnt,
	  tmp.max_betcnt max_betcnt,
	  sum(case when betcnt >= (avg_betcnt-dev_betcnt) and betcnt <= (avg_betcnt+dev_betcnt) then betcnt else 0 end) indev_betcnt,
	  mon.extkey
	from rank_ext_monthly mon, 
	(
		select
		  description, bettype, bet_kumiban, pattern, ranktype, waku, 
		  avg(betcnt)::int avg_betcnt,
		  stddev_pop(betcnt)::int dev_betcnt,
		  min(betcnt) min_betcnt,
		  max(betcnt) max_betcnt,
		  extkey
		from rank_ext_monthly
		where description = paramDescription and ranktype = paramRankType
		group by description, bettype, bet_kumiban, pattern, ranktype, waku, extkey
		order by description, bettype, bet_kumiban, pattern, ranktype, waku, extkey
	) tmp
	where mon.description = paramDescription and mon.ranktype = paramRankType
	  and mon.extkey = tmp.extkey
	group by mon.description, mon.bettype, mon.bet_kumiban, mon.pattern, mon.ranktype, mon.waku, 
	  tmp.avg_betcnt, tmp.dev_betcnt, tmp.min_betcnt, tmp.max_betcnt, mon.extkey;
	
  END;
$$ LANGUAGE plpgsql;


-- 메트릭 
DROP FUNCTION IF EXISTS sub_generate_rank_ext_metric (VARCHAR(10), VARCHAR(10), int);
CREATE OR REPLACE FUNCTION sub_generate_rank_ext_metric (
paramDescription VARCHAR(10),
paramRankType VARCHAR(10),
paramDays int
) RETURNS VOID AS $$
  DECLARE
  BEGIN
	---------------------------------------------
	-- 확장통계
	raise info 'insert rank_ext_metric';
	delete from rank_ext_metric where description = paramDescription and ranktype = paramRankType;
	insert into rank_ext_metric
	select
	  ext.description, ext.bettype, ext.bet_kumiban, ext.pattern, ext.ranktype, ext.waku, 
	  0, -- 20200620 사용성떨어짐 (hit.indev_hitamt::float / ext.hitamt::float)::numeric(7,2) indev_hitamt_rate, 	-- 전체 적중금액들에 대해 평균편차내 적중금액이 차지하는 비율 (수익안정성과 비례)
	  (mon.plus_cnt::float / ext.bet_months::float)::numeric(7,2) plus_month_rate, 		-- 전체 투표월수 대비 흑자월수 비율 (클수록 수익안정적)
	  (ext.bet_days::float / paramDays::float)::numeric(7,2) betdays_rate, 				-- 전체 일수 대비 투표일수 비율 (투표안정성과 비례)
	  0, -- 느림 (bet.indev_betcnt::float / ext.betcnt::float)::numeric(7,2) indev_betcnt_rate,  	-- 전체 월별투표회수들에 대해 평균편차내 투표회수의 월이 차지하는 비율(투표안정성과비례)
	  mon.slope_monthly_income slope_monthly_income, 									-- 월평균수익금(율?)의 선형기울기 (수익성추이)
	  mon.stddev_hitrate,
	  mon.stddev_incomerate,
	  ext.extkey
	from
	(
		select
		  description, bettype, bet_kumiban, pattern, ranktype, waku, 
		  betcnt,
		  hitamt,
		  bet_months, 
		  bet_days,
		  extkey
		from rank_ext
		where description = paramDescription and ranktype = paramRankType
	) ext, 
-- 20200620 사용제외
--	(
--		select
--		  indev_hitamt, -- 평균편차 이내 적중금액의 합계
--		  extkey
--		from rank_ext_hit
--		where description = paramDescription and ranktype = paramRankType
--	) hit, 
--	(
--		select
--		  indev_betcnt, -- 월평균편차 이내 투표회수의 합계
--		  extkey
--		from rank_ext_bet
--		where description = paramDescription and ranktype = paramRankType
--	) bet, 
	(
		select
		  sum((case when incomeamt >= 0 then 1 else 0 end)) plus_cnt, -- 흑자월수	  
		  regr_slope(avg_incomeamt, ym::int)::numeric(12,3) slope_monthly_income, -- 월평균 수익금액 추이의 기울기
		  stddev_pop(hitrate)::numeric(7,2) stddev_hitrate, -- 월평균 적중율의 평균편차
		  stddev_pop(incomerate)::numeric(7,2) stddev_incomerate, -- 월평균 수익율의 평균편차
		  extkey
		from rank_ext_monthly
		where description = paramDescription and ranktype = paramRankType
		group by extkey
	) mon
	where ext.extkey = mon.extkey; 
	  -- and ext.extkey = bet.extkey 
	  -- and ext.extkey = hit.extkey;
	
  END;
$$ LANGUAGE plpgsql;

select sub_generate_rank_ext_metric('0003', 'norm1t_23', '120');
select count(*) from rank_ext_metric;


