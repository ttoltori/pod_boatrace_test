@echo off

cd /d %~dp0

set model=%1
set rankno=%2
set rate=%3
set fsql=%4

echo ml_test_py start %model% %rankno% %rate% %fsql%
echo "%model% %rankno% %rate% %fsql%"  >> %model%_rank%rankno%.txt
echo "===================================================================="  >> %model%_rank%rankno%.txt
if "%fsql%" == "fs_6" (
  goto fs_6 
) else if "%fsql%" == "fs_5" (
  goto fs_5 
) else if "%fsql%" == "fs_4" (
  goto fs_4 
) else if "%fsql%" == "fs_3" (
  goto fs_3 
) else if "%fsql%" == "fs_2" (
  goto fs_2 
) else if "%fsql%" == "fs_1" (
  goto fs_1 
) else if "%fsql%" == "en_nw_ext_25" (
  goto en_nw_ext_25 
) else if "%fsql%" == "en" (
  goto en 
) else if "%fsql%" == "nw" (
  goto nw
) else if "%fsql%" == "fs_7" (
  goto fs_7
) else if "%fsql%" == "fs_9" (
  goto fs_9
) else if "%fsql%" == "fs_10" (
  goto fs_10
) else if "%fsql%" == "fs_11" (
  goto fs_11
) else if "%fsql%" == "fs_12" (
  goto fs_12
) else if "%fsql%" == "fs_13" (
  goto fs_13
) else if "%fsql%" == "fs_14" (
  goto fs_14
) else if "%fsql%" == "fs_15" (
  goto fs_15
) else if "%fsql%" == "fs_16" (
  goto fs_16
) else if "%fsql%" == "fs_17" (
  goto fs_17
) else if "%fsql%" == "fs_18" (
  goto fs_18
) else ( 
  goto end 
)


rem 
rem call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" ",class" ",category" >> %model%_rank%rankno%.txt

