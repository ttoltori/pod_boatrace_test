select min(ym::int), max(ym::int) from rank_ext_monthly;

  
  
-- 월별 통계데이터로부터 월별 잔액데이터를 생성한다.
DROP FUNCTION IF EXISTS monthly_balance_generator ();
CREATE OR REPLACE FUNCTION monthly_balance_generator (
) RETURNS VOID AS $$
    BEGIN
      -- 기존 테이블 삭제
      truncate rank_ext_balance;

      -- rank_ext_balance 생성
      raise info 'insert rank_ext_balance';
      insert into rank_ext_balance
	  select
  		*,
  	    sum(incomeamt) over (partition by description, ranktype, bet_kumiban, pattern order by ym::int) balance
	  from rank_ext_monthly mon;

    END;
$$ LANGUAGE plpgsql;

select monthly_balance_generator();

-- 잔액기울기 테이블 생성 수작업  
20160101 - 20181231 - 20200531 6개월단위분할
truncate rank_ext_slope;
insert into rank_ext_slope
select
  array[slope1,slope2,slope3,slope4,slope5,slope6,slope7,slope8,slope9], tmp1.extkey
from 
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope1
	from rank_ext_balance mon
	where ym::int between 1 and 6
	group by extkey
) tmp1,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope2
	from rank_ext_balance mon
	where ym::int between 7 and 12
	group by extkey
) tmp2,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope3
	from rank_ext_balance mon
	where ym::int between 13 and 18
	group by extkey
) tmp3,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope4
	from rank_ext_balance mon
	where ym::int between 19 and 24
	group by extkey
) tmp4,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope5
	from rank_ext_balance mon
	where ym::int between 25 and 30
	group by extkey
) tmp5,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope6
	from rank_ext_balance mon
	where ym::int between 31 and 36
	group by extkey
) tmp6,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope7
	from rank_ext_balance mon
	where ym::int between 37 and 42
	group by extkey
) tmp7,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope8
	from rank_ext_balance mon
	where ym::int between 43 and 48
	group by extkey
) tmp8,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope9
	from rank_ext_balance mon
	where ym::int between 49 and 53
	group by extkey
) tmp9
where tmp1.extkey = tmp2.extkey and tmp1.extkey = tmp3.extkey and tmp1.extkey = tmp4.extkey
  and tmp1.extkey = tmp5.extkey and tmp1.extkey = tmp6.extkey and tmp1.extkey = tmp7.extkey
  and tmp1.extkey = tmp8.extkey and tmp1.extkey = tmp9.extkey
;



-- 잔액기울기 테이블 생성 수작업  
20160101 - 20181231 - 20200531 6개월단위분할
truncate rank_ext_slope;
insert into rank_ext_slope
select
  array[slope1,0,0,0,slope5,slope6,slope7,slope8,slope9], tmp1.extkey
from 
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope1
	from rank_ext_balance mon
	where ym::int between 1 and 24
	group by extkey
) tmp1,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope5
	from rank_ext_balance mon
	where ym::int between 25 and 30
	group by extkey
) tmp5,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope6
	from rank_ext_balance mon
	where ym::int between 31 and 36
	group by extkey
) tmp6,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope7
	from rank_ext_balance mon
	where ym::int between 37 and 42
	group by extkey
) tmp7,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope8
	from rank_ext_balance mon
	where ym::int between 43 and 48
	group by extkey
) tmp8,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope9
	from rank_ext_balance mon
	where ym::int between 49 and 53
	group by extkey
) tmp9
where tmp1.extkey = tmp5.extkey and tmp1.extkey = tmp6.extkey and tmp1.extkey = tmp7.extkey
  and tmp1.extkey = tmp8.extkey and tmp1.extkey = tmp9.extkey
;


truncate rank_ext_slope;
insert into rank_ext_slope
select
  array[slope1,0,0,0,0,0,slope7,slope8,slope9], tmp1.extkey
