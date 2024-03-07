@echo off

if "%~2"=="" (
  echo usage: command {targetdb} {directory} 
  goto :eof
)

cd /d %~dp0

set target_db=%1
set directory=%2

set starttime=%date%_%time%

echo copying rank_result, rank_result_form
psql -h localhost -U postgres -d %target_db% -p 55432 -c ^
  "select copyto_rank_result('%directory%')"

set endtime=%date%_%time%

echo backup_result_tables %1 %2
echo start: %starttime%
echo end  : %endtime%

:eof