:fs_18
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd1,pd2,pd3,mbo3t1,mbo3t2,mbo3t3,mbo3t4,mbo3t5,mbo3t6,mbo3t7,mbo3t8,mbo3t9,mbo3t10,mbo3t11,mbo3t12,mbo3t13,mbo3t14,mbo3t15,mbo3t16,mbo3t17,mbo3t18,mbo3t19,mbo3t20,mbork3t1,mbork3t2,mbork3t3,mbork3t4,mbork3t5,mbork3t6,mbork3t7,mbork3t8,mbork3t9,mbork3t10,mbork3t11,mbork3t12,mbork3t13,mbork3t14,mbork3t15,mbork3t16,mbork3t17,mbork3t18,mbork3t19,mbork3t20,class" "category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_17
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd1,pd2,pd3,r1prob1,r1prob2,r1prob3,r1prob4,r1prob5,r1prob6,r2prob1,r2prob2,r2prob3,r2prob4,r2prob5,r2prob6,r3prob1,r3prob2,r3prob3,r3prob4,r3prob5,r3prob6,class" "category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_16
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd1,mbo3t1,mbo3t2,mbo3t3,mbo3t4,mbo3t5,mbo3t6,mbo3t7,mbo3t8,mbo3t9,mbo3t10,mbo3t11,mbo3t12,mbo3t13,mbo3t14,mbo3t15,mbo3t16,mbo3t17,mbo3t18,mbo3t19,mbo3t20,mbork3t1,mbork3t2,mbork3t3,mbork3t4,mbork3t5,mbork3t6,mbork3t7,mbork3t8,mbork3t9,mbork3t10,mbork3t11,mbork3t12,mbork3t13,mbork3t14,mbork3t15,mbork3t16,mbork3t17,mbork3t18,mbork3t19,mbork3t20,class" "category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_15
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd1,pd2,pd3,r1prob1,r1prob2,r1prob3,r1prob4,r1prob5,r1prob6,r2prob1,r2prob2,r2prob3,r2prob4,r2prob5,r2prob6,r3prob1,r3prob2,r3prob3,r3prob4,r3prob5,r3prob6,mbo3t1,mbo3t2,mbo3t3,mbo3t4,mbo3t5,mbo3t6,mbo3t7,mbo3t8,mbo3t9,mbo3t10,mbo3t11,mbo3t12,mbo3t13,mbo3t14,mbo3t15,mbo3t16,mbo3t17,mbo3t18,mbo3t19,mbo3t20,mbork3t1,mbork3t2,mbork3t3,mbork3t4,mbork3t5,mbork3t6,mbork3t7,mbork3t8,mbork3t9,mbork3t10,mbork3t11,mbork3t12,mbork3t13,mbork3t14,mbork3t15,mbork3t16,mbork3t17,mbork3t18,mbork3t19,mbork3t20,class" "category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_14
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,fixent,en1,en2,en3,en4,en5,en6,rcnt1,rcnt2,rcnt3,rcnt4,rcnt5,rcnt6,cond1,cond2,cond3,cond4,cond5,cond6,n1p1,n1p2,n1p3,n1p4,n1p5,n1p6,n2p1,n2p2,n2p3,n2p4,n2p5,n2p6,n3p1,n3p2,n3p3,n3p4,n3p5,n3p6,n1pw1,n1pw2,n1pw3,n1pw4,n1pw5,n1pw6,n2pw1,n2pw2,n2pw3,n2pw4,n2pw5,n2pw6,n3pw1,n3pw2,n3pw3,n3pw4,n3pw5,n3pw6,avgw1,avgw2,avgw3,avgw4,avgw5,avgw6,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n2w6,n3w1,n3w2,n3w3,n3w4,n3w5,n3w6,lw1,lw2,lw3,lw4,lw5,lw6,l2w1,l2w2,l2w3,l2w4,l2w5,l2w6,l3w1,l3w2,l3w3,l3w4,l3w5,l3w6,lv1,lv2,lv3,lv4,lv5,lv6,weit1,weit2,weit3,weit4,weit5,weit6,fly1,fly2,fly3,fly4,fly5,fly6,class" "category,category,category,category,category,category,float,float,category,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_13
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,time,isvenus,weekday,sime,fixent,rcnt1,rcnt2,rcnt3,rcnt4,rcnt5,rcnt6,rcntsp1,rcntsp2,rcntsp3,rcntsp4,rcntsp5,rcntsp6,cond1,cond2,cond3,cond4,cond5,cond6,condsp1,condsp2,condsp3,condsp4,condsp5,condsp6,n1p1,n1p2,n1p3,n1p4,n1p5,n1p6,n1psp1,n1psp2,n1psp3,n1psp4,n1psp5,n1psp6,n2p1,n2p2,n2p3,n2p4,n2p5,n2p6,n2psp1,n2psp2,n2psp3,n2psp4,n2psp5,n2psp6,n3p1,n3p2,n3p3,n3p4,n3p5,n3p6,n3psp1,n3psp2,n3psp3,n3psp4,n3psp5,n3psp6,n1pw1,n1pw2,n1pw3,n1pw4,n1pw5,n1pw6,n1pwsp1,n1pwsp2,n1pwsp3,n1pwsp4,n1pwsp5,n1pwsp6,n2pw1,n2pw2,n2pw3,n2pw4,n2pw5,n2pw6,n2pwsp1,n2pwsp2,n2pwsp3,n2pwsp4,n2pwsp5,n2pwsp6,n3pw1,n3pw2,n3pw3,n3pw4,n3pw5,n3pw6,n3pwsp1,n3pwsp2,n3pwsp3,n3pwsp4,n3pwsp5,n3pwsp6,avgw1,avgw2,avgw3,avgw4,avgw5,avgw6,avgwsp1,avgwsp2,avgwsp3,avgwsp4,avgwsp5,avgwsp6,class" "category,category,category,category,category,category,float,float,category,category,category,float,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_12
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,time,isvenus,weekday,sime,fixent,en1,en2,en3,en4,en5,en6,rcnt1,rcnt2,rcnt3,rcnt4,rcnt5,rcnt6,rcntsp1,rcntsp2,rcntsp3,rcntsp4,rcntsp5,rcntsp6,cond1,cond2,cond3,cond4,cond5,cond6,condsp1,condsp2,condsp3,condsp4,condsp5,condsp6,n1p1,n1p2,n1p3,n1p4,n1p5,n1p6,n1psp1,n1psp2,n1psp3,n1psp4,n1psp5,n1psp6,n2p1,n2p2,n2p3,n2p4,n2p5,n2p6,n2psp1,n2psp2,n2psp3,n2psp4,n2psp5,n2psp6,n3p1,n3p2,n3p3,n3p4,n3p5,n3p6,n3psp1,n3psp2,n3psp3,n3psp4,n3psp5,n3psp6,n1pw1,n1pw2,n1pw3,n1pw4,n1pw5,n1pw6,n1pwsp1,n1pwsp2,n1pwsp3,n1pwsp4,n1pwsp5,n1pwsp6,n2pw1,n2pw2,n2pw3,n2pw4,n2pw5,n2pw6,n2pwsp1,n2pwsp2,n2pwsp3,n2pwsp4,n2pwsp5,n2pwsp6,n3pw1,n3pw2,n3pw3,n3pw4,n3pw5,n3pw6,n3pwsp1,n3pwsp2,n3pwsp3,n3pwsp4,n3pwsp5,n3pwsp6,avgw1,avgw2,avgw3,avgw4,avgw5,avgw6,avgwsp1,avgwsp2,avgwsp3,avgwsp4,avgwsp5,avgwsp6,class" "category,category,category,category,category,category,float,float,category,category,category,float,category,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_11
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,time,isvenus,weekday,sime,fixent,en1,en2,en3,en4,en5,en6,rcnt1,rcnt2,rcnt3,rcnt4,rcnt5,rcnt6,rcntsp1,rcntsp2,rcntsp3,rcntsp4,rcntsp5,rcntsp6,cond1,cond2,cond3,cond4,cond5,cond6,condsp1,condsp2,condsp3,condsp4,condsp5,condsp6,n1p1,n1p2,n1p3,n1p4,n1p5,n1p6,n1psp1,n1psp2,n1psp3,n1psp4,n1psp5,n1psp6,n2p1,n2p2,n2p3,n2p4,n2p5,n2p6,n2psp1,n2psp2,n2psp3,n2psp4,n2psp5,n2psp6,n3p1,n3p2,n3p3,n3p4,n3p5,n3p6,n3psp1,n3psp2,n3psp3,n3psp4,n3psp5,n3psp6,n1pw1,n1pw2,n1pw3,n1pw4,n1pw5,n1pw6,n1pwsp1,n1pwsp2,n1pwsp3,n1pwsp4,n1pwsp5,n1pwsp6,n2pw1,n2pw2,n2pw3,n2pw4,n2pw5,n2pw6,n2pwsp1,n2pwsp2,n2pwsp3,n2pwsp4,n2pwsp5,n2pwsp6,n3pw1,n3pw2,n3pw3,n3pw4,n3pw5,n3pw6,n3pwsp1,n3pwsp2,n3pwsp3,n3pwsp4,n3pwsp5,n3pwsp6,avgw1,avgw2,avgw3,avgw4,avgw5,avgw6,avgwsp1,avgwsp2,avgwsp3,avgwsp4,avgwsp5,avgwsp6,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n2w6,n3w1,n3w2,n3w3,n3w4,n3w5,n3w6,lw1,lw2,lw3,lw4,lw5,lw6,l2w1,l2w2,l2w3,l2w4,l2w5,l2w6,l3w1,l3w2,l3w3,l3w4,l3w5,l3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,sex1,sex2,sex3,sex4,sex5,sex6,lv1,lv2,lv3,lv4,lv5,lv6,age1,age2,age3,age4,age5,age6,weit1,weit2,weit3,weit4,weit5,weit6,fly1,fly2,fly3,fly4,fly5,fly6,late1,late2,late3,late4,late5,late6,avgst1,avgst2,avgst3,avgst4,avgst5,avgst6,class" "category,category,category,category,category,category,float,float,category,category,category,float,category,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_10
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,time,isvenus,weekday,sime,fixent,rcnt1,rcnt2,rcnt3,rcnt4,rcnt5,rcnt6,rcntsp1,rcntsp2,rcntsp3,rcntsp4,rcntsp5,rcntsp6,cond1,cond2,cond3,cond4,cond5,cond6,condsp1,condsp2,condsp3,condsp4,condsp5,condsp6,n1p1,n1p2,n1p3,n1p4,n1p5,n1p6,n1psp1,n1psp2,n1psp3,n1psp4,n1psp5,n1psp6,n2p1,n2p2,n2p3,n2p4,n2p5,n2p6,n2psp1,n2psp2,n2psp3,n2psp4,n2psp5,n2psp6,n3p1,n3p2,n3p3,n3p4,n3p5,n3p6,n3psp1,n3psp2,n3psp3,n3psp4,n3psp5,n3psp6,n1pw1,n1pw2,n1pw3,n1pw4,n1pw5,n1pw6,n1pwsp1,n1pwsp2,n1pwsp3,n1pwsp4,n1pwsp5,n1pwsp6,n2pw1,n2pw2,n2pw3,n2pw4,n2pw5,n2pw6,n2pwsp1,n2pwsp2,n2pwsp3,n2pwsp4,n2pwsp5,n2pwsp6,n3pw1,n3pw2,n3pw3,n3pw4,n3pw5,n3pw6,n3pwsp1,n3pwsp2,n3pwsp3,n3pwsp4,n3pwsp5,n3pwsp6,avgw1,avgw2,avgw3,avgw4,avgw5,avgw6,avgwsp1,avgwsp2,avgwsp3,avgwsp4,avgwsp5,avgwsp6,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n2w6,n3w1,n3w2,n3w3,n3w4,n3w5,n3w6,lw1,lw2,lw3,lw4,lw5,lw6,l2w1,l2w2,l2w3,l2w4,l2w5,l2w6,l3w1,l3w2,l3w3,l3w4,l3w5,l3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,sex1,sex2,sex3,sex4,sex5,sex6,lv1,lv2,lv3,lv4,lv5,lv6,age1,age2,age3,age4,age5,age6,weit1,weit2,weit3,weit4,weit5,weit6,fly1,fly2,fly3,fly4,fly5,fly6,late1,late2,late3,late4,late5,late6,avgst1,avgst2,avgst3,avgst4,avgst5,avgst6,class" "category,category,category,category,category,category,float,float,category,category,category,float,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_9
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,weekday,sime,fixent,en1,en2,en6,nw1,nw2,nw6,n2w1,n2w2,n2w6,n3w1,n3w2,n3w6,lw1,lw2,lw6,l2w1,l2w2,l2w6,l3w1,l3w2,l3w6,m2w1,m2w2,m2w6,sex1,sex2,sex6,lv1,lv2,lv6,age1,age2,age6,weit1,weit2,weit6,fly1,fly2,fly6,late1,late2,late6,avgst1,avgst2,avgst6,class" "category,category,category,category,category,category,float,float,category,float,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_7
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,time,fixent,weekday,sime,isvenus,en1,en2,en3,en4,nw1,nw2,nw3,nw4,n2w1,n2w2,n2w3,n2w4,n3w1,n3w2,n3w3,n3w4,lw1,lw2,lw3,lw4,l2w1,l2w2,l2w3,l2w4,l3w1,l3w2,l3w3,l3w4,m2w1,m2w2,m2w3,m2w4,sex1,sex2,sex3,sex4,lv1,lv2,lv3,lv4,age1,age2,age3,age4,weit1,weit2,weit3,weit4,fly1,fly2,fly3,fly4,late1,late2,late3,late4,avgst1,avgst2,avgst3,avgst4,class" "category,category,category,category,category,category,float,float,category,category,category,float,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end


