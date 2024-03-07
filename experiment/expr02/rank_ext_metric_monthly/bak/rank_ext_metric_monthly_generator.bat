@echo off

if "%~4"=="" (
  echo usage: command {description} {fromYmd} {toYmd} {ranktype}
  goto :eof
)

cd /d %~dp0

set description=%1
set from_ymd=%2
set to_ymd=%3
set ranktype=%4

set starttime=%date%_%time%

psql -h localhost -U postgres -d boatstat -p 55432 -c ^
  "select rank_ext_metric_monthly_%ranktype%('%description%', '%from_ymd%', '%to_ymd%')"

set endtime=%date%_%time%

echo rank_ext_metric_monthly_generator %1 %2 %3 %4
echo start: %starttime%
echo end  : %endtime%

:eof