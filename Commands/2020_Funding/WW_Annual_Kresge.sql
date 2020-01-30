use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50),
flag bit)
insert into @client (Client) values
('Kresge')

Declare @coverageStartdate date = '1/1/19'
Declare @coverageenddate date = '12/31/2020'

Declare @debug nvarchar(50) = '5RFMS72Z'


Select 
Row_Number() over ( partition by Base.funding_aid order by Base.y desc) as indx,
Base.Client,
Base.Funding_AID,
fund.pin,
base.y,
Sum(fund.Funding_Amount),
m.RHE_Exchange,
m.Eligible,
DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Employer_Subsidy_Contribution_3
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

--where

--	isnull(fund.Xerox_Disposition,'expected') in ('none','Send to WW','expected')
--	and m.Eligible like 'yes' 
--	and fund.Pay_Date is null 
	
	--and (case when m.SubsidyStartDate>= base.expected_Date then 'fund' else null end) is null ----Should be funded??
	--and (case when base.expected_Date  > m.SubsidyStartDate then 1 else null end) = 1 ----Funded before subsidy start

	---Deceased Check
	--m.Date_Of_Death is not null
	--and (case when datepart(Q,Date_Of_Death)<= base.q then 'fund' else null end)is null --Null should be funded?
	--and (case when datepart(Q,Date_Of_Death)>= base.q then 'stop' else null end) is null --Funding should be questioned?




Group by
Base.Client,
Base.Funding_AID,
fund.pin,
base.y,
m.RHE_Exchange,
m.Eligible,
DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Employer_Subsidy_Contribution_3






--  Select 
--  Row_number() over (partition by holderssn order by relation_code),
--  pin
--  aid,
--  Holderssn,
--  RRACompanycode,
--  CNX_EmployerGroup,
--  CNX_Message,
--  TransitionDate,
--  Date_Of_Birth,
--  DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age
--,case 
--	when Date_Of_Birth >'1/1/1957' then 15095 
--	when Date_Of_Birth <='1/1/1957' then 6295

--end as subsidy

 
--  from dbo.MMAMembers m
--  where
--  Employer like 'Kresge'

--  order by Date_Of_Birth asc




--Update m
--set Employer_Subsidy_Contribution_3 = 
--case 
--	when Date_Of_Birth >'1/1/1957' then 15095 
--	when Date_Of_Birth <='1/1/1957' then 6295

--end
--  from dbo.MMAMembers m
--  where
--  Employer like 'Kresge'