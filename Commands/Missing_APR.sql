use RAS_APR_Reconciliation
Declare @coverageStartdate date = '2/1/19'
Declare @sentlimit date = '7/1/18'
Declare @coverageenddate date = '11/1/2019'

Declare @CarrierType table(
Carrier nvarchar(50),
product_Type nvarchar(50))
Insert into @CarrierType(Carrier,product_Type)values

---Make sure to swap out carrier table below

--('Aetna',NULL),
--('Aetna','A')
--('Aetna','Medigap')
--('Aetna','Part C'),
--('Aetna','Part D')
--('BCBS of South Carolina','Medigap')
--('CIGNA','Medigap')
--('CIGNA','Part D'),
--('Coventry','Part C'),
--('Coventry','Part D')
--('CVS Caremark','Part D')
--('Delta of MI','Dental'),
--('Humana','Medigap'),
--('Humana','Part C'),
--('Humana','Part D')
--('Slica Dental','Dental'),
--('United Healthcare',NULL),
('United Healthcare','Medigap')
--('United Healthcare','Part C'),
--('United Healthcare','Part D')
--('VSP Vision','Vision')

Select 
Row_Number() over ( partition by  Base.carrier_member_id,base.product_Type order by Base.expected_date desc,Reimbursement_status) as indx 
,Base.carrier_member_id
,Base.Product_type
,Base.expected_Date
,carrier.FirstName,carrier.LastName,carrier.Identifier
,APR.Amount
,APR.Input_status
,APR.Data_status
,APR.Reimbursement_status
,carrier.filename
from
	(
	select 
	*
	from
		(
		select 
		distinct 
		r.carrier_member_id,
		r.Product_type
		from dbo.APR_Sent r
			Join @CarrierType c
				on
					r.Carrier = c.Carrier and
					r.Product_type = c.product_Type
		where 
			r.Sent_or_Pending >=@coverageStartdate

			
		--select 
		--r.CarrierID as carrier_Member_id
		--,c.product_Type
		--from dbo.Research_ID r
		--	join @CarrierType c
		--		on 1 = 1
		) users
			
		inner join 
		
		(
		select 
		Date as expected_Date 
		from dbo.Date_Dimension
		where year >= 2018 and day = 1
		and date between @coverageStartdate and @coverageenddate
		 ) CSD
			on 1=1
	) as  Base
	
		left join  
		(
		Select p.*, 
		DATEADD(month, DATEDIFF(month, 0, p.Coverage_Start_date), 0) as 'Coverage_Month_Begin'
		FROM [RAS_APR_Reconciliation].[dbo].RAS_MemberPremiumPayments p
			Join @CarrierType c
				on
					p.Carrier = c.Carrier and
					p.Product_type = c.product_Type
			 where 
				Coverage_Start_date >=@coverageStartdate and
				Amount >0 
			    --and Reimbursement_status in ('SENT','pending','none','no opt-in') and input_status not like 'person Not Found'
				--and (Input_status like 'Person Not Found'	or Reimbursement_status like 'sent')
		) APR
		on 
		Base.carrier_member_id = APR.carrier_member_id and
		Base.Product_type = APR.product_Type and
		Base.expected_date = apr.Coverage_Month_Begin

		left join  
		(
		Select Carrier.* 
		------change this table adding in carrier
		FROM dbo.Carrier_uhc Carrier
		where 
			CoverageStart >= @coverageStartdate and
			carrier.Amount > 0 
		) Carrier
		
		on 
			Base.carrier_member_id = Carrier.CarrierID and
			Base.expected_date = Carrier.CoverageStart 
			--and apr.Amount = carrier.Amount
--where
	--apr.Payment_ID is null and carrier.Filename is not null
	--and expected_Date >= '7/1/19'
--order by expected_Date