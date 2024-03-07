select count(*) from stat_ml_result where description = 'ntile.2'


select 
  kumiban, betcnt, hitcnt, betamount, income, 
  cast( (cast(hitcnt as float)/ cast(betcnt as float) *100) as numeric(7,2)) hitrate,
  cast( (cast(income as float)/ cast(betamount as float) *100) as numeric(7,2)) incomerate,
  (income - betamount) balance,
  (betcnt / (365*1)) dayilbet
from
(
	select 
	  kumiban, 
	  sum ( 1 ) betcnt,
	  sum ( case nirenhukuno when kumiban then 1 else 0 end ) hitcnt,
	  sum ( 100 ) betamount,
	  sum ( case nirenhukuno when kumiban then nirenhukuprize else 0 end ) income
	from 
	(
		select tmp.*, odds.odds, odds.rank
		from 
		(
			select
			  race.ymd, race.jyocd, race.raceno, nirenhukuno, nirenhukuprize, ml.kumiban
			from
			  rec_race race, stat_ml_result ml
			where race.ymd >= '20170101' and race.ymd <= '20171231'
			  and race.ymd = ml.ymd and race.jyocd = ml.jyocd and race.raceno = ml.raceno
			  and ml.kumiban <> 'else'
			  and ml.description = 'ntile.2'
		) tmp left outer join rec_odds odds using (ymd, jyocd, raceno, kumiban)
		where odds.bettype = '2F' 
--		and odds.odds >= 2 and odds.odds <= 4
	) tmp1
	group by kumiban
) tmp2 
;

