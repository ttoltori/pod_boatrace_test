@echo off

cd /d %~dp0

set starttime=%date%_%time%

set PYTHONPATH=%PYTHONPATH%;C:/Dev/workspace/Oxygen/py_boatrace
set program_property=C:/Dev/github/pod_boatrace/properties/expr10/expr10.properties
set model_property=C:/Dev/github/pod_boatrace/properties/expr10/model.properties

python C:/Dev/workspace/Oxygen/py_boatrace/boatrace/classification/lgbm//BoatLGBMClassifierTest.py %1 %2 %3 %4 %5

set endtime=%date%_%time%

echo BoatLGBMClassifierTest %1
echo start: %starttime%
echo end  : %endtime%
:eof