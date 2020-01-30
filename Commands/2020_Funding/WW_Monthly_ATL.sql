use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50),
flag bit)
insert into @client (Client) values
('Atlanta Plumbers and Steamfitters')

Declare @coverageStartdate date = '6/1/19'
Declare @coverageenddate date = '1/31/2020'

Declare @debug nvarchar(50) = 'KFTNC6E7'


Select 
Row_Number() over ( partition by Base.funding_aid order by Base.expected_date desc) as indx,
Base.Client,
Base.Funding_AID,
fund.pin,
base.expected_date,
Sum(fund.Funding_Amount),
m.Eligible,
DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.SubsidyType,
m.Employer_Subsidy_Contribution_1
--m.Date_Of_Death,
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

			select Date as expected_Date 
			from dbo.Date_Dimension
			where 
			day = 1 
			and date between @coverageStartdate and @coverageenddate
			


			 ) CSD
					on 1=1
		) as  base
	
	left join  [dbo].WW_Funding fund
		on base.Funding_AID = fund.Funding_AID and
		base.expected_date = DATEADD(month, DATEDIFF(month, 0,fund.Pay_Date), 0) 


	left join dbo.MMAMembers m
		on base.Funding_AID = m.AID

where
base.expected_Date = '1/1/2020'
and fund.Pay_Date is null




----Current Funding----------------------
--where
--isnull(m.SubsidyType,'')  like 'M'
--and m.Eligible like 'yes'
--and (case when base.expected_Date < m.SubsidyStartDate then 1 else 0 end ) = 0
----and (case when base.expected_Date <= isnull(m.subsidyenddate,getdate()) then 1 else 0 end ) = 1
--and (case when base.expected_Date <= isnull(m.subsidyenddate,'2020-01-01') then 1 else 0 end ) = 1
--and fund.Pay_Date is not null
--and base.expected_Date = '1/1/2020'








	
	--and (case when m.SubsidyStartDate>= base.expected_Date then 'fund' else null end) is null ----Should be funded??
	--and (case when base.expected_Date  > m.SubsidyStartDate then 1 else null end) = 1 ----Funded before subsidy start

	---Deceased Check
	--m.Date_Of_Death is not null
	--and (case when datepart(Q,Date_Of_Death)<= base.q then 'fund' else null end)is null --Null should be funded?
	--and (case when datepart(Q,Date_Of_Death)>= base.q then 'stop' else null end) is null --Funding should be questioned?




Group by
base.Client,
fund.pin,
base.Funding_AID,
base.expected_Date,

m.Eligible,
DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Date_Of_Death,
m.Employer_Subsidy_Contribution_1,
m.SubsidyType
--benefitwallet_disposition


--order by SubsidyEndDate

  
  --Select 
  --Row_number() over (partition by holderssn order by relation_code),
  --pin,
  --aid,
  --Holderssn,
  --RRACompanycode,
  --CNX_EmployerGroup,
  --CNX_Message,
  --Date_Of_Birth,
  --DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age
  --from dbo.MMAMembers m
  --where Employer like 'clorox'
  --and RRACompanycode like 'CONSOLIDATED PLAN' 
  --and CNX_EmployerGroup like 'F,F,F'
  --order by Date_Of_Birth asc