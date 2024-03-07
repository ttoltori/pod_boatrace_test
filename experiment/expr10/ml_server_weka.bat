@echo off

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set starttime=%date%_%time%

java -Xmx32000m -cp %CP% com.pengkong.boatrace.exp10.remote.server.BoatWebSocketServer %PROPERTIES% 

set endtime=%date%_%time%

echo BoatWebSocketServer %1
echo start: %starttime%
echo end  : %endtime%
:eof