:fs_6
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,weekday,sime,fixent,en1,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n2w6,n3w1,n3w2,n3w3,n3w4,n3w5,n3w6,lw1,lw2,lw3,lw4,lw5,lw6,l2w1,l2w2,l2w3,l2w4,l2w5,l2w6,l3w1,l3w2,l3w3,l3w4,l3w5,l3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,sex1,sex2,sex3,sex4,sex5,sex6,lv1,lv2,lv3,lv4,lv5,lv6,age1,age2,age3,age4,age5,age6,weit1,weit2,weit3,weit4,weit5,weit6,fly1,fly2,fly3,fly4,fly5,fly6,late1,avgst1,avgst2,avgst3,avgst4,avgst5,avgst6,class" "category,category,category,category,category,category,float,float,category,float,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_5
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,raty,alvt,fixent,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n2w6,n3w1,n3w2,n3w3,n3w4,n3w5,n3w6,lw1,lw2,lw3,lw4,lw5,lw6,l2w1,l2w2,l2w3,l2w4,l2w5,l2w6,l3w1,l3w2,l3w3,l3w4,l3w5,l3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,age1,age2,age3,age4,age5,age6,weit1,weit2,weit3,weit4,weit5,weit6,avgst1,avgst2,avgst3,avgst4,avgst5,avgst6,class" "category,category,category,category,category,float,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_4
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,time,isvenus,weekday,sime,fixent,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n2w6,n3w1,n3w2,n3w3,n3w4,n3w5,n3w6,lw1,lw2,lw3,lw4,lw5,lw6,l2w1,l2w2,l2w3,l2w4,l2w5,l2w6,l3w1,l3w2,l3w3,l3w4,l3w5,l3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,sex1,sex2,sex3,sex4,sex5,sex6,lv1,lv2,lv3,lv4,lv5,lv6,age1,age2,age3,age4,age5,age6,weit1,weit2,weit3,weit4,weit5,weit6,fly1,fly2,fly3,fly4,fly5,fly6,late1,late2,late3,late4,late5,late6,avgst1,avgst2,avgst3,avgst4,avgst5,avgst6,class" "category,category,category,category,category,category,float,float,category,category,category,float,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end


