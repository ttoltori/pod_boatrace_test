select count(*) from stat_ml_result where description = 'ntile.2'

copy (
select
  hittbl.wrwaku || '_' || hittbl.devi id,
  nirenhukuno,
  betcnt, hitcnt, income, 
  cast( (cast(hitcnt as float)/ cast(betcnt as float) *100) as numeric(10,2)) hitrate,
  cast( (cast(income as float)/ cast(betamt as float) *100) as numeric(10,2)) incomerate,
  (income - betamt) balance,
  cast( cast(betcnt as float) / (365 * 7) as numeric(5,2)) dayilbet  
from 
  (select 
      (win1_rank1_waku || win1_rank2_waku || win2_rank1_waku || win2_rank2_waku) wrwaku,
      ntiledevi.devi_famerank1 devi,
      nirenhukuno, 
      count(nirenhukuno) hitcnt, 
      sum(nirenhukuprize) income
  from 
      rec_race race, rec_fame_rank3 rank3, stat_deviation statdevi, ntile_deviation ntiledevi
  where 
      race.ymd >= '20100101' and race.ymd <= '20161231'
      and race.ymd = rank3.ymd and race.jyocd = rank3.jyocd and race.raceno = rank3.raceno
      and race.ymd = statdevi.ymd and race.jyocd = statdevi.jyocd and race.raceno = statdevi.raceno
      and race.ymd = ntiledevi.ymd and race.jyocd = ntiledevi.jyocd and race.raceno = ntiledevi.raceno
      and nirenhukuno not in ('特払','不成立','発売無')
  group by wrwaku, devi, nirenhukuno
  order by wrwaku, devi, nirenhukuno
  ) hittbl
  ,
  (select 
      (win1_rank1_waku || win1_rank2_waku || win2_rank1_waku || win2_rank2_waku) wrwaku,
      ntiledevi.devi_famerank1 devi, 
      count(nirenhukuno) betcnt, 
      sum(100) betamt
  from 
      rec_race race, rec_fame_rank3 rank3, stat_deviation statdevi, ntile_deviation ntiledevi
  where 
      race.ymd >= '20100101' and race.ymd <= '20161231'
      and race.ymd = rank3.ymd and race.jyocd = rank3.jyocd and race.raceno = rank3.raceno
      and race.ymd = statdevi.ymd and race.jyocd = statdevi.jyocd and race.raceno = statdevi.raceno
      and race.ymd = ntiledevi.ymd and race.jyocd = ntiledevi.jyocd and race.raceno = ntiledevi.raceno
      and nirenhukuno not in ('特払','不成立','発売無')
  group by wrwaku, devi
  order by wrwaku, devi
  ) bettbl
where hittbl.wrwaku = bettbl.wrwaku
  and hittbl.devi = bettbl.devi
--  and cast( (cast(income as float)/ cast(betamt as float) *100) as numeric(10,2)) > 90
--  and (income - betamt) > 0
--  and cast( (cast(hitcnt as float)/ cast(betcnt as float) *100) as numeric(10,2)) > 10
) to 'C:\Dev\workspace\Oxygen\pod_boatrace\test\statistics\ntile10_deviation.csv' with csv