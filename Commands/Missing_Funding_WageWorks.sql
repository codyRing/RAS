use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50),
flag bit)
insert into @client (Client,flag) values
('Atlanta Plumbers and Steamfitters','0'),
('Clorox','0'),
('DAV','0'),
('Dayco','1'),
('JM Family','0'),
('Kresge','0'),
('Noble Energy','0'),
('Savannah River','0')

Declare @coverageStartdate date = '1/1/19'
Declare @coverageenddate date = '4/30/2019'






Select 
Row_Number() over ( partition by a.funding_aid order by a.expected_Date desc) as indx,
a.Client,
p.pin,
a.Funding_AID,
a.expected_Date,
p.Pay_Date,
--p.Funding_Amount,
Sum(p.Funding_Amount)
--p.Record_Loaded_On
	from (

 select *  from 
			(
			select distinct Funding_AID,c.Client 
			FROM [RAS_APR_Reconciliation].[dbo].WW_Funding p
				join @client c
					on p.Client_Name = c.Client
			 where
				c.flag = 1 
				and Pay_Date >=@coverageStartdate
--				and p.PIN in (
--'3ATMU5AG', '4QE96F6K', '4RE7SDUH', '6FFRY839', 
--'6XXTS9AW', '754QTJB4', '8HYR59RS', 'BZVSYDBZ',
--'ETKMSAHW', 'FA2WG4KR', 'H2JUPGHY', 'H3YGQSX3', 
--'MUZTQ45S', 'QZGPSC7H', 'SFFAARPZ', 'WK3P3GN4')
			) users

	inner join 
			(
			select Date as expected_Date from dbo.Date_Dimension
			where 
			day = 1 
			and date between @coverageStartdate and @coverageenddate
			and date in (
			 '2019-04-01', 
			 '2019-01-01', 
			 '2018-10-01', 
			 '2018-07-01', 
			 '2018-04-01', 
			 '2018-01-01') --quarterly funding
			 ) CSD
					on 1=1
		) as  a

 left join  [dbo].WW_Funding p
	on a.Funding_AID = p.Funding_AID and
		a.expected_date = DATEADD(month, DATEDIFF(month, 0, p.Pay_Date), 0) 
--where 
--	p.Pay_Date is null

Group by
a.Client,
p.pin,
a.Funding_AID,
a.expected_Date,
p.Pay_Date