-- 기계학습 예측 결과를 DB로부터 csv로 추출한다.
-- 2F 予想オッズは除外する
copy(
select tmp.*, odds.odds, odds.rank
from 
(
	select
	-- rec_race
	  race.ymd, 
	  race.jyocd, 
	  race.raceno, 
	  sime, 
	  temparature, 
	  weather, 
	  winddirection, 
	  wind, 
	  watertemp, 
	  wave, 
	  grade, 
	  isvenus, 
	  timezone, 
	  turn, 
	  sanrentanno, 
	  sanrentanprize, 
	  sanrentanpopular, 
	  sanrenhukuno, 
	  sanrenhukuprize, 
	  sanrenhukupopular, 
	  nirentanno, 
	  nirentanprize, 
	  nirentanpopular, 
	  nirenhukuno, 
	  nirenhukuprize, 
	  nirenhukupopular, 
	  tansyono, 
	  tansyoprize, 
	  tansyopopular, 
	  kimarite, 
	  wakurank, 
	  levelrank, 
	  resultlevelrank, 
	  nationwiningrank, 
	  nation2winingrank, 
	  nation3winingrank, 
	  localwiningrank, 
	  local2winingrank, 
	  local3winingrank, 
	  motor2rank, 
	  motor3rank, 
	  startexhibitrank, 
	  exhibitrank, 
	  averagestartrank, 
	  fixedEntrance, 
	  ( case 
		  when racetype = '予選' then '予選'
		  when racetype in ('一般戦', '一般') then '一般'
		  when racetype in ('準優勝戦', '準優勝') then '準優勝戦'
		  when racetype = '優勝戦' then '優勝戦'
		  when racetype in ('予選特選', '予選特賞') then '予選特'
		  when racetype like '%選抜%' then '選抜'
		  when racetype in ('特選', '特賞') then '特'
		  else 'else' end ) racetype1, 
	  wakuLevelList, 
	  aLevelCount, 
	  femaleCount, 
	  avgstcondrank, 
	  setuwinrank, 
	  flrank, 
	-- stat_ml_result
	  ml.kumiban,
	  ( case nirenhukuno 
	      when ml.kumiban then 'Y' else 'N' 
	    end
	  ) hit,
	-- ntile_fame_rank3
	-- stat_race
	  recentnationwiningrank, 
	  recentnation2winingrank, 
	  recentnation3winingrank, 
	  recentlocalwiningrank, 
	  recentlocal2winingrank, 
	  recentlocal3winingrank, 
	  recentavgstrank, 
	  recentavgtimerank, 
	  recentmotor2winingrank, 
	  recentmotor3winingrank, 
	  statnationwiningrank, 
	  statnation2winingrank, 
	  statnation3winingrank, 
	  statlocalwiningrank, 
	  statlocal2winingrank, 
	  statlocal3winingrank, 
	  statmotor2winingrank, 
	  statmotor3winingrank, 
	  statstartrank, 
	  racerwiningrank, 
	  racer2winingrank, 
	  racer3winingrank, 
	  motorwiningrank, 
	  motor2winingrank, 
	  motor3winingrank, 
	-- ntile_deviation
--	  devi_famewin1, 
--	  devi_famewin2, 
--	  devi_famewin3, 
	  devi_famerank1, 
	  devi_famerank2, 
	  devi_famerank3, 
--	  devi_winingrate_12, 
--	  devi_winingrate_23, 
--	  devi_winingrate_14, 
--	  devi_winingrate_123, 
	  devi_winingrate_123456
	from
	  rec_race race, rec_race_waku waku, rec_race_waku2 waku2, 
	  ntile_fame_rank3 famerank, stat_race statrank, ntile_deviation devi, stat_ml_result ml
	where race.ymd >= '20170101' and race.ymd <= '20171231'
	  and race.ymd = waku.ymd and race.jyocd = waku.jyocd and race.raceno = waku.raceno
	  and race.ymd = waku2.ymd and race.jyocd = waku2.jyocd and race.raceno = waku2.raceno
	  and race.ymd = famerank.ymd and race.jyocd = famerank.jyocd and race.raceno = famerank.raceno
	  and race.ymd = statrank.ymd and race.jyocd = statrank.jyocd and race.raceno = statrank.raceno
	  and race.ymd = devi.ymd and race.jyocd = devi.jyocd and race.raceno = devi.raceno
	  and race.ymd = ml.ymd and race.jyocd = ml.jyocd and race.raceno = ml.raceno
	  and nirenhukuno not in ('特払','不成立','発売無')
      and ml.description = 'ntile.2' and ml.bettype = '2F'
	order by race.ymd, race.sime
) tmp left outer join rec_odds odds using (ymd, jyocd, raceno, kumiban)
where odds.bettype = '2F' 
) to 'C:\Dev\workspace\Oxygen\pod_boatrace\src\statistics\boatstat\ntile_analysis\2.ntile10_deviation_result.csv' with csv
;


race.ymd
race.jyocd
race.raceno
sime
temparature
weather
winddirection
wind
watertemp
wave
grade
isvenus
timezone
turn
sanrentanno
sanrentanprize
sanrentanpopular
sanrenhukuno
sanrenhukuprize
sanrenhukupopular
nirentanno
nirentanprize
nirentanpopular
nirenhukuno
nirenhukuprize
nirenhukupopular
tansyono
tansyoprize
tansyopopular
kimarite
wakurank
levelrank
resultlevelrank
nationwiningrank
nation2winingrank
nation3winingrank
localwiningrank
local2winingrank
local3winingrank
motor2rank
motor3rank
startexhibitrank
exhibitrank
averagestartrank
fixedEntrance
racetype1
wakuLevelList
aLevelCount
femaleCount
avgstcondrank
setuwinrank
flrank
ml.kumiban,
hit,
recentnationwiningrank
recentnation2winingrank
recentnation3winingrank
recentlocalwiningrank
recentlocal2winingrank
recentlocal3winingrank
recentavgstrank
recentavgtimerank
recentmotor2winingrank
recentmotor3winingrank
statnationwiningrank
statnation2winingrank
statnation3winingrank
statlocalwiningrank
statlocal2winingrank
statlocal3winingrank
statmotor2winingrank
statmotor3winingrank
statstartrank
racerwiningrank
racer2winingrank
racer3winingrank
motorwiningrank
motor2winingrank
motor3winingrank
devi_famerank1
devi_famerank2
devi_famerank3
devi_winingrate_123456

	 