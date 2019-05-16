use RAS_APR_Reconciliation
Declare @coverageStartdate date = '1/1/19'
Declare @sentlimit date = '7/1/18'
Declare @coverageenddate date = '5/1/2019'

Declare @CarrierType table(
Carrier nvarchar(50),
product_Type nvarchar(50))
Insert into @CarrierType(Carrier,product_Type)values

---Make sure to swap out carrier table below

--('Aetna',NULL),
--('Aetna','A')
--('Aetna','Medigap')
--('Aetna','Part C')
--('Aetna','Part D')
('BCBS of South Carolina','Medigap')
--('CIGNA','Medigap')
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
--('United Healthcare','Part D')
--('VSP Vision','Vision')


--truncate table dbo.research_id
--insert into dbo.Research_ID(
--CarrierID,Identifier,Identifier_Two,FirstName,LastName,Date_Of_Birth)

--Select distinct
--carrier.CarrierID,carrier.Identifier,carrier.Identifier_Two,carrier.FirstName,carrier.LastName,carrier.Date_Of_Birth



Select 
Row_Number() over ( partition by Base.carrier_member_id order by Base.expected_date desc,Reimbursement_status) as indx 
,Base.carrier_member_id
,Base.expected_date
,APR.Amount
,APR.Input_status
,APR.Reimbursement_status
,apr.Holder_AID
,APR.Product_type
,carrier.FirstName,carrier.LastName
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

				--join dbo.Research_ID r
				--	on p.Carrier_Member_id = r.CarrierID
			 where 
				Coverage_Start_date >=@sentlimit and
				Amount >0 and
			    Reimbursement_status in('sent','pending') and
				isnull(HRA_employer,'') not in ('ConAgra')	
				--and Carrier_Member_id like '025980643474'
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
		Select p.*, 
		DATEADD(month, DATEDIFF(month, 0, p.Coverage_Start_date), 0) as 'Coverage_Month_Begin'
		FROM [RAS_APR_Reconciliation].[dbo].RAS_MemberPremiumPayments p
			Join @CarrierType c
				on
					p.Carrier = c.Carrier and
					p.Product_type = c.product_Type
			 where 
				Coverage_Start_date >=@coverageStartdate and
				Amount >0 and
			    Reimbursement_status in('sent','pending','No Opt-In','none') and
				Input_status not like 'Person Not Found'	
		) APR
		
		on 
		Base.carrier_member_id = APR.carrier_member_id and
		Base.expected_date = apr.Coverage_Month_Begin

  left join  
		(
		Select Carrier.* 
		------change this table adding in carrier
		FROM dbo.Carrier_BCBS Carrier
		where 
			CoverageStart >= @coverageStartdate and
			carrier.Amount > 0
		) Carrier
		
		on 
		Base.carrier_member_id = Carrier.CarrierID and
		Base.expected_date = Carrier.CoverageStart
--where base.expected_Date = '5/1/2019'
--where apr.Payment_ID is null and carrier.Filename is not null
