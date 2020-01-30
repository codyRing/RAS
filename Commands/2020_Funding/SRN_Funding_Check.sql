use [RAS_Reconciliation]
go

--populate temp tables
If(OBJECT_ID('tempdb..#sr_funding_2020') Is Not Null) drop table #sr_funding_2020
If(OBJECT_ID('tempdb..#sr_funding_2019') Is Not Null) drop table #sr_funding_2019

select 
	  m1.[LastName]
	, m1.[FirstName]
	, m1.[AID]
	, m1.[SSN] as [Member SSN]
	, w.[PIN] as [AH PIN]
	, m2.[SSN] as [AH SSN]
	, m1.[RELATIONCODE]
	, sum(convert(numeric(18,2),w.[PRE TAX PROGRAM SPONSOR CONTR  ADDITIONAL BENEFIT])) as [FundingAmt]
into #sr_funding_2020
from [dbo].[WW_FundingRecords] w
left outer join [dbo].[MMAMembers] m1
	on m1.[AID] = w.[FundingAid]
left outer join [dbo].[MMAMembers] m2
	on m2.[PIN] = w.[PIN]
where
	[ClientName] = 'Savannah River'
	and convert(date,[FundingDate]) = convert(date,'2020-01-01')
	and [XeroxDisposition] <> 'Ignore'
	and [WageWorksDisposition] <> 'WW Ignored'
group by
	  m1.[LastName]
	, m1.[FirstName]
	, m1.[AID]
	, m1.[SSN]
	, w.[PIN]
	, m2.[SSN]
	, m1.[RELATIONCODE]

select 
	  m1.[LastName]
	, m1.[FirstName]
	, m1.[AID]
	, m1.[SSN] as [Member SSN]
	, w.[PIN] as [AH PIN]
	, m2.[SSN] as [AH SSN]
	, m1.[RELATIONCODE]
	, sum(convert(numeric(18,2),w.[PRE TAX PROGRAM SPONSOR CONTR  ADDITIONAL BENEFIT])) as [FundingAmt]
into #sr_funding_2019
from [dbo].[WW_FundingRecords] w
left outer join [dbo].[MMAMembers] m1
	on m1.[AID] = w.[FundingAid]
left outer join [dbo].[MMAMembers] m2
	on m2.[PIN] = w.[PIN]
where
	[ClientName] = 'Savannah River'
	and convert(date,[FundingDate]) >= convert(date,'2019-01-01') and convert(date,[FundingDate]) <= convert(date,'2019-12-31')
	and [XeroxDisposition] <> 'Ignore'
	and [WageWorksDisposition] <> 'WW Ignored'
group by
	  m1.[LastName]
	, m1.[FirstName]
	, m1.[AID]
	, m1.[SSN]
	, w.[PIN]
	, m2.[SSN]
	, m1.[RELATIONCODE]

--select * from #sr_funding_2019

--check 2020 Savannah River funding
select 
	  case when f20.[FundingAmt] is null then 'FALSE' else 'TRUE' end as [Funded in 2020?]
	, case when f19.[FundingAmt] is null then 'FALSE' else 'TRUE' end as [Funded in 2019?]
	, case when m.[DECEASED] = 'Y' then 'TRUE' else 'FALSE' end as [Deceased?]
	, m.[LastName]
	, m.[FirstName]
	, m.[AID]
	, m.[SSN]
	, m.[DateOfBirth]
	, case when f20.[AH SSN] is not null then f20.[AH SSN] else f19.[AH SSN] end as [AH SSN]
	, case when f20.[AH PIN] is not null then f20.[AH PIN] else f19.[AH PIN] end as [AH PIN]
	, m.[RELATIONCODE]
	, isnull(f20.[FundingAmt],0) as [2020 Funding]
	, isnull(f19.[FundingAmt],0) as [2019 Funding]
from [dbo].[MMAMembers] m
left outer join #sr_funding_2020 f20
	on f20.[AID] = m.[AID]
left outer join #sr_funding_2019 f19
	on f19.[AID] = m.[AID]
where isnull(f19.[FundingAmt],0) > 0 or isnull(f20.[FundingAmt],0) > 0 --funded in either 2019 or 2020
order by m.[LastName], m.[FirstName], m.[DateOfBirth]
