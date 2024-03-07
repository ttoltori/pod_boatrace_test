@echo off

call :parse "%~1"
goto :eof

:parse
setlocal
set list=%~1
echo list = %list%

for /F "tokens=1* delims=," %%f in ("%list%") do (
    rem if the item exist
    if not "%%f" == "" call :doJob %%f
    rem if next item exist
    if not "%%g" == "" call :parse "%%g"
)
endlocal
goto :eof

:doJob
setlocal
call ml_result %1
goto :eof