:fs_3
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "jyo,race,turn,raty,alvt,fixent,mm,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n3w5,n3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,lv1,weit2,fly1,fly4,class" "category,category,category,category,float,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_2
:call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "jyo,race,turn,raty,alvt,fixent,mm,en1,en2,en3,en4,en5,en6,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n3w5,n3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,lv1,weit2,fly1,fly4,class" "category,category,category,category,float,category,category,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:fs_1
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "jyo,race,turn,grade,fixent,isvenus,mm,weekday,sime,en1,en2,en3,en4,en5,en6,lv1,lv2,lv3,lv4,lv5,lv6,class" "category,category,category,category,category,category,category,category,float,category,category,category,category,category,category,category,category,category,category,category,category,category" >> %model%_rank%rankno%.txt
goto end

:en_nw_ext_25
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "mm,jyo,race,turn,grade,raty,femcnt,alvt,time,fixent,en1,en2,en3,en4,en5,en6,nw1,nw2,nw3,nw4,nw5,nw6,n2w1,n2w2,n2w3,n2w4,n2w5,n2w6,n3w1,n3w2,n3w3,n3w4,n3w5,n3w6,lw1,lw2,lw3,lw4,lw5,lw6,l2w1,l2w2,l2w3,l2w4,l2w5,l2w6,l3w1,l3w2,l3w3,l3w4,l3w5,l3w6,m2w1,m2w2,m2w3,m2w4,m2w5,m2w6,sex1,sex2,sex3,sex4,sex5,sex6,lv1,lv2,lv3,lv4,lv5,lv6,age1,age2,age3,age4,age5,age6,weit1,weit2,weit3,weit4,weit5,weit6,fly1,fly2,fly3,fly4,fly5,fly6,late1,late2,late3,late4,late5,late6,avgst1,avgst2,avgst3,avgst4,avgst5,avgst6,class" "category,category,category,category,category,category,float,float,category,category,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

