  use RAS_APR_Reconciliation
Declare @mindate date = '1/1/19'
--Swap out carrier table

  select 
  Row_number() over (partition by carrier.carrierid order by CoverageStart desc) as indx
  ,carrier.CarrierID
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
		FROM [RAS_APR_Reconciliation].[dbo].Carrier_UHC b
			where 
				CoverageStart >= @mindate and
				amount >1 
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
	--r.Payment_ID is null 
	--r.Input_status like 'person not found'
	 s.Carrier_Member_id is not null



