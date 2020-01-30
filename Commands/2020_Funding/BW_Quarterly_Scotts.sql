use RAS_APR_Reconciliation
Declare @client Table(
Client nvarchar(50),
flag bit)
insert into @client (Client) values
('scotts')

Declare @coverageStartdate date = '1/1/19'
Declare @coverageenddate date = '1/31/2020'

Declare @debug nvarchar(50) = '173716'





Select 
Row_Number() over ( partition by Base.funding_aid order by Base.y desc,base.q desc) as indx,
Base.Client,
Base.Funding_AID,
fund.Aid,
base.y,
base.q,
Sum(fund.Funding_Amount),
Employer_Subsidy_Contribution_2,
m.Eligible,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Date_Of_Death,
datepart(Q,m.Date_Of_Death),
benefitwallet_disposition
	from (

 select *  from 
			(
			select distinct Funding_AID,c.Client 
			FROM [RAS_APR_Reconciliation].[dbo].BW_Funding p
				join @client c
					on p.Client_Name = c.Client
			 where
				Pay_Date >=@coverageStartdate
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

	left join  [dbo].BW_Funding fund
		on base.Funding_AID = fund.Funding_AID and

		base.y = datepart(yyyy,fund.pay_date) and
		base.q = datepart(q,fund.pay_date)

	left join dbo.MMAMembers m
		on base.Funding_AID = m.AID

	where 
	isnull(fund.benefitwallet_disposition,'expected') in ('none','BW Accepted','expected')
	and fund.Pay_Date is not null 
	and m.Eligible like 'yes' 
	and (case 
				when datepart(Q,SubsidyStartDate)>= base.q and
				     datepart(YY,SubsidyStartDate)>= base.y
					then 1 else 0 end) =0
	--and base.y = 2020
	
	
	---Deceased Check
	--m.Date_Of_Death is not null
	--and (case when datepart(Q,Date_Of_Death)<= base.q then 'fund' else null end)is null --Null should be funded?
	--and (case when datepart(Q,Date_Of_Death)>= base.q then 'stop' else null end) is null --Funding should be questioned?

	------increase members------------------------------------------------
	--where base.Funding_AID in (
	--		select aid
	--		from dbo.MMAMembers
	--		where Employer like 'scotts'
	--		and yos<='23'
	--		and Retirement_Date <='1/2/1994'
	--		)
	

Group by
base.Client,
fund.Aid,
base.Funding_AID,
base.y,
base.q,
Employer_Subsidy_Contribution_2,
m.Eligible,
m.SubsidyStartDate,
m.SubsidyEndDate,
m.Date_Of_Death,
benefitwallet_disposition







--Select
--aid,
--pin,
--First_Name,
--Last_Name,
--Date_Of_Birth,
--DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age, 
--YOS,
--Retirement_Date,
--EmployerSubsidyContrib
----SubsidyStartDate
--,case
--	when Retirement_Date <= '1/1/1981' then 3183
--	when Retirement_Date <= '1/1/1994' then 2622
--	when YOS = 10 then 546
--	when YOS = 11 then 656
--	when yos >=12 and yos <=21 then 765+ (109 *(yos -12)) --12-21 yos --2622 verified
--	when yos = 22 then 1858
--	when yos = 23 then 1967
--	when yos >= 24 then 2000

--end as subsidy


--from dbo.MMAMembers
--where Employer like 'scotts'
--and aid like @debug
----and  yos >=12 and yos <=21
----and Retirement_Date <='1/2/1994'
--order by yos asc




--update a
--set Employer_Subsidy_Contribution_2 =
--case
--	when Retirement_Date <= '1/1/1981' then 3183
--	when Retirement_Date <= '1/1/1994' then 2701
--	when YOS = 10 then 562
--	when YOS = 11 then 676
--	when yos >=12 and yos <=21 then 788+ (112.5 *(yos -12)) --12-21 yos --2622 verified
--	when yos = 22 then 1914
--	when yos >= 23 then 2000


--end

--from dbo.MMAMembers a
--where employer like 'scotts'
--and yos is not null


--update a
--set Employer_Subsidy_Contribution_2 =
--Employer_Subsidy_Contribution_2/4

--from dbo.MMAMembers a
--where employer like 'scotts'
--and yos is not null




--update m
--set yos = substring(yos,0,charindex('.',yos))
--from dbo.MMAMembers m
--where yos is not null
--and yos like '%.%'