rem :mbo_20
rem call ml_test_py "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd123,mbo3t1,mbo3t2,mbo3t3,mbo3t4,mbo3t5,mbo3t6,mbo3t7,mbo3t8,mbo3t9,mbo3t10,mbo3t11,mbo3t12,mbo3t13,mbo3t14,mbo3t15,mbo3t16,mbo3t17,mbo3t18,mbo3t19,mbo3t20,class" "category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
rem goto end

rem  call ml_test_py "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "r1prob1,r1prob2,r1prob3,r1prob4,r1prob5,r1prob6,r1skew,r1kurto,pd1,class" "float,float,float,float,float,float,float,float,category,category" >> %model%_rank%rankno%.txt

rem call ml_test_py "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd1,pd2,pd3,r1prob1,r1prob2,r1prob3,r1prob4,r1prob5,r2prob1,r2prob2,r2prob3,r2prob4,r2prob5,r2prob6,r3prob1,r3prob2,r3prob3,r3prob4,r3prob5,r3prob6,class" "category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt

rem call ml_test_py "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd1,rpb1,rpb2,rpb3,rpb4,rpb5,rpb6,rpb7,rpb8,rpb9,rpb10,rpb11,rpb12,rpb13,rpb14,rpb15,rpb16,rpb17,rpb18,rpb19,rpb20,rpb21,rpb22,rpb23,rpb24,rpb25,rpb26,rpb27,rpb28,rpb29,rpb30,rpb31,rpb32,rpb33,rpb34,rpb35,rpb36,rpb37,rpb38,rpb39,rpb40,rpb41,rpb42,rpb43,rpb44,rpb45,rpb46,rpb47,rpb48,rpb49,rpb50,rpb51,rpb52,rpb53,rpb54,rpb55,rpb56,rpb57,rpb58,rpb59,rpb60,rpb61,rpb62,rpb63,rpb64,rpb65,rpb66,rpb67,rpb68,rpb69,rpb70,rpb71,rpb72,rpb73,rpb74,rpb75,rpb76,rpb77,rpb78,rpb79,rpb80,class" "category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt

