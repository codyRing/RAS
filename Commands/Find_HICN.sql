use RAS_APR_Reconciliation
---------------------------------------------Without DOB----------------
Declare @mindate date = '1/1/18'

--Step one get APR File Identifiers that appear to be MBI's
Truncate table dbo.research_id
insert into dbo.research_id (Identifier,MemberID,lastname,firstname)

select distinct
a.Identifier,a.MemberID,a.lastname,a.firstname
   FROM (
		SELECT  row_number() over (partition by memberid order by coverageperiodstart desc) as indx
		,*
		--FROM [RAS_APR_Reconciliation].[dbo].Aetna_pdp
		--FROM [RAS_APR_Reconciliation].[dbo].CVS
		--FROM [RAS_APR_Reconciliation].[dbo].Coventry
		--FROM [RAS_APR_Reconciliation].[dbo].Cigna_medigap
		--FROM [RAS_APR_Reconciliation].[dbo].UHC 
		--FROM [RAS_APR_Reconciliation].[dbo].Humana
		where CoveragePeriodStart >= @mindate
		) A
where 
   len(a.Identifier)>= 11 
  and SUBSTRING(identifier,1,1) like '[0-9]'
  and SUBSTRING(identifier,5,1) like '[a-zA-Z]'


 --select * From dbo.Research_ID


---Get details from existing RAS_APR_RECORDS that have been sent previously
;with APR as(

	select 
	t.Identifier,
	t.memberid,
	x.HICN,
	x.Holder_AID,
	x.First_Name,
	x.Last_Name
	from dbo.research_id t
		cross apply
		(
		select top 1 hicn,first_name,last_name,File_date,Holder_AID
			from dbo.RAS_APR_Records
				where 
					Carrier_Member_id = t.memberid and
					last_name = t.lastname and
					firstname = t.firstname and
					Reimbursement_status in ('sent','pending')
		order by File_date desc
		) x
),


----Get SSN's from MMA members based on First and Last Name
MMA as(
	Select 
	t.firstname,
	t.lastname,
	t.Identifier,
	m.ssn,
	m.aid 
	from dbo.MMAMembers m
		join dbo.research_id t
			on m.Last_Name = t.lastname and
			m.First_Name = t.firstname
			)		

---Join together on MBI and AID to get SSN's from MMA Members
select 
 apr.Identifier as MBI
,mma.SSN as SSN
,apr.HICN as HICN
,apr.First_Name,apr.Last_Name,apr.memberid
	from APR
		 left join MMA
			on	APR.identifier =MMA.identifier and
				APR.Holder_AID = mma.AID
				



---View Prior APR records from Carrier DI
select 
Row_number () over(partition by x.identifier order by r.coverage_Start_date desc),
x.*,
r.Input_status,
r.Data_status,
r.Reimbursement_status,
r.Coverage_Start_date,
r.Product_type
FROM	(
		select 
		--Row_Number() over( order by carrier_member_id,coverage_Start_date desc) AS INDX
		*
		from dbo.RAS_APR_Records
		where Reimbursement_status not in ('Non-Participating Employer')
		) R
	join dbo.research_id x
		on r.carrier_member_Id = x.memberid 
	order by r.Reimbursement_status
