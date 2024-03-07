DROP FUNCTION IF EXISTS rank_filter_generator (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(10));
CREATE OR REPLACE FUNCTION rank_filter_generator (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramRankType VARCHAR(10)
) RETURNS VOID AS $$
  DECLARE
    varWaku VARCHAR(100); 
  BEGIN
    -- 기존 테이블 삭제
    delete from stmp_rank_ext;
    delete from stmp_rank_ext_monthly;
    
    -- 랭크 와꾸 패턴 취득
    if paramRankType in ('norm1t_23', 'form2t2_23', 'form3t8_23') then
      varWaku := 'substring(predict_rank123 from 2 for 2)';
    elsif paramRankType in ('norm2f_12') then
      varWaku := 'substring(predict_rank123 from 1 for 2)';
    elsif paramRankType in ('norm2t_3', 'form3t4_3') then
      varWaku := 'substring(predict_rank123 from 3 for 1)';
    elsif paramRankType in ('norm3f_123') then
      varWaku := 'predict_rank123';
    elsif paramRankType in ('norm3t_0') then
      varWaku := '0::text';
    end if;

	if substring(paramRankType from 1 for 4) = 'norm' then
	  perform rank_ext_generator_norm(paramDescription, paramFromYmd, paramToYmd, paramRankType, varWaku);
	elseif substring(paramRankType from 1 for 4) = 'form' then
	  perform rank_ext_generator_form(paramDescription, paramFromYmd, paramToYmd, paramRankType, varWaku);
	end if;
	
  END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS sub_filter_indev_plusmon(VARCHAR(20), VARCHAR(4), VARCHAR(50), VARCHAR(50), VARCHAR(50));
CREATE OR REPLACE FUNCTION sub_filter_indev_plusmon (
paramRankType VARCHAR(20),
paramBetKumiban VARCHAR(4),
paramRangeIndevHitamtRate VARCHAR(50),
paramRangePlusMonthRate VARCHAR(50),
paramCondition VARCHAR(50)
) RETURNS VOID AS $$
  DECLARE
	varArrIndevHitamtRate numeric(7,2)[];
	varArrPlusMonthRate numeric(7,2)[];
  BEGIN
	select into varArrIndevHitamtRate string_to_array(paramRangeIndevHitamtRate, '~')::numeric(7,2)[];
	select into varArrPlusMonthRate string_to_array(paramRangePlusMonthRate, '~')::numeric(7,2)[];
  
	-- 기존 동일 조건의 필터레코드 삭제
	delete from rank_filter where condition = paramCondition;
	
	-- rank_filter추가
	insert into rank_filter
	select 
	  ext.description, ext.bettype, ext.bet_kumiban, ext.pattern, ext.ranktype, ext.waku, ext.extkey, paramCondition
	from stmp_rank_ext ext, rank_ext_metric met
	where ext.ranktype = paramRankType and ext.bet_kumiban = paramBetKumiban
		and ext.extkey = met.extkey
		-- and indev_hitamt_rate >= varArrIndevHitamtRate[1] and indev_hitamt_rate <= varArrIndevHitamtRate[2]
		and plus_month_rate >= varArrPlusMonthRate[1] and plus_month_rate <= varArrPlusMonthRate[2]
		-- and ext.hitrate >= 0.4
		-- and ext.bet_months >= 25
		and ext.incomerate >= 0.9
		and met.betdays_rate >= 0.3
		-- and met.slope_monthly_income >= 0
	;
	
  END;
$$ LANGUAGE plpgsql;

select sub_filter_indev_plusmon('norm1t_23', '1', '0.55~0.99', '0.4~0.99', 'test1' );
select sub_filter_indev_plusmon('norm1t_23', '2', '0.55~0.99', '0.4~0.99', 'test1' );
select sub_filter_indev_plusmon('norm1t_23', '4', '0.55~0.99', '0.4~0.99', 'test1' );
select sub_filter_indev_plusmon('norm1t_23', '5', '0.55~0.99', '0.4~0.99', 'test1' );
select sub_filter_indev_plusmon('form2t2_23', '1=', '0.55~0.99', '0.5~0.99', 'test1' );
select sub_filter_indev_plusmon('form2t2_23', '2=', '0.55~0.99', '0.5~0.99', 'test1' );

select sub_filter_indev_plusmon('norm2t_3', '12', '0.55~0.99', '0.3~0.99', 'test1' );

select sub_filter_indev_plusmon('norm2t_3', '13', '0.55~0.99', '0.3~0.99', 'test1' );

select sub_filter_indev_plusmon('norm2t_3', '21', '0.55~0.99', '0.2~0.99', 'test1' );

select sub_filter_indev_plusmon('form3t4_3', '12=', '0.01~0.99', '0.4~0.99', 'test1' );

select sub_filter_indev_plusmon('form3t8_23', '1==', '0.01~0.75', '0.51~0.99', 'test1' );

select sub_filter_indev_plusmon('norm3t_0', '123', '0.55~0.99', '0.2~0.99', 'test1' );

select sub_filter_indev_plusmon('norm2f_12', '12', '0.55~0.99', '0.51~0.99', 'test1' );

select sub_filter_indev_plusmon('norm3t_0', '126', '0.75~0.99', '0.2~0.99', 'test1' );


truncate rank_filter;
truncate run_rank_result;
truncate run_rank_result_ptn;



truncate rank_ext;
truncate rank_ext_monthly;
truncate rank_ext_hit;
truncate rank_ext_bet;
truncate rank_ext_metric;
