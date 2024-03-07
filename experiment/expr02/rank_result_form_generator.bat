@echo off

if "%~3"=="" (
  echo usage: command {targetDb} {fromYmd} {toYmd}
  goto :eof
)

cd /d %~dp0

set target_db=%1
set from_ymd=%2
set to_ymd=%3


set starttime=%date%_%time%

echo "%target_db% select rank_table_generator_form2t2('%from_ymd%', '%to_ymd%', 'form2t2_23')"
psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_table_generator_form2t2('%from_ymd%', '%to_ymd%', 'form2t2_23')"
  
echo "%target_db% select rank_table_generator_form3t4('%from_ymd%', '%to_ymd%', 'form3t4_3')"
psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_table_generator_form3t4('%from_ymd%', '%to_ymd%', 'form3t4_3')"

echo "%target_db% select rank_table_generator_form3t8('%from_ymd%', '%to_ymd%', 'form3t8_23')"
psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_table_generator_form3t8('%from_ymd%', '%to_ymd%', 'form3t8_23')"

set endtime=%date%_%time%

echo rank_result_form_generator %1 %2 %3
echo start: %starttime%
echo end  : %endtime%

:eof