use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50))
insert into @client (Client) values
--('Atlanta Plumbers and Steamfitters')
--('Clorox')
--('DAV')
--('Dayco')
--('JM Family'),
--('Kresge'),
--('Noble Energy'),
('Savannah River')

Declare @coverageStartdate date = '1/1/19'
Declare @coverageenddate date = '10/30/2019'






Select 
Row_Number() over ( partition by Base.funding_aid order by Base.expected_Date desc) as indx,
Base.Client,
Base.Funding_AID,
Base.expected_Date,
--DATEADD(month, DATEDIFF(month, 0, fund.Pay_Date), 0), 
Sum(fund.Funding_Amount) as funding,
m.Eligible,m.SubsidyStartDate,m.SubsidyEndDate,
m.Holderssn,m.pin
	from (

 select *  from 
			(
			select distinct Funding_AID,c.Client 
			FROM [RAS_APR_Reconciliation].[dbo].WW_Funding p
				join @client c
					on p.Client_Name = c.Client
			 where
				 Pay_Date >=@coverageStartdate

			) users

	inner join 
			(
			select Date as expected_Date from dbo.Date_Dimension
			where 
			day = 1 
			and date between @coverageStartdate and @coverageenddate
			--and date in (
			-- '2019-10-01',
			-- '2019-07-01',
			-- '2019-04-01', 
			-- '2019-01-01', 
			-- '2018-10-01', 
			-- '2018-07-01', 
			-- '2018-04-01', 
			-- '2018-01-01') --quarterly funding
			 ) CSD
					on 1=1
		) as  base

	left join  [dbo].WW_Funding fund
		on base.Funding_AID = fund.Funding_AID and
			base.expected_date = DATEADD(month, DATEDIFF(month, 0,fund.Pay_Date), 0) 

	left join dbo.MMAMembers m
		on base.Funding_AID = m.AID
where 
	m.Eligible like 'yes' 
	and fund.Pay_Date is null 
	and (case when base.expected_date <= m.SubsidyEndDate then 'true' end) = 'true' 
	and (case when base.expected_Date >= m.SubsidyStartDate then 'true' end ) = 'true'


Group by
base.Client,
base.Funding_AID,
base.expected_Date,
m.Eligible,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Holderssn,
m.pin

--order by SubsidyEndDate desc