DROP FUNCTION IF EXISTS rank_ext_generator (VARCHAR(10), VARCHAR(8), VARCHAR(8), VARCHAR(10), VARCHAR(3), VARCHAR(3));
CREATE OR REPLACE FUNCTION rank_ext_generator (
paramDescription VARCHAR(10),
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramRankType VARCHAR(10),
paramMonths VARCHAR(3), -- 월별 통계 테이블의 분할 단위 수 (월수)
paramMinBetcnt VARCHAR(3) -- 최소 베팅수
) RETURNS VOID AS $$
  DECLARE
    token VARCHAR(10)[]; 
    varWaku VARCHAR(100); 
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

	if substring(paramRankType from 1 for 4) = 'norm' then
	  perform rank_ext_generator_norm(paramDescription, paramFromYmd, paramToYmd, paramRankType, varWaku, paramMonths, paramMinBetcnt);
	elseif substring(paramRankType from 1 for 4) = 'form' then
	  perform rank_ext_generator_form(paramDescription, paramFromYmd, paramToYmd, paramRankType, varWaku, paramMonths, paramMinBetcnt);
	end if;
	
  END;
$$ LANGUAGE plpgsql;

select rank_ext_generator('0003', '20170801', '20171231', 'norm1t_23');
select count(*) from rank_ext_metric where ranktype = 'norm1t_23';

select rank_ext_generator('0003', '20170801', '20171231', 'form2t2_23');
select count(*) from rank_ext_metric where ranktype = 'form2t2_23';

select rank_ext_generator('0003', '20170801', '20171231', 'form3t8_23');
select count(*) from rank_ext_metric where ranktype = 'form3t8_23';

select rank_ext_generator('0003', '20170801', '20171231', 'norm2f_12');
select count(*) from rank_ext_metric where ranktype = 'norm2f_12';

select rank_ext_generator('0003', '20170801', '20171231', 'norm2t_3');
select count(*) from rank_ext_metric where ranktype = 'norm1t_23';

select rank_ext_generator('0003', '20170801', '20171231', 'form3t4_3');
select count(*) from rank_ext_metric where ranktype = 'norm1t_23';

select rank_ext_generator('0003', '20170801', '20171231', 'norm3f_123');
select count(*) from rank_ext_metric where ranktype = 'norm3f_123';

select rank_ext_generator('0003', '20170801', '20171231', 'norm3t_0');
select count(*) from rank_ext_metric where ranktype = 'norm3t_0';



truncate rank_ext;
truncate rank_ext_monthly;
truncate rank_ext_hit;
truncate rank_ext_metric;
truncate rank_result_form;
truncate rank_result_hity;
truncate rank_result_form_hity;

select coutn(*) from rank_ext;
select coutn(*) from rank_ext_monthly;



