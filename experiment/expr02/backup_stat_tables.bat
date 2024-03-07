@echo off

if "%~2"=="" (
  echo usage: command {targetdb} {directory} 
  goto :eof
)

cd /d %~dp0

set target_db=%1
set directory=%2

set starttime=%date%_%time%

echo copying rank_model
psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
  "copy (select * from rank_model) to '%directory%rank_model.tsv' csv delimiter E'\t' header"

echo copying rank_ext
psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
  "copy (select * from rank_ext) to '%directory%rank_ext.tsv' csv delimiter E'\t' header"

rem 20200620 사용제외
REM echo copying rank_ext_hit
REM psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
REM   "copy (select * from rank_ext_hit) to '%directory%rank_ext_hit.tsv' csv delimiter E'\t' header"

echo copying rank_ext_metric
psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
  "copy (select * from rank_ext_metric) to '%directory%rank_ext_metric.tsv' csv delimiter E'\t' header"

REM 20200713 rank_ext_balance로대체
REM echo copying rank_ext_monthly
REM psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
REM  "copy (select * from rank_ext_monthly) to '%directory%rank_ext_monthly.tsv' csv delimiter E'\t' header"

echo copying rank_ext_balance
psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
  "copy (select * from rank_ext_balance) to '%directory%rank_ext_balance.tsv' csv delimiter E'\t' header"

echo copying rank_ext_slope
psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
  "copy (select * from rank_ext_slope) to '%directory%rank_ext_slope.tsv' csv delimiter E'\t' header"

set endtime=%date%_%time%

echo backup_stat_tables %1 %2
echo start: %starttime%
echo end  : %endtime%

:eof