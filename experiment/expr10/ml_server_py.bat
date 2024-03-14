@echo off

cd /d %~dp0

set starttime=%date%_%time%

set PYTHONPATH=%PYTHONPATH%;C:/Dev/github/py_boatrace
set program_property=C:/Dev/github/pod_boatrace/properties/expr10/expr10.properties
set model_property=C:/Dev/github/pod_boatrace/properties/expr10/model.properties
`
python C:/Dev/github/py_boatrace/boatrace/server/BoatWebSocketServer.py %program_property% %model_property% 

set endtime=%date%_%time%

echo BoatWebSocketServer %1
echo start: %starttime%
echo end  : %endtime%
:eof