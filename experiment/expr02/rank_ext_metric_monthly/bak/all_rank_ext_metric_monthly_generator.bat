@echo off

if "%~1"=="" (
  echo usage: command {ranktype}
  goto :eof
)

cd /d %~dp0

set ranktype=%1

set starttime=%date%_%time%

call rank_ext_metric_monthly_generator 0003 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0005 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0006 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0007 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0011 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0012 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0013 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0015 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0016 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0017 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0019 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0020 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0021 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0022 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0041 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0042 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0043 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0044 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0047 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0049 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0062 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0063 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0064 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0065 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0066 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0067 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0068 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0069 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0070 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0071 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0072 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0073 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0074 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0075 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0076 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0077 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0079 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0080 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0081 20170801 20190731 %ranktype%
call rank_ext_metric_monthly_generator 0082 20170801 20190731 %ranktype%

set endtime=%date%_%time%

echo -----------------------------------------
echo all_rank_ext_metric_monthly_generator %1
echo start: %starttime%
echo end  : %endtime%

:eof