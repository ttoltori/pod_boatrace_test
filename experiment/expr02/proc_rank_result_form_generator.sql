-- 포메이션투표용 결과테이블 생성 2T 두개 투표
--   랭크2와2이 다르면 랭크1-2 랭크1-3 두개를 투표한다.
-- paramRankType= form2t2_23 or form2t2_234
DROP FUNCTION IF EXISTS rank_table_generator_form2t2 (VARCHAR(8), VARCHAR(8), VARCHAR(20));
CREATE OR REPLACE FUNCTION rank_table_generator_form2t2 (
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramRankType VARCHAR(20)
) RETURNS VOID AS $$
  DECLARE
    rec RECORD;
    paramBetType VARCHAR(10);
  BEGIN
    paramBetType := '2T';
    
	-- 포메이션 투표용 임시 결과테이블 생성
	raise info 'insert rank_result_form';
	delete from rank_result_form where ranktype = paramRankType and ymd >= paramFromYmd and ymd <= paramToYmd;
	insert into rank_result_form
	select
	  ymd, sime, jyocd, raceno, description, pattern,
	  paramBetType, 
	  paramRankType, 
	  predict_rank123, result_rank123, 
	  (bet_kumiban || '=') bet_kumiban,
	  bet_odds, bet_oddsrank, 
	  (result_kumiban || '=') result_kumiban,
	  result_odds, result_oddsrank,
	  nirentanprize result_amt,
	  (case when ( substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) or
	  			   (substring(predict_rank123 from 1 for 1) || substring(predict_rank123 from 3 for 1)) = substring(result_rank123 from 1 for 2)
	  			 ) 
	      then 1 else 0 end
	  ) hity,
	  (case when ( substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) or
	  			   (substring(predict_rank123 from 1 for 1) || substring(predict_rank123 from 3 for 1)) = substring(result_rank123 from 1 for 2)
	  			 ) 
	      then 0 else 1 end
	  ) hitn,
	  200 betamt,
	  (case when ( substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) or
	  			   (substring(predict_rank123 from 1 for 1) || substring(predict_rank123 from 3 for 1)) = substring(result_rank123 from 1 for 2)
	  			 ) 
	      then nirentanprize else 0 end
	  ) hitamt,
	  '' duplicate
	from
	(
		select 
		  res.*,
		  race.nirentanprize
		from rank_result res, rec_race race
		where res.ymd = race.ymd and res.jyocd = race.jyocd and res.raceno = race.raceno
		  and bettype = '1T'  and tansyono not in ('特払','不成立','発売無')
		  and (
		    (substring(predict_rank123 from 1 for 1) <> substring(predict_rank123 from 2 for 1)) and
		    (substring(predict_rank123 from 2 for 1) <> substring(predict_rank123 from 3 for 1)) and
		    (substring(predict_rank123 from 1 for 1) <> substring(predict_rank123 from 3 for 1)) -- 20200107
		  )
		  and res.ymd >= paramFromYmd and res.ymd <= paramToYmd
	) result
	order by ymd, sime;

  END;
$$ LANGUAGE plpgsql;

select rank_table_generator_form2t2_23('2001', '20170101', '20191129', 'form2t2_234');
select count(*) from rank_result_form where description = '2001' and ranktype = 'form2t2_234';


-- 포메이션투표용 결과테이블 생성 3T 네개 투표
--   2T투표로 랭크12가 정해진 상태에서 랭크3 네개를 투표한다.
-- paramRankType= form3t4_3 or form3t4_34
DROP FUNCTION IF EXISTS rank_table_generator_form3t4 (VARCHAR(8), VARCHAR(8), VARCHAR(20));
CREATE OR REPLACE FUNCTION rank_table_generator_form3t4 (
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramRankType VARCHAR(20)
) RETURNS VOID AS $$
  DECLARE
    rec RECORD;
    paramBetType VARCHAR(10);
  BEGIN
    paramBetType := '3T';
    
	-- 포메이션 투표용 임시 결과테이블 생성
	raise info 'insert rank_result_form';
	delete from rank_result_form where ranktype = paramRankType and ymd >= paramFromYmd and ymd <= paramToYmd;
	insert into rank_result_form
	select
	  ymd, sime, jyocd, raceno, description, pattern,
	  paramBetType, 
	  paramRankType, 
	  predict_rank123, result_rank123, 
	  (bet_kumiban || '=') bet_kumiban,
	  bet_odds, bet_oddsrank, 
	  (result_kumiban || '=') result_kumiban,
	  result_odds, result_oddsrank,
	  sanrentanprize result_amt,
	  (case when substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) then 1 else 0 end) hity,
	  (case when substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) then 0 else 1 end) hitn,
	  400 betamt,
	  (case when substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) then sanrentanprize else 0 end) hitamt,
	  '' duplicate
	from
	(
		select 
		  res.*,
		  race.sanrentanprize
		from rank_result res, rec_race race
		where res.ymd = race.ymd and res.jyocd = race.jyocd and res.raceno = race.raceno
		  and bettype = '2T'  and nirentanno not in ('特払','不成立','発売無')
		  and res.ymd >= paramFromYmd and res.ymd <= paramToYmd
	) result
	order by ymd, sime;
	
  END;
