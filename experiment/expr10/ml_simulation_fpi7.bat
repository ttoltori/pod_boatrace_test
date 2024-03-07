@echo off

if "%~1"=="" (
  echo usage: command {comma seperated experiment no list} 
  goto :eof
)

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set exno_list=%1

set starttime=%date%_%time%

java -Xmx8048m ^
  -cp %CP% com.pengkong.boatrace.exp10.MLSimulationGeneratorFPI7 C:/Dev/github/pod_boatrace/properties/expr10/expr10.properties %exno_list% 

set endtime=%date%_%time%

echo MLSimulationGeneratorFPI7 %1
echo %exno_list% start: %starttime%
echo %exno_list%end  : %endtime%
:eof