from 
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope1
	from rank_ext_balance mon
	where ym::int between 1 and 36
	group by extkey
) tmp1,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope7
	from rank_ext_balance mon
	where ym::int between 37 and 42
	group by extkey
) tmp7,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope8
	from rank_ext_balance mon
	where ym::int between 43 and 48
	group by extkey
) tmp8,
(
	select 
	  extkey, regr_slope(balance, ym::int)::int slope9
	from rank_ext_balance mon
	where ym::int between 49 and 53
	group by extkey
) tmp9
where tmp1.extkey = tmp7.extkey
  and tmp1.extkey = tmp8.extkey and tmp1.extkey = tmp9.extkey
;

truncate rank_ext_slope;
insert into rank_ext_slope
select
  array[slope1,slope2,slope3,slope4,slope5], tmp1.extkey
from 
(
	select 
	  extkey, regr_slope(balance, ym::int)::numeric(10,2) slope1
	from rank_ext_balance mon
	where ym::int between 1 and 80 
	group by extkey
) tmp1,
(
	select 
	  extkey, regr_slope(incomeamt, ym::int)::numeric(10,2) slope2
	from rank_ext_balance mon
	where ym::int between 1 and 80
	group by extkey
) tmp2,
(
	select 
	  extkey, (regr_slope(incomerate, ym::int) * 100)::numeric(10,2) slope3
	from rank_ext_balance mon
	where ym::int between 1 and 80
	group by extkey
) tmp3,
(
	select 
	  extkey, (regr_slope(hitrate, ym::int) * 100)::numeric(10,2) slope4
	from rank_ext_balance mon
	where ym::int between 1 and 80
	group by extkey
) tmp4,
(
	select 
	  extkey, count(1) slope5
	from rank_ext_balance mon
	where ym::int between 1 and 80
	group by extkey
) tmp5
where tmp1.extkey = tmp2.extkey
  and tmp1.extkey = tmp3.extkey and tmp1.extkey = tmp4.extkey and tmp1.extkey = tmp5.extkey
;

select * from rank_ext_balance where extkey = '0022+1T+2+7_5+norm1t_23+0' order by ym::int;

-- 잔액기울기 테이블 생성 수작업  
20160101 - 20181231 - 20200531 6개월단위분할
truncate rank_ext_slope;
insert into rank_ext_slope
select
  array[slope_bal1,0,0,0,0,0,slope_bal7,0,slope_bal9], 
  array[slope_income1,0,0,0,0,0,slope_income7,0,slope_income9], 
  array[intercept_bal1,0,0,0,0,0,intercept_bal7,0,intercept_bal9], 
  array[intercept_income1,0,0,0,0,0,intercept_income7,0,intercept_income9], 
  tmp1.extkey
from 
(
	select 
	  extkey, 
	  regr_slope(balance, ym::int)::numeric(10,2) slope_bal1,
	  regr_slope(incomeamt, ym::int)::numeric(10,2) slope_income1,
	  regr_intercept(balance, ym::int)::numeric(10,2) intercept_bal1,
	  regr_intercept(incomeamt, ym::int)::numeric(10,2) intercept_income1
	from rank_ext_balance mon
	where ym::int between 1 and 36
	group by extkey
) tmp1,
(
	select 
	  extkey, 
	  regr_slope(balance, ym::int)::numeric(10,2) slope_bal7,
	  regr_slope(incomeamt, ym::int)::numeric(10,2) slope_income7,
	  regr_intercept(balance, ym::int)::numeric(10,2) intercept_bal7,
	  regr_intercept(incomeamt, ym::int)::numeric(10,2) intercept_income7
	from rank_ext_balance mon
	where ym::int between 37 and 48
	group by extkey
) tmp2,
(
	select 
	  extkey, 
	  regr_slope(balance, ym::int)::numeric(10,2) slope_bal9,
	  regr_slope(incomeamt, ym::int)::numeric(10,2) slope_income9,
	  regr_intercept(balance, ym::int)::numeric(10,2) intercept_bal9,
	  regr_intercept(incomeamt, ym::int)::numeric(10,2) intercept_income9
	from rank_ext_balance mon
	where ym::int between 49 and 53
	group by extkey
) tmp3
where tmp1.extkey = tmp2.extkey and tmp1.extkey = tmp3.extkey
;

