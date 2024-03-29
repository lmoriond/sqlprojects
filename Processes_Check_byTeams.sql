--Analyzing Case Distribution by Team and Month

--The retrieved information provides a comprehensive overview of case distribution patterns, enabling effective team evaluation and performance assessment.
--The resulting dataset unveils a granular view of case handling across teams and time periods. 
--By analyzing this data, stakeholders can identify teams excelling in case management, observe any discrepancies in performance, and pinpoint areas for improvement. This granular analysis empowers organizations to optimize their resource allocation, streamline team operations, and enhance overall case management effectiveness.


----------------------------------------------------------------Cases worked by month for each team

SELECT
case_id,
bus_unit,
case_class,
cust_mkt,
case_ctgy,
case_type,
case_asgn_team,
work_type,
workbasket_or_wklst,
tot_trans_work,
refer_id_type,
coalesce(cm15,se10,other_refer_id) as reference_id,
simple_case_sta,
full_case_sta,
to_date(inq_ts) as inq_ts,
to_date(creat_ts) as creat_ts,
to_date(latest_rslv_ts) as latest_rslv_ts,
datediff(inq_ts,creat_ts) as dif_creat_inq,
datediff(latest_rslv_ts,inq_ts) as open_CTR,
creat_opr_nm,
--creat_opr_id, use in filter to only see one Analyst
pend_ct,
tot_pend_tm,
latest_pend_ts,
first_pend_rsn,
latest_pend_note,
latest_updt_ts,
latest_updt_opr_nm,
latest_updt_note,
--latest_rslv_opr_id,
--latest_rslv_opr_nm,
latest_rslv_rsn,
latest_rslv_note,
--latest_reopn_note,
--latest_lift_note,
--latest_trmn_note,
srce_appl

FROM cstonedb3.gsn_clic_case_detail

where crnt_case_rec_flag = 'Yes'
and substring(case_id,1,2) <> 'BI'
and creat_ts between '2022-01-01' and current_date()  --latest_rslv_ts/inq_ts between '2021-05-01' and current_date()  :Use resolve for actual work done
and cust_mkt in ('Germany')
and bus_unit = 'CORP'
--and case_type in ('DD Enrolment','DD Maintenance')
--and case_type like '%Fee Reversal%'
--and case_asgn_team like '%BTA Allocations%'


----------------------------------------------------------------Looking at cases filtering by client

SELECT distinct 
case_id,
bus_unit,
case_ctgy,
case_type,
case_asgn_team,
workbasket_or_wklst,
tot_trans_req,
cust_mkt,
simple_case_sta,
full_case_sta,
to_date(inq_ts) as Inquiry_date,
to_date(creat_ts) as Create_date,
to_date(latest_rslv_ts) as Resolve_date

from cstonedb3.gsn_clic_case_detail
where crnt_case_rec_flag = 'Yes'   --for only last case updated (flag created in database)
and COALESCE(cm15,se10,other_refer_id) in ('#####1772009','); --like 'number%' for any client with that termination

#---------------------------------------------------------------- Creating temporary table in order to filter a created column---------------------------#

create temporary table gocm_bahub.commerical_CTR_temp as

select
a.case_id,
datediff(latest_rslv_ts,inq_ts) as CTR

from cstonedb3.gsn_clic_case_detail

create temporary table gocm_bahub.CTR_official as

select
temp.case_id,
bus_unit,
case_class,
cust_mkt,
case_ctgy,
case_type,
case_asgn_team,
work_type,
workbasket_or_wklst,
tot_trans_work,
refer_id_type,
coalesce(cm15,se10,other_refer_id) as reference_id,
simple_case_sta,
full_case_sta,
to_date(inq_ts) as inq_ts,
to_date(creat_ts) as creat_ts,
to_date(latest_rslv_ts) as latest_rslv_ts,
date(a.latest_updt_ts) as Update_date,
datediff(current_date(),a.latest_updt_ts) as RTW, -- Fecha de hoy
datediff(current_date(),a.inq_ts) as CTR -- Fecha de hoy
creat_opr_nm,
latest_updt_opr_nm,
pend_ct,
tot_pend_tm,
latest_pend_ts,
first_pend_rsn,
latest_rslv_note,
workbasket_or_wklst,
srce_appl

from cstonedb3.gsn_clic_case_detail a left join gocm_bahub.commerical_CTR_temp temp on a.case_id = temp.case_id

where crnt_case_rec_flag = 'Yes'
and substring(case_id,1,2) <> 'BI'
and latest_rslv_ts between '2022-01-01' and current_date()
and cust_mkt in ('Germany','Austria','Spain','France')
and bus_unit = 'CORP'
and CTR >= 200

select * from gocm_bahub.CTR_official

