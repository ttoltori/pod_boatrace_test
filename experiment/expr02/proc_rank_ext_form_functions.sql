DROP FUNCTION IF EXISTS rank_ext_generator_form (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION rank_ext_generator_form (
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
	
	-- 랭크타입 취득 및 폼투표용 결과테이블, 적중평균편차계산용 테이블 재생성 20200209
	if left(paramRankType, 7) = 'form2t2' then 
	  varBetType := '2T';
	elsif left(paramRankType, 7) = 'form3t4' then 
	  varBetType := '3T';
	elsif left(paramRankType, 7) = 'form3t8' then 
	  varBetType := '3T';
	end if;
  
	-- 기본 통계(포뮬레이션투표)
	perform sub_generate_rank_ext_form(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, paramWaku, paramMonths, paramMinBetcnt);
	
	-- 월별통계(포뮬레이션투표)
	perform sub_generate_rank_ext_monthly_form(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, paramWaku, paramMonths);
	
	-- 전체 적중금액들에 대해 평균편차내 적중금액이 차지하는 비율 (수익안정성과 비례) 을 취득하기 위한 데이터(포뮬레이션투표)
	-- 삭제 20200620 > 별로 참조 안하고 있으며 제외되는 패턴이 생겨버린다.
	-- perform sub_generate_rank_ext_hit_form(paramDescription, paramFromYmd, paramToYmd, varBetType, paramRankType, paramWaku);
	
	-- 전체 월별투표회수들에 대해 평균편차내 투표회수의 월이 차지하는 비율(투표안정성과비례)을 취득하기 위한 데이터
	-- 느림 perform sub_generate_rank_ext_bet(paramDescription, paramRankType);

	-- 확장통계
	perform sub_generate_rank_ext_metric(paramDescription, paramRankType, varDays);
	
  END;
$$ LANGUAGE plpgsql;

select rank_ext_generator_form('0003', '20170101', '20170331', 'form2t2_23', 'substring(predict_rank123 from 2 for 2)', '4');
select count(*) from rank_ext_metric where ranktype = 'form2t2_23';

select rank_ext_generator_form('0003', '20170801', '20171231', 'form3t4_3', 'substring(predict_rank123 from 3 for 1)');
select count(*) from rank_ext_metric where ranktype = 'form3t4_3';

select rank_ext_generator_form('0003', '20170801', '20171231', 'form3t8_23', 'substring(predict_rank123 from 2 for 2)');
select count(*) from rank_ext_metric where ranktype = 'form3t8_23';

-- 기본통계
DROP FUNCTION IF EXISTS sub_generate_rank_ext_form (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION sub_generate_rank_ext_form (
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
  	-- varMinBetcnt := cast(paramMinBetcnt as int);
  	-- 20200616 제외되는 패턴이 없도록 조건해제 boatstat에 적용
  	varMinBetcnt := cast(paramMinBetcnt as int);
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
			from rank_result_form
			where description = ''%s'' and ranktype = ''%s''
			  and ymd >= ''%s'' and ymd <= ''%s'' 
			  and bettype = ''%s''
			group by description, bettype, bet_kumiban, pattern, waku
			order by description, bettype, bet_kumiban, pattern, waku
		) tmp
		where hitrate >= %s and incomerate >= %s and betcnt >= %s
	' , paramRankType, paramWaku, varMonths, paramRankType, paramWaku
	  , paramDescription, paramRankType, paramFromYmd, paramToYmd, paramBetType, varMinHitrate, varMinIncomerate, varMinBetcnt
    );
	
  END;
$$ LANGUAGE plpgsql;

 select sub_generate_rank_ext_form('0003', '20170101', '20170331', '2T', 'form2t2_23', 'substring(predict_rank123 from 2 for 2)', '4');
 select count(*) from rank_ext where ranktype = 'form2t2_23';

-- 월별통계
DROP FUNCTION IF EXISTS sub_generate_rank_ext_monthly_form (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100), VARCHAR(3));
CREATE OR REPLACE FUNCTION sub_generate_rank_ext_monthly_form (
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
	-- 월별 통계
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
			  (ntile(%s) over(partition by description, bettype, bet_kumiban, pattern, %s order by ymd, sime))::text ym,
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
	' , paramRankType, paramWaku, varMonths, paramWaku, paramRankType, paramWaku
	  , paramDescription, paramRankType, paramBetType, paramFromYmd, paramToYmd
    );
    
  END;
$$ LANGUAGE plpgsql;

 select sub_generate_rank_ext_monthly_form('0003', '20170101', '20170331', '2T', 'form2t2_23', 'substring(predict_rank123 from 2 for 2)', '4');
 select count(*) from rank_ext_monthly where ranktype = 'form2t2_23';


-- 적중금액 메트릭 준비 데이터
-- 20200620 사용제외
DROP FUNCTION IF EXISTS sub_generate_rank_ext_hit_form (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(10), VARCHAR(100));
CREATE OR REPLACE FUNCTION sub_generate_rank_ext_hit_form (
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
		from rank_result_form_hity res, 
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
				from rank_result_form_hity
				where description = ''%s'' and ranktype = ''%s''
				  and ymd >= ''%s'' and ymd <= ''%s'' 
				  and bettype = ''%s''
			) tmp2, rank_ext ext
			where tmp2.extkey = ext.extkey
			group by tmp2.description, tmp2.bettype, tmp2.bet_kumiban, tmp2.pattern, tmp2.waku, tmp2.extkey
			order by description, bettype, bet_kumiban, pattern, waku
		) tmp
		where res.description = ''%s'' and res.ranktype = ''%s''
		  and res.ymd >= ''%s'' and res.ymd <= ''%s'' 
		  and res.description = tmp.description and res.bettype = tmp.bettype and res.bet_kumiban = tmp.bet_kumiban 
		  and res.pattern = tmp.pattern 
		  and %s = tmp.waku
		group by res.description, res.bettype, res.bet_kumiban, res.pattern, 
		tmp.waku, tmp.avg_hitamt, tmp.dev_hitamt, tmp.min_hitamt, tmp.max_hitamt, tmp.extkey
	' , paramRankType, paramWaku, paramRankType, paramWaku
	  , paramDescription, paramRankType, paramFromYmd, paramToYmd, paramBetType
	  , paramDescription, paramRankType, paramFromYmd, paramToYmd
	  , paramWaku
    );
    
  END;
$$ LANGUAGE plpgsql;

select sub_generate_rank_ext_hit_form('0003', '20170101', '20170331', '2T', 'form2t2_23', 'substring(predict_rank123 from 2 for 2)');
select count(*) from rank_ext_hit where ranktype = 'form2t2_23';
 
select sub_generate_rank_ext_metric('0003', 'form2t2_23', '120');
select count(*) from rank_ext_metric;




