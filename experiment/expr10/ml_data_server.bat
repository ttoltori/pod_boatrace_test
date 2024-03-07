@echo off

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set starttime=%date%_%time%

java -Xmx16384m ^
  -cp %CP% com.pengkong.boatrace.exp10.simulation.data.rmi.server.RmiDataServer %PROPERTIES% 

set endtime=%date%_%time%

echo RmiDataServer start: %starttime%
echo RmiDataServer end  : %endtime%
:eof