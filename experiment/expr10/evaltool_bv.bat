@echo off

if "%~1"=="" (
  echo usage: graph_harvestor.bat {evalno}
  goto :eof
)

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set type=%1
set tsv_filename=%2

set starttime=%date%_%time%

java  ^
  -cp %CP% com.pengkong.boatrace.exp10.util.EvaluationsIdToolBIG5VIC2 %type% %tsv_filename%

set endtime=%date%_%time%

echo EvaluationsIdToolBIG5VIC2 %tsv_filename%
echo start: %starttime%
echo end  : %endtime%
:eof