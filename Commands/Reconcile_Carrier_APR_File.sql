  use RAS_APR_Reconciliation
Declare @mindate date = '1/1/19'


  select 
  --Row_number() over (partition by carrier.carrierid order by CoverageStart desc) as indx
  carrier.CarrierID
  ,carrier.identifier,carrier.Identifier_Two
  ,carrier.CoverageStart
  ,carrier.amount
  ,carrier.firstname
  ,carrier.lastname
  ,r.Carrier
  ,r.Payment_ID
  ,r.Product_type
  --,r.Coverage_Start_date
  --,r.Coverage_End_date
  ,HRA_employer
  ,r.Input_status
  ,r.Data_status
  ,r.Reimbursement_status
  ,r.Amount
  ,r.Carrier_Member_id
  ,r.file_date
  ,r.Data_status
  ,r.Input_status
  ,r.Reimbursement_status
  ,carrier.filename
  FROM 
		(
		SELECT  
		row_number() over (partition by b.CarrierID order by b.CoverageStart desc) as indx,
		b.*
		FROM [RAS_APR_Reconciliation].[dbo].Carrier_aetna b
			where 
				CoverageStart >= @mindate and
				amount >1 
				--and filename like 'DESTINATIONRX_HRA_2019_OnlyHICN.txt%'
		) carrier

  left join 
		(
		Select  
		Row_number() over (partition by r.carrier_member_id order by r.Coverage_Start_date desc) as indx,
		r.*
		from dbo.[RAS_MemberPremiumPayments] R
			) r
		on 
			carrier.CarrierID = r.Carrier_Member_id and
			carrier.CoverageStart = r.Coverage_Start_date 
			and round(carrier.amount,0,1) = round(r.amount,0,1)
  
------Toggle to limit user getting monthly 'sent' payments

  --left join dbo.APR_not_Sent s
  left join dbo.APR_Sent s
	on carrier.CarrierID = s.Carrier_Member_id 

where
	r.Payment_ID is null  
	--r.Input_status like 'person not found'
	--carrier.LastName like 'WILLIAMS'
	--carrier.Filename  like 'AETNA_MEDIGAP_HRA_2825_20191102.TXT'
	--and carrier.LastName like 'hall'
	--and carrier.CoverageStart >='9/1/2019'
--	and carrier.CarrierID not in (
--'019164061-1'
--,'A02156650'
--,'A00686580')
order by carrier.Filename desc,carrier.CoverageStart desc



Select
filename,
count(*)
from dbo.Carrier_Humana
group by filename
order by filename desc

--Update a
--set product_Type = 'Part D'
--from dbo.RAS_MemberPremiumPayments a
--where carrier like 'Coventry'
--and Product_type like 'Part C'

--Select distinct product_type
--from dbo.RAS_MemberPremiumPayments
--where carrier like 'aetna'

--select * from dbo.Carrier_UHC 
--where CarrierID like '020402445-1'





