use RAS_APR_Reconciliation
---------------------------------------------With DOB----------------
Declare @mindate date = '1/1/18'

--Step one get APR File Identifiers that appear to be MBI's
Truncate table dbo.research_id
insert into dbo.research_id (Identifier,MemberID,lastname,firstname,Date_Of_Birth)

select distinct
a.Identifier,a.MemberID,a.lastname,a.firstname,Date_Of_Birth
   FROM (
		SELECT  row_number() over (partition by memberid order by coverageperiodstart desc) as indx
		,*
		 --FROM [RAS_APR_Reconciliation].[dbo].Cigna_medigap
		 FROM [RAS_APR_Reconciliation].[dbo].CVS -----Does Have DOB
		 --FROM [RAS_APR_Reconciliation].[dbo].Coventry
		--FROM [RAS_APR_Reconciliation].[dbo].Cigna_medigap
		 --FROM [RAS_APR_Reconciliation].[dbo].UHC ------PDP file does not have DOB
		 --FROM [RAS_APR_Reconciliation].[dbo].Humana
		where CoveragePeriodStart >= @mindate
		--and Filename like '%missed%'
		) A
where 
   len(a.Identifier)>= 11 
  and SUBSTRING(identifier,1,1) like '[0-9]'
  and SUBSTRING(identifier,5,1) like '[a-zA-Z]'


---Get HICN's from prior APR records based on Carrier ID
;with a as(
	select distinct
	t.identifier,
	r.HICN,
	r.First_Name,r.Last_Name
	from dbo.RAS_MemberPremiumPayments r
		join dbo.research_id t
			on r.Carrier_Member_id = t.memberid
	where r.HICN not like ''
),


----Get SSN's from MMA members based on First and Last Name and DOB
b as(
	Select distinct
	t.firstname,
	t.lastname,
	t.Identifier,
	m.ssn,
	m.aid 
	from RAS_Reconciliation.dbo.MMAMembers m
		join dbo.research_id t
			on 
			m.LastName = t.lastname 
			and m.FirstName = t.firstname 
			and m.DateOfBirth = t.Date_Of_Birth
			--left(a.hicn,9) = m.SSN
			)		

---Join together on MBI and only keep records where first 9 of HICN match SSN
select 
	Row_number() over(partition by a.Identifier order by a.last_name),
	'Carrier ID and HICN/SSN/name/dob Match',
	a.First_Name,a.Last_Name,B.AID,
	a.Identifier as MBI,
	b.SSN,
	a.hicn
	from a 
		join b
			on a.identifier =b.identifier
	where (case when left(a.hicn,9) = b.ssn then 'true' else null end) = 'true'
	




	---Just look at ssn
		select 
		'Name and DOB',
		Row_number() over(partition by r.identifier order by m.ssn) as sort,
		r.firstname,
		r.lastname,
		m.Date_Of_Birth, r.Date_Of_Birth,
		r.identifier,				
		m.SSN,
		null as hicn
		from dbo.MMAMembers m
			right join dbo.research_id r
		on 
		m.First_Name = r.firstname 
		and m.Last_Name = r.lastname 
		and m.Date_Of_Birth = r.date_Of_birth
		where m.SSN is not null 



----Add Address into dbo.research_ID
--select 
--a.Identifier,a.FirstName,a.LastName,m.Address_1,m.Zip 

--from dbo.Research_ID a
--	join dbo.MMAMembers m
--		on a.FirstName = m.First_Name and
--		a.LastName = m.Last_Name