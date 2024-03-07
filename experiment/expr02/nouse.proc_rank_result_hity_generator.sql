-- 적중금액 평균편차 계산용 적중된것만 발췌한 결과테이블 생성 
-- 20200620 사용제외
DROP FUNCTION IF EXISTS rank_table_generator_hity (VARCHAR(8), VARCHAR(8));
CREATE OR REPLACE FUNCTION rank_table_generator_hity (
paramFromYmd VARCHAR(8),
paramToYmd VARCHAR(8)
) RETURNS VOID AS $$
  DECLARE
    rec RECORD;
  BEGIN
	-- 적중금액 평균편차 계산용 적중한 것만 발췌한 테이블 재생성
	raise info 'insert rank_result_hity';
	
	truncate rank_result_hity;
	
	insert into rank_result_hity 
	select * from rank_result res 
	where res.ymd >= paramFromYmd and res.ymd <= paramToYmd
	  and hity=1;

	-- 포메이션 투표 적중금액 평균편차 계산용 적중한 것만 발췌한 테이블 재생성
	raise info 'insert rank_result_form_hity';
	
	truncate rank_result_form_hity;
	
	insert into rank_result_form_hity 
	select * from rank_result_form res 
	where res.ymd >= paramFromYmd and res.ymd <= paramToYmd
	  and hity=1;
	
END;
$$ LANGUAGE plpgsql;

