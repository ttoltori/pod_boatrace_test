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

java -cp %CP% com.pengkong.boatrace.exp10.automation.Simul2GroupsFileGenerator %PROPERTIES% %exno_list% 

set endtime=%date%_%time%

echo Simul2GroupsFileGenerator %1
echo %exno_list% start: %starttime%
echo %exno_list%end  : %endtime%
:eof