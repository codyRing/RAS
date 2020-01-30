use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50),
flag bit)
insert into @client (Client) values
('Noble Energy')

Declare @coverageStartdate date = '1/1/2019'
Declare @coverageenddate date = '12/31/2020'
Declare @debug nvarchar(50) = '5RFMS72Z'
--Declare @limit date = '12/31/2019'



Select 
Row_Number() over ( partition by m.SSN, Base.funding_aid order by Base.y desc) as indx,
Base.Client,
m.SSN,
Base.Funding_AID,
fund.pin,
base.y,
Sum(fund.Funding_Amount),
m.SubsidyType,
m.Eligible,
DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age,
m.date_of_Birth,
m.SubsidyType,
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

where
base.y = 2020
--SubsidyType not like 'N'
--and m.EmployerSubsidyContrib not like '6946.00'
AND fund.Pay_Date is  null






------65 before 12/31/2019
--m.Date_Of_Birth <='1954-12-31'
--and base.y = 2020
--and fund.Pay_Date is not null





Group by
Base.Client,
m.SSN,
Base.Funding_AID,
fund.pin,
base.y,
m.SubsidyType,
m.Eligible,
DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END,
m.date_of_Birth,
SubsidyType,
m.EmployerSubsidyContrib





