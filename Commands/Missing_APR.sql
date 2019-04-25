use RAS_APR_Reconciliation
Declare @coverageStartdate date = '1/1/19'
Declare @coverageenddate date = '4/1/2019'

Declare @CarrierType table(
Carrier nvarchar(50),
product_Type nvarchar(50))
Insert into @CarrierType(Carrier,product_Type)values

---Make sure to swap out carrier table below

--('Aetna',NULL),
--('Aetna','A')
('Aetna','Medigap')
--('Aetna','Part C')
--('Aetna','Part D')
--('BCBS of South Carolina','Medigap')
--('CIGNA','Medigap'),
--('CIGNA','Part D'),
--('Coventry','Part C')
--('Coventry','Part D')
--('CVS Caremark','Part D')
--('Delta of MI','Dental'),
--('Humana','Medigap'),
--('Humana','Part C'),
--('Humana','Part D'),
--('Slica Dental','Dental'),
--('United Healthcare',NULL),
--('United Healthcare','Medigap')
--('United Healthcare','Part C'),
--('United Healthcare','Part D'),
--('VSP Vision','Vision')




Select 
Row_Number() over ( partition by Base.carrier_member_id order by Base.expected_date desc,Reimbursement_status) as indx 
,Base.carrier_member_id
,Base.expected_date
,APR.Amount
,APR.Input_status
,APR.Reimbursement_status
,APR.Carrier
,APR.Product_type
,carrier.Filename


	from (

 select *  from 
			(
			select distinct carrier_member_id 
			FROM [RAS_APR_Reconciliation].[dbo].RAS_MemberPremiumPayments p
				Join @CarrierType c
					on
						p.Carrier = c.Carrier and
						p.Product_type = c.product_Type
			 where 
				Coverage_Start_date >=@coverageStartdate and
				Amount >0 and
			    Reimbursement_status in('sent','pending')	
			) users

	inner join 
			(
			select Date as expected_Date 
			from dbo.Date_Dimension
			where year >= 2018 and day = 1
			and date between @coverageStartdate and @coverageenddate
			 ) CSD
					on 1=1
		) as  Base

  left join  
		(
		Select p.* 
		FROM [RAS_APR_Reconciliation].[dbo].RAS_MemberPremiumPayments p
			Join @CarrierType c
				on
					p.Carrier = c.Carrier and
					p.Product_type = c.product_Type
		) APR
		
		on Base.carrier_member_id = APR.carrier_member_id and
		Base.expected_date = APR.coverage_start_date

  left join  
		(
		Select Carrier.* 
		FROM dbo.Aetna Carrier
		where CoveragePeriodStart >= @coverageStartdate
		) Carrier
		
		on 
		Base.carrier_member_id = Carrier.MemberID and
		Base.expected_date = Carrier.CoveragePeriodStart

			