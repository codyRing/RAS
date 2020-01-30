use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50),
flag bit)
insert into @client (Client) values
('Dayco')

Declare @coverageStartdate date = '1/1/19'
Declare @coverageenddate date = '1/31/2020'

Declare @debug nvarchar(50) = 'WK3P3GN4'


Select 
Row_Number() over ( partition by Base.funding_aid order by Base.y desc,base.q desc) as indx,
Base.Client,
Base.Funding_AID,
fund.pin,
base.y,
base.q,
Sum(fund.Funding_Amount),
EmployerSubsidyContrib,
--Employer_Subsidy_Contribution_1,
--Employer_Subsidy_Contribution_2,
--m.Employer_Subsidy_Contribution_3,
m.SubsidyType,
m.Eligible,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Date_Of_Birth
--m.Date_Of_Death
--datepart(Q,m.Date_Of_Death)
--WageWorks_Disposition
	from (


select *  from 
			(
			select distinct Funding_AID,c.Client 
			FROM [RAS_APR_Reconciliation].[dbo].WW_Funding p
				join @client c
					on p.Client_Name = c.Client
			 where
				Pay_Date >=@coverageStartdate
				--and pin like @debug
			) users

	inner join 
			(

			Select 
			distinct
			year as y,
			QuarterNumber as q
			from dbo.Date_Dimension
			where date between @coverageStartdate and @coverageenddate


			 ) CSD
					on 1=1
		) as  base
	
	left join  [dbo].WW_Funding fund
		on base.Funding_AID = fund.Funding_AID and

		base.y = datepart(yyyy,fund.pay_date) and
		base.q = datepart(q,fund.pay_date)

	left join dbo.MMAMembers m
		on base.Funding_AID = m.AID

where

	isnull(fund.Xerox_Disposition,'expected') in ('none','Send to WW','expected')
	and m.Eligible like 'yes' 
    and fund.Pay_Date is  null 
	
	--and (case when datepart(Q,SubsidyStartDate)>= base.q then 'fund' else null end) is null

	---Deceased Check
	--m.Date_Of_Death is not null
	--and (case when datepart(Q,Date_Of_Death)<= base.q then 'fund' else null end)is null --Null should be funded?
	--and (case when datepart(Q,Date_Of_Death)>= base.q then 'stop' else null end) is null --Funding should be questioned?




Group by
Base.Client,
Base.Funding_AID,
fund.pin,
base.y,
base.q,
EmployerSubsidyContrib,
--Employer_Subsidy_Contribution_1,
--Employer_Subsidy_Contribution_2,
--m.Employer_Subsidy_Contribution_3,
m.SubsidyType,
m.Eligible,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Date_Of_Birth
--m.Date_Of_Death
--datepart(Q,m.Date_Of_Death)
--WageWorks_Disposition



--update a
--set Employer_Subsidy_Contribution_2 =
--Employer_Subsidy_Contribution_1/4
--from dbo.MMAMembers a
--where employer like 'Dayco'
--and yos is not null








--declare @aid nvarchar(50) = '181721'
--declare @hssn nvarchar(50) =(select distinct holderssn from dbo.MMAMembers where aid like @aid)
--Declare @pin nvarchar(50) =(select distinct pin from dbo.MMAMembers where ssn like @hssn)
--Declare @limit date = '12/31/2019'

 
--  Select 
--  Row_number() over (partition by holderssn order by relation_code),
--  m.First_Name,
--  m.Last_Name,
--  relation_code,
--  pin,
--  aid,
--  Holderssn,
--  RRACompanycode,
--RHE_Exchange,
--  TransitionDate,
--  Date_Of_Birth,
--  DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age,
--  --DATEDIFF(YY, Date_Of_Birth, @limit) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(@limit)*100 + DAY(@limit)) ) THEN 1 ELSE 0 END as age_at_Limit,
--m.EmployerSubsidyContrib,
--m.SubsidyType

 
--  from dbo.MMAMembers m
--  where
--  --Employer like 'Atlanta%'
-- --and SubsidyType like 'M'
--  Holderssn like @hssn