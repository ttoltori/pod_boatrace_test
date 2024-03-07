@echo off

if "%~3"=="" (
  echo usage: make_model_bayesnet.bat {arff filepath} {model filepath} {evaluation filepath} 
  goto :eof
)

cd /d %~dp0

rem create model
set arff_filepath=%1
set model_filepath=%2
set eval_filepath=%3

rem error   -Q weka.classifiers.bayes.net.search.local.K2 -- -P 1 -S BAYES -E weka.classifiers.bayes.net.estimate.SimpleEstimator -- -A 0.5 ^

java ^
  -cp C:/Dev/workspace/Oxygen/pod_boatrace_test/lib/weka.jar;. ^
  weka.classifiers.bayes.BayesNet -D ^
  -t "%arff_filepath%" ^
  -d %model_filepath% ^
  -no-cv ^
  -split-percentage 80 ^
  >> %eval_filepath%


:eof