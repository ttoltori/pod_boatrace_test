truncate rank_pattern;

insert into rank_pattern
select 
  'jyocd' pattern_name, 
  race.jyocd pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+alevelcount' pattern_name, 
  jyocd || '_' || alevelcount
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+level1' pattern_name, 
  jyocd || '_' || substring(race.wakulevellist from 1 for 2)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+mm' pattern_name, 
  jyocd || '_' || substring(race.ymd from 5 for 2)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+raceno' pattern_name, 
  jyocd || '_' || raceno
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+racetype' pattern_name, 
  jyocd || '_' || racetype_simple
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+timezone' pattern_name, 
  jyocd || '_' || timezone
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+turn' pattern_name, 
  jyocd || '_' || turn
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'level1234' pattern_name, 
  substring(race.wakulevellist from 1 for 11) 
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'nopattern' pattern_name, 
  'nopattern'
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'raceno' pattern_name, 
  raceno::text
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'racetype' pattern_name, 
  racetype_simple
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'racetype+alevelcount' pattern_name, 
  racetype_simple  || '_' || alevelcount
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

delete from rank_pattern where pattern_name = 'racetype+level12';
insert into rank_pattern
select 
  'racetype+level12' pattern_name, 
  racetype_simple  || '_' || substring(race.wakulevellist from 1 for 5)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn' pattern_name, 
  turn
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+alevelcount' pattern_name, 
  turn || '_' || alevelcount
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+alevelcount+level1' pattern_name, 
  turn || '_' || alevelcount  || '_' || substring(race.wakulevellist from 1 for 2)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+apos' pattern_name, 
  turn  || '_' || 
    ( 
      (case when substring(wakulevellist from 1 for 1) = 'A' then '1' else '0' end) || 
      (case when substring(wakulevellist from 4 for 1) = 'A' then '1' else '0' end) || 
      (case when substring(wakulevellist from 7 for 1) = 'A' then '1' else '0' end) || 
      (case when substring(wakulevellist from 10 for 1) = 'A' then '1' else '0' end) 
    ) 
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+level1' pattern_name, 
  turn || '_' || substring(race.wakulevellist from 1 for 2)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+level12' pattern_name, 
  turn || '_' || substring(race.wakulevellist from 1 for 5)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+raceno' pattern_name, 
  turn || '_' || raceno
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+racetype' pattern_name, 
  turn || '_' || racetype_simple
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+rank1+level1' pattern_name, 
  turn || '_' || substring(nationwiningrank from 1 for 1)  || '_' || substring(wakulevellist from 1 for 2)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'turn+timezone' pattern_name, 
  turn || '_' || timezone
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;

insert into rank_pattern
select 
  'jyocd+level12' pattern_name, 
  jyocd || '_' || substring(race.wakulevellist from 1 for 5)
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;;

insert into rank_pattern
select 
  'nation123rank' pattern_name, 
  substring(nationwiningrank from 1 for 1 ) || '_' || substring(nation2winingrank from 1 for 1 ) || '_' || substring(nation3winingrank from 1 for 1 )
  pattern,
  count(1) betcnt
from rec_race race group by pattern_name, pattern order by pattern_name, pattern;


===========================================
copy (
  select * from rank_pattern order by pattern_name, pattern, betcnt
) to 'C:\Dev\workspace\Oxygen\pod_boatrace_test\experiment\expr02\rank_pattern.csv' csv; 

copy (
  select 
    description, pattern_name, attributes, algorithm, training_days
  from rank_model order by description
) to 'C:\Dev\workspace\Oxygen\pod_boatrace_test\experiment\expr02\rank_model.csv' csv; 