$$ LANGUAGE plpgsql;

select rank_table_generator_form3t4_3('2001', '20170101', '20191129', 'form3t4_3');
select count(*) from rank_result_form where description = '2001' and ranktype = 'form3t4_3';


-- 포메이션투표용 결과테이블 생성 3T 여덟개 투표
--   1T투표로 랭크1이 정해진 상태에서, 랭크2,3이 다른경우  랭크12네개, 랭크13네개 총 여덟개를 투표한다.
-- paramRankType= form3t8_23 or form3t8_234
DROP FUNCTION IF EXISTS rank_table_generator_form3t8 (VARCHAR(8), VARCHAR(8), VARCHAR(20));
CREATE OR REPLACE FUNCTION rank_table_generator_form3t8 (
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8),
paramRankType VARCHAR(20)
) RETURNS VOID AS $$
  DECLARE
    rec RECORD;
    paramBetType VARCHAR(10);
  BEGIN
    paramBetType := '3T';
    
	-- 포메이션 투표용 임시 결과테이블 생성
	raise info 'insert rank_result_form';
	delete from rank_result_form where ranktype = paramRankType and ymd >= paramFromYmd and ymd <= paramToYmd;
	insert into rank_result_form
	select
	  ymd, sime, jyocd, raceno, description, pattern,
	  paramBetType, 
	  paramRankType, 
	  predict_rank123, result_rank123, 
	  (bet_kumiban || '==') bet_kumiban,
	  bet_odds, bet_oddsrank, 
	  (result_kumiban || '==') result_kumiban,
	  result_odds, result_oddsrank,
	  sanrentanprize result_amt,
	  (case when ( substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) or
	  			   (substring(predict_rank123 from 1 for 1) || substring(predict_rank123 from 3 for 1)) = substring(result_rank123 from 1 for 2)
	  			 ) 
	      then 1 else 0 end
	  ) hity,
	  (case when ( substring(predict_rank123 from 1 for 2) <> substring(result_rank123 from 1 for 2) or
	  			   (substring(predict_rank123 from 1 for 1) || substring(predict_rank123 from 3 for 1)) = substring(result_rank123 from 1 for 2)
	  			 ) 
	      then 0 else 1 end
	  ) hitn,
	  800 betamt,
	  (case when ( substring(predict_rank123 from 1 for 2) = substring(result_rank123 from 1 for 2) or
	  			   (substring(predict_rank123 from 1 for 1) || substring(predict_rank123 from 3 for 1)) = substring(result_rank123 from 1 for 2)
	  			 ) 
	      then sanrentanprize else 0 end
	  ) hitamt,
	  '' duplicate
	from
	(
		select 
		  res.*,
		  race.sanrentanprize
		from rank_result res, rec_race race
		where res.ymd = race.ymd and res.jyocd = race.jyocd and res.raceno = race.raceno
		  and bettype = '1T' and tansyono not in ('特払','不成立','発売無') 
		  and (
		    (substring(predict_rank123 from 1 for 1) <> substring(predict_rank123 from 2 for 1)) and
		    (substring(predict_rank123 from 2 for 1) <> substring(predict_rank123 from 3 for 1)) and
		    (substring(predict_rank123 from 1 for 1) <> substring(predict_rank123 from 3 for 1)) -- 20200107
		  )
		  and res.ymd >= paramFromYmd and res.ymd <= paramToYmd
	) result
	order by ymd, sime;

END;
$$ LANGUAGE plpgsql;

select rank_table_generator_form3t8_23('2001', '20170101', '20191129', 'form3t8_23');
select count(*) from rank_result_form where  description = '2001' and ranktype = 'form3t8_23';

