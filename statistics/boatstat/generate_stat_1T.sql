DROP FUNCTION IF EXISTS generate_stat_1T(VARCHAR(8), VARCHAR(8), VARCHAR(3), VARCHAR(3), VARCHAR(120), 
int, numeric(5,2), numeric(5,2), VARCHAR(3), VARCHAR(120));
CREATE OR REPLACE FUNCTION generate_stat_1T(
paramFromYmd  VARCHAR(8),
paramToYmd VARCHAR(8), 
paramBettype VARCHAR(3),
paramBettype2 VARCHAR(3),
paramPattern VARCHAR(120),
paramMinPatternCnt int, 
paramMinHitRate numeric(5,2), 
paramMinIncomeRate numeric(5,2),
paramKumiban VARCHAR(3),
paramPath VARCHAR(120))
RETURNS VOID AS $$
  BEGIN
  
    truncate zen_pattern;
    truncate zen_race;
    truncate zen_stat;
    
    EXECUTE format ('
		insert into zen_pattern
		select 
		  ''%s'' || ''_'' || ''%s'' bettype, 
		  %s pattern,
		  count(%s) patterncnt,
		  (count(%s) * 100) betamount
		from rec_race race
		where race.ymd >= ''%s'' and race.ymd <= ''%s''
--          and race.tansyono = ( ''%s'')
		group by bettype, pattern
		order by bettype, pattern
	', paramBettype, paramBettype2, paramPattern, paramPattern, paramPattern,  paramFromYmd, paramToYmd, paramKumiban);
	
    
	EXECUTE format ('
		insert into zen_race
		select 
		  ''%s'' || ''_'' || ''%s'' bettype, 
		  %s pattern,
	      race.tansyono kumiban, 
		  count(%s) hitcnt,
          sum(race.tansyoprize) prize
		from rec_race race
		where race.ymd >= ''%s'' and race.ymd <= ''%s''
--          and race.tansyono = ( ''%s'')
        group by bettype, pattern, kumiban
		order by bettype, pattern, kumiban
    ', paramBettype, paramBettype2, paramPattern, paramPattern, paramFromYmd, paramToYmd, paramKumiban);

    insert into zen_stat
    select *, cast( (hitrate * incomerate) as numeric(7,2) ) avgincomerate
    from 
    (
	    select
	      r.bettype,
	      r.pattern,
	      r.kumiban,
	      p.patterncnt,
	      p.betamount,
	      r.hitcount,
	      r.prize,
	      cast( (cast(r.hitcount as float) / cast(p.patterncnt as float) ) as numeric(7,2) ) hitrate,
	      cast( (cast(r.prize as float) / cast(p.betamount as float) ) as numeric(7,2) ) incomerate
	    from
	      zen_pattern p, zen_race r
	    where
	      p.bettype = r.bettype
	      and p.pattern = r.pattern
    ) zen_tmp
    order by avgincomerate desc, hitrate desc; 
    
    EXECUTE format('copy 
      (select * from zen_stat 
        where bettype = ''%s'' || ''_'' || ''%s''
          and (patterncnt >= %s)
          and (hitrate >= %s)
          and (avgincomerate >= %s)
		order by avgincomerate desc, hitrate desc
      ) 
      to ''%s'' with csv'
     ,paramBettype, paramBettype2
     ,paramMinPatternCnt
     ,paramMinHitRate
     ,paramMinIncomeRate
     ,paramPath || paramToYmd || '_stat_' || paramBettype || '_' || paramBettype2 || '_' || paramKumiban || '_' ||  
       paramMinPatternCnt || '_' || paramMinHitRate || '_' || paramMinIncomeRate || '.csv' );
     
  END;
$$ LANGUAGE plpgsql;

