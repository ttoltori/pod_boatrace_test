@echo off

if "%~4"=="" (
  echo usage: command {fromYmd} {toYmd} {betType} {kumiban}
  goto :eof
)

cd /d %~dp0

@REM 環境変数読み込み
call config.bat

set fromymd=%1
set toymd=%2
set bettype=%3
set kumiban=%4

set starttime=%date%_%time%

java -Xmx8048m ^
  -cp %CP% com.pengkong.boatrace.util.OddsResultFileUploader %fromymd% %toymd% %bettype% %kumiban%

set endtime=%date%_%time%

echo OddsResultFileUploader %fromymd% %toymd% %bettype% %kumiban% 
echo start: %starttime%
echo end  : %endtime%
:eof