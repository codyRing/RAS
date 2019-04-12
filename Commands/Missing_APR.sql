use RAS_APR_Reconciliation
Declare @carrier nvarchar(50) = 'Humana'
Declare @productType nvarchar(50) = '%'
Declare @coverageStartdate date = '10/1/18'
Declare @coverageenddate date = '4/1/2019'
-- carrier|Product_type
-- Aetna|
-- Aetna|A
-- Aetna|Medigap
-- Aetna|Part C
-- Aetna|Part D
-- BCBS of South Carolina|Medigap
-- CIGNA|Medigap
-- CIGNA|Part D
-- Coventry|Part C
-- Coventry|Part D
-- CVS Caremark|Part D
-- Delta of MI|Dental
-- HealthPlan of Upper Ohio|Medigap
-- HealthPlan of Upper Ohio|Part C
-- Humana|Medigap
-- Humana|Part C
-- Humana|Part D
-- IBC|Medigap
-- IBC|Part C
-- MVP|Part C
-- Slica Dental|Dental
-- United Healthcare|
-- United Healthcare|Medigap
-- United Healthcare|Part C
-- United Healthcare|Part D
-- VSP Vision|Vision

--Truncate table dbo.research_id
--insert into dbo.Research_ID (memberid,Date_Of_Birth)



Select 
--distinct a.Carrier_Member_id,a.expected_Date
Row_Number() over ( partition by a.carrier_member_id order by a.expected_date desc) as indx 
,a.carrier_member_id
,a.expected_date
,p.Coverage_Start_date as Actual_date
,p.Payment_ID
,p.[Last_Name] +', '+p.[First_Name] as Name
,p.Amount
,p.Reimbursement_status
,p.Product_type


	from (

 select *  from 
			(
			select distinct carrier_member_id 
			FROM [RAS_APR_Reconciliation].[dbo].RAS_MemberPremiumPayments p
			 where Carrier like @carrier
			 and Coverage_Start_date >=@coverageStartdate
			 and Product_type like @productType
			 and Amount >0 
			 and Reimbursement_status in('sent','pending')

			) users

	inner join 
			(
			select Date as expected_Date from dbo.Date_Dimension
			where year >= 2018 and day = 1
			and date between @coverageStartdate and @coverageenddate
			 ) CSD
					on 1=1
		) as  a

  left join  
		(Select * from [dbo].RAS_MemberPremiumPayments
		where Product_type like @productType
		and Carrier like @carrier) p
	on a.carrier_member_id = p.carrier_member_id and
		a.expected_date = p.coverage_start_date
	--where p.Coverage_Start_date is null
	--and a.expected_Date = '3/1/2019'
	--where a.Carrier_Member_id like 'H72218627'

