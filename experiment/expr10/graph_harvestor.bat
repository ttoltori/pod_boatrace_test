@echo off

if "%~1"=="" (
  echo usage: graph_harvestor.bat {evalno}
  goto :eof
)

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set eval_dir=D:/Dev/experiment/expr10/work/groups_store
set eval_id=%1
set in_dir=D:/Dev/experiment/expr10/result
set out_dir=D:/Dev/experiment/expr10/work/graph

set starttime=%date%_%time%

java  ^
  -cp %CP% com.pengkong.boatrace.exp10.util.GraphHarvestor %eval_dir% %eval_id% %in_dir% %out_dir%

set endtime=%date%_%time%

echo GraphHarvestor %eval_dir%%eval_id%.tsv %in_dir% %out_dir%
echo start: %starttime%
echo end  : %endtime%
:eof