rem pop_20
rem call ml_test_py "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd123,pk3t1,pk3t2,pk3t3,pk3t4,pk3t5,pk3t6,pk3t7,pk3t8,pk3t9,pk3t10,pk3t11,pk3t12,pk3t13,pk3t14,pk3t15,pk3t16,pk3t17,pk3t18,pk3t19,pk3t20,pbo3t1,pbo3t2,pbo3t3,pbo3t4,pbo3t5,pbo3t6,pbo3t7,pbo3t8,pbo3t9,pbo3t10,pbo3t11,pbo3t12,pbo3t13,pbo3t14,pbo3t15,pbo3t16,pbo3t17,pbo3t18,pbo3t19,pbo3t20,class" "category,category,category,category,category,category,category,category,category,category,category,category,category,category,category,category,category,category,category,category,category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt

rem popk_10
rem call ml_test_py "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd123,pk3t1,pk3t2,pk3t3,pk3t4,pk3t5,pk3t6,pk3t7,pk3t8,pk3t9,pk3t10,class" "category,category,category,category,category,category,category,category,category,category,category,category" >> %model%_rank%rankno%.txt

rem mb_40
rem call ml_test_py "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "pd123,mbo3t1,mbo3t2,mbo3t3,mbo3t4,mbo3t5,mbo3t6,mbo3t7,mbo3t8,mbo3t9,mbo3t10,mbo3t11,mbo3t12,mbo3t13,mbo3t14,mbo3t15,mbo3t16,mbo3t17,mbo3t18,mbo3t19,mbo3t20,mbork3t1,mbork3t2,mbork3t3,mbork3t4,mbork3t5,mbork3t6,mbork3t7,mbork3t8,mbork3t9,mbork3t10,mbork3t11,mbork3t12,mbork3t13,mbork3t14,mbork3t15,mbork3t16,mbork3t17,mbork3t18,mbork3t19,mbork3t20,class" "category,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt

:en
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "en1,en2,en3,en4,en5,en6,class" "category,category,category,category,category,category,category" >> %model%_rank%rankno%.txt
goto end

:nw
call ml_test_py_call "boosting_type=gbdt,learning_rate=%rate%" "D:/Dev/experiment/expr10/arff/%model%_rank%rankno%.csv" "D:/Dev/tmp/tmp.model" "nw1,nw2,nw3,nw4,nw5,nw6,class" "float,float,float,float,float,float,category" >> %model%_rank%rankno%.txt
goto end

:end 
echo ml_test_py end %model% %rankno% %rate% %fsql%
echo.
echo.

:eof
