@echo off

if "%~1"=="" (
  echo usage: graph_harvestor.bat {evalno}
  goto :eof
)

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set graph_dir_in=%1
set eval_dir_in=D:/Dev/experiment/expr10/work
set eval_dir_out=D:/Dev/experiment/expr10/work/3.evaluation_selected
set eval_id=%2

set starttime=%date%_%time%

java  ^
  -cp %CP% com.pengkong.boatrace.exp10.util.EvaluationHarvestor %graph_dir_in% %eval_dir_in% %eval_dir_out% %eval_id%

set endtime=%date%_%time%

echo EvaluationHarvestor %graph_dir_in% %eval_dir_out%/%eval_id%.tsv
echo start: %starttime%
echo end  : %endtime%
:eof