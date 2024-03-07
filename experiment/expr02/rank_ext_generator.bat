@echo off
REM 실행조건:rank_result_form_generator.bat가 사전에 실행되어야 한다. 

if "%~7"=="" (
  echo usage: command {targetDb} {description} {fromYmd} {toYmd} {ranktype} {months} {minBetcnt}
  goto :eof
)

cd /d %~dp0

set target_db=%1
set description=%2
set from_ymd=%3
set to_ymd=%4
set ranktype=%5
set months=%6
set min_betcnt=%7

set starttime=%date%_%time%

if %ranktype% == all (
  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm1t_23', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm1t_23', '%months%', '%min_betcnt%')"
  
  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm2f_123', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm2f_123', '%months%', '%min_betcnt%')"

  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm2t_3', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm2t_3', '%months%', '%min_betcnt%')"

  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm3f_123', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm3f_123', '%months%', '%min_betcnt%')"

  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm3t_0', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'norm3t_0', '%months%', '%min_betcnt%')"

  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'form2t2_23', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'form2t2_23', '%months%', '%min_betcnt%')"

  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'form3t4_3', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'form3t4_3', '%months%', '%min_betcnt%')"

  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'form3t8_23', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', 'form3t8_23', '%months%', '%min_betcnt%')"

) else (
  echo "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', '%ranktype%', '%months%', '%min_betcnt%')"
  psql -h localhost -U postgres -d %target_db% -p 55432 -c "select rank_ext_generator('%description%', '%from_ymd%', '%to_ymd%', '%ranktype%', '%months%', '%min_betcnt%')"
)

set endtime=%date%_%time%

echo rank_ext_generator %1 %2 %3 %4 %5 %6 %7
echo start: %starttime%
echo end  : %endtime%

:eof