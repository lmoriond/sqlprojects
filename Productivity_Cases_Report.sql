--Evaluating Analyst Productivity with SQL

--This SQL code delves into a structured database to retrieve data relevant to case completion times for individual analysts. This enables a comprehensive evaluation of productivity and identifies areas for improvement.
--The code groups cases by analyst and calculate their average completion time & status. 
--This aggregation enables the calculation of a key performance indicator (KPI) for analyst productivity, providing a valuable metric for stakeholders.
--This granular analysis empowers managers to allocate resources effectively, provide targeted coaching, and foster a culture of continuous improvement.


--Cases worked in the last 3 months by analysts

SELECT
task.case_id,
task.task_id,
task.task_ts,
task.task_nm,
task.task_team,
task.opr_id,
task.opr_wsid,
task.opr_site,
task.opr_nm,
task.opr_bus_grp,
task.opr_ldr1,
task.opr_ldr2,
task.task_rsn_or_outcm,
task.workbasket_or_wklst,
task.bus_unit,
task.cust_mkt,
clic.case_type,
clic.case_asgn_team

FROM db3.database_task_detail AS task
left join db3.database_case_detail AS clic on task.case_id = clic.case_id

WHERE task.task_ts between '2022-01-01' and current_date() --depends on the rolling we need
and task.opr_id in ('7030034','7029026','7029000','6551292','7029431','7029085','7028966','6551260','7029564','7029122','7029216','7028960','7029449','6423763','6433133','7029605','6330609','6162654','6473678','6330786','6415038','6584162','6507180','6587077','6335146','6418727','6278451','7052037','7053013','7053480','7052360','7052110','7030221','7052078','7029559')
and substring(task.case_id,1,2) <> 'BI'
and task.task_nm in ('Pend','TransferToWorkBasket','Resolve','Terminate')  --not all actions are important for productivity report


---Productivity BY DAY of each analyst

SELECT
date_format(a.case_wrk_ts,'dd-MMM-yy') as ws_month,
a.people_sft_id,
b.disp_nm as ccp_name,
c.disp_nm as mng_1,
d.disp_nm as mng_2,
e.disp_nm as mng_3,
g.disp_nm as mng_4,
f.user_dept,
f.user_locat,
f.user_ctry,
f.emply_type,
f.bus_unit_ds,
f.cost_ctr_ds,
f.emply_sta_cd,
f.dept_hier_ds_lvl3,
f.dept_hier_ds_lvl4,
f.dept_hier_ds_lvl5,
f.dept_hier_ds_lvl6,
CASE
                              WHEN a.people_sft_id in ('7030034','7029026','7029000','6423763','6433133','7029605') THEN "Allocations" --Dividing analysts by team in conditional
                              WHEN a.people_sft_id in ('6330609','6162654','6473678','6330786') THEN "ABFT"
                              WHEN a.people_sft_id in ('6415038','6584162','6507180','6587077','6335146','7029559','7029122') THEN "Maint"
                              WHEN a.people_sft_id in ('6418727','6278451') THEN "RFE"
                              WHEN a.people_sft_id in ('7052037','7053013','7053480','7052360','7052110','7030221','7052078') THEN "ABC team"
                              ELSE 'Other'
               END corp_Team,
round(((sum(a.dur_evnt)/60)/60),2) as sum_dur_evnt_hs,
count (distinct date_format(a.case_wrk_ts,'dd-MMM-yy')) number_of_days,  --we need this to see how many days he worked in the month
round((((sum(a.dur_evnt)/60)/60) / count (distinct date_format(a.case_wrk_ts,'dd-MMM-yy'))),2) as avg_prod_hs,
round((sum(a.trans_wrkd) / ((sum(a.dur_evnt)/60)/60)),2) as UPH,   --trans worked per hour
round((sum((a.trans_wrkd)*(a.case_rslv_in)) / ((sum(a.dur_evnt)/60)/60)),2) as UPH_E2E,
sum(a.trans_wrkd) trans_wrkd,
sum(a.case_work_in) case_work_in,
sum(a.case_creat_in) case_creat_in,
sum(a.case_rslv_in) case_rslv_in,
sum(a.case_touched_in) case_touched_in

FROM db3.productivity_case_detail a
left outer join db3.employee_details b
on trim(a.people_sft_id) = trim(b.emp_id)
left outer join cstonedb3.employee_details c
on trim(b.mgr_emp_id) = trim(c.emp_id)
left outer join cstonedb3.employee_details d
on trim(c.mgr_emp_id) = trim(d.emp_id)
left outer join cstonedb3.employee_details e
on trim(d.mgr_emp_id) = trim(e.emp_id)
left outer join cstonedb3.employee_details f
on trim(a.people_sft_id) = trim(f.emp_id)
left outer join cstonedb3.employee_details g
on trim(e.mgr_emp_id) = trim(g.emp_id)

WHERE a.case_wrk_ts between '2022-01-01' and '2022-03-31'   --last 3 months to see trends
and a.people_sft_id in ('7030034','7029026','7029000','6551292','7029431','7029085','7028966','6551260','7029564','7029122','7029216','7028960','7029449','6423763','6433133','7029605','6330609','6162654','6473678','6330786','6415038','6584162','6507180','6587077','6335146','6418727','6278451','7052037','7053013','7053480','7052360','7052110','7030221','7052078','7029559') 
--Analyst we need to see

GROUP BY
date_format(a.case_wrk_ts,'dd-MMM-yy'),
a.people_sft_id,
b.disp_nm,
c.disp_nm,
d.disp_nm,
e.disp_nm,
g.disp_nm,
f.user_dept,
f.user_locat,
f.user_ctry,
f.emply_type,
f.bus_unit_ds,
f.cost_ctr_ds,
f.emply_sta_cd,
f.dept_hier_ds_lvl3,
f.dept_hier_ds_lvl4,
f.dept_hier_ds_lvl5,
f.dept_hier_ds_lvl6
;


