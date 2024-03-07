@echo off

if "%~2"=="" (
  echo usage: command {def filepath} {property filepath} 
  goto :eof
)

cd /d %~dp0

set def_filepath=%1
set prop_filepath=%2

set starttime=%date%_%time%

rem java  ^
java -Xmx30000m ^
  -cp C:/Dev/workspace/Oxygen/pod_boatrace/target/classes;C:/Dev/workspace/Oxygen/pod_boatrace_test/lib/*;. ^
  com.pengkong.boatrace.exp02.RankResultGenerator %def_filepath%  %prop_filepath% 

set endtime=%date%_%time%

echo RankResultGenerator %1 %2
echo start: %starttime%
echo end  : %endtime%

:eof