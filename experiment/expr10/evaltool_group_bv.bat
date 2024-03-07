@echo off

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set tsv_filepath=%1

set starttime=%date%_%time%

java  ^
  -cp %CP% com.pengkong.boatrace.exp10.simulation.evaluation.EvaluationSimulLoaderBVFromTsv %tsv_filepath%

set endtime=%date%_%time%

echo EvaluationSimulLoaderBVFromTsv %tsv_filename%
echo start: %starttime%
echo end  : %endtime%
:eof