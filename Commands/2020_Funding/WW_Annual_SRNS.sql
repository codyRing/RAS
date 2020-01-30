use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50),
flag bit)
insert into @client (Client) values
('Savannah River')

Declare @coverageStartdate date = '1/1/18'
Declare @coverageenddate date = '12/31/2020'


Declare @aid  nvarchar(50) =  '172895'
Declare @hssn nvarchar(50) = (select Holderssn from dbo.MMAMembers where aid like @aid)
Declare @debug nvarchar(50) = (select pin from dbo.MMAMembers where SSN like @hssn)

--Declare @debug nvarchar(50) = 'QZEXJHFP'


Select 
Row_Number() over ( partition by Base.funding_aid order by Base.y desc) as indx,
Base.Client,
Base.Funding_AID,
fund.pin,
base.y,
Sum(fund.Funding_Amount),
m.SubsidyType,
m.RHE_Exchange,

m.Eligible,

DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.EmployerSubsidyContrib
	from (


select *  from 
			(
			select distinct Funding_AID,c.Client 
			FROM [RAS_APR_Reconciliation].[dbo].WW_Funding p
				join @client c
					on p.Client_Name = c.Client
			 where
				Pay_Date >=@coverageStartdate
				and pin like @debug
			) users

	inner join 
			(

			select 
			distinct year as y
			
			--Date as expected_Date 
			from dbo.Date_Dimension
			where 
			date between @coverageStartdate and @coverageenddate
			


			 ) CSD
					on 1=1
		) as  base
	
	left join  [dbo].WW_Funding fund
		on base.Funding_AID = fund.Funding_AID and
		base.y = datepart(yyyy,fund.pay_date)


	left join dbo.MMAMembers m
		on base.Funding_AID = m.AID

where

	isnull(fund.Xerox_Disposition,'expected') in ('none','Send to WW','expected')
	and m.Eligible like 'yes' 
	--and fund.Pay_Date is ndatepart(yy,m.subsidystartdate)ot  null 
	
	--and (case when datepart(yy,m.subsidystartdate) > base.y then 'fund' else null end) like 'fund' ----Should be funded??
	--and (case when base.expected_Date  > m.SubsidyStartDate then 1 else null end) = 1 ----Funded before subsidy start

	---Deceased Check
	--m.Date_Of_Death is not null
	--and (case when datepart(Q,Date_Of_Death)<= base.q then 'fund' else null end)is null --Null should be funded?
	--and (case when datepart(Q,Date_Of_Death)>= base.q then 'stop' else null end) is null --Funding should be questioned?




Group by
base.Client,
fund.pin,
base.Funding_AID,
base.y,
m.SubsidyType,
m.RHE_Exchange,
m.Eligible,
DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END,
m.SubsidyStartDate,
m.SubsidyEndDate,
--m.Date_Of_Death,
EmployerSubsidyContrib




Select
'WW_Funding' as 'source',
Row_number () over( partition by f.pin,f.funding_aid order by pay_date desc),
f.pin,
f.Account_SSN,
f.Last_Name,
f.First_Name,
f.Funding_AID,
f.Funding_Amount,
f.Pay_Date,
 CONVERT(VARCHAR(7), f.Pay_Date, 120) as pay_month,
f.Xerox_Disposition,
f.Wageworks_Disposition,
File_Creation_Date
From dbo.Ww_funding f
where f.pin like @debug

select 
RELATION_CODE,
aid,
pin,
ssn,
First_Name,
Last_Name,
Employer
 from dbo.MMAMembers
where Holderssn like @hssn