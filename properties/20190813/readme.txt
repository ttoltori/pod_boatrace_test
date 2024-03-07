1. depth1의 다른 기간별로 final을 생성
2. boatstat1에 이하 테이블에 각각 저장했다.

drop table if exists stmp_stat_ml_ptn_final_2015;
create table stmp_stat_ml_ptn_final_2015 (
description varchar(200),
bettype varchar(2),
kumiban varchar(4),
pattern_name varchar(400),
pattern_value varchar(400),
betcnt int, 
hitcnt int, 
betamt int, 
hitamt int, 
incomeamt int, 
betrate numeric(7,3),
hitrate numeric(7,2),
incomerate numeric(7,2),
totalrate numeric(7,2),
hitamt_bias_rate numeric(7,2),
hit_bet_slope_rate numeric(7,2),
minus_days int, -- 적자 일수
plus_days int, -- 흑자 일수
minus_changed_count int, -- 적자전환 횟수
plus_changed_count int, -- 흑자전환 횟수
minus_days_rate  numeric(7,2), -- 전체일수에 대한 적자일수 비율
linear_incomeamt_slope numeric(10,5),
recover_success_rate numeric(7,2), -- 적중투표수에 대한 적자=>흑자전환투표수 비율
recover_fail_rate numeric(7,2), -- 적중투표수에 대한 적자=>흑자전환실패투표수 비율
recover_plus_rate numeric(7,2), -- 적중투표수에 대한 흑자증가투표수 비율
recover_minus_rate numeric(7,2), -- 적중투표수에 대한 흑자감소투표수 비율
hitamt_sum_under int,
hitamt_sum_over int,
hitamt_mod int,
hitamt_percent int,
days_bet int,
days_plus int,
days_plus_rate numeric(7,2),
betcnt_limit int
);
create index indexes_stmp_stat_ml_ptn_final_2015 on stmp_stat_ml_ptn_final_2015 (description, bettype, kumiban, pattern_name, pattern_value);

drop table if exists stmp_stat_ml_ptn_final_2018;
create table stmp_stat_ml_ptn_final_2018 (
description varchar(200),
bettype varchar(2),
kumiban varchar(4),
pattern_name varchar(400),
pattern_value varchar(400),
betcnt int, 
hitcnt int, 
betamt int, 
hitamt int, 
incomeamt int, 
betrate numeric(7,3),
hitrate numeric(7,2),
incomerate numeric(7,2),
totalrate numeric(7,2),
hitamt_bias_rate numeric(7,2),
hit_bet_slope_rate numeric(7,2),
minus_days int, -- 적자 일수
plus_days int, -- 흑자 일수
minus_changed_count int, -- 적자전환 횟수
plus_changed_count int, -- 흑자전환 횟수
minus_days_rate  numeric(7,2), -- 전체일수에 대한 적자일수 비율
linear_incomeamt_slope numeric(10,5),
recover_success_rate numeric(7,2), -- 적중투표수에 대한 적자=>흑자전환투표수 비율
recover_fail_rate numeric(7,2), -- 적중투표수에 대한 적자=>흑자전환실패투표수 비율
recover_plus_rate numeric(7,2), -- 적중투표수에 대한 흑자증가투표수 비율
recover_minus_rate numeric(7,2), -- 적중투표수에 대한 흑자감소투표수 비율
hitamt_sum_under int,
hitamt_sum_over int,
hitamt_mod int,
hitamt_percent int,
days_bet int,
days_plus int,
days_plus_rate numeric(7,2),
betcnt_limit int
);
create index indexes_stmp_stat_ml_ptn_final_2018 on stmp_stat_ml_ptn_final_2018 (description, bettype, kumiban, pattern_name, pattern_value);
