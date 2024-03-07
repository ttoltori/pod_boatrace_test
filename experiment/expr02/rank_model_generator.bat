@echo off

if "%~2"=="" (
  echo usage: command {def filepath} {property filepath} 
  goto :eof
)

cd /d %~dp0

set def_filepath=%1
set prop_filepath=%2

set starttime=%date%_%time%

java -Xmx8048m ^
  -cp C:/Dev/workspace/Oxygen/pod_boatrace/target/classes;C:/Dev/workspace/Oxygen/pod_boatrace_test/lib/*;. ^
  com.pengkong.boatrace.exp02.RankModelGenerator %def_filepath%  %prop_filepath% 

set endtime=%date%_%time%

echo RankModelGenerator %1 %2
echo %def_filepath% start: %starttime% >> %prop_filepath%.model.elasped
echo %def_filepath% end  : %endtime% >> %prop_filepath%.model.elasped

:eof