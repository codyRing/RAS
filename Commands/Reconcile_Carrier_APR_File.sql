use RAS_APR_Reconciliation
Declare @mindate date = '1/1/19'
-----Make Sure To change carrier table for the correct one
-----The two APR views are recent sent pending or recent not sent pending

  select 
  Row_number() over (partition by carrier.carrierid order by CoverageStart desc) as indx
  --carrier.indx
  ,carrier.CarrierID
  ,carrier.identifier,carrier.Identifier_Two
  ,carrier.CoverageStart
  ,carrier.amount
  ,carrier.firstname
  ,carrier.lastname
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


  FROM (
		SELECT  
		row_number() over (partition by b.CarrierID order by b.CoverageStart desc) as indx,
		b.*
		FROM [RAS_APR_Reconciliation].[dbo].Carrier_Humana b		

					left join dbo.APR_Sent x
						on b.CarrierID = x.Carrier_Member_id
					
					left join dbo.APR_Not_Sent y
						on b.CarrierID = y.Carrier_Member_id
			where 
				CoverageStart >= @mindate and
				amount >1 and
				(x.Carrier_Member_id is  null and y.carrier_member_id is not  null)

		) carrier

  left join (
			Select  
				Row_number() over (partition by r.carrier_member_id order by r.Coverage_Start_date desc) as indx,
				r.*
				from dbo.[RAS_MemberPremiumPayments] R
				) r
		on 
			carrier.CarrierID = r.Carrier_Member_id and
			carrier.CoverageStart = r.Coverage_Start_date and
			carrier.amount = r.amount
--where r.Payment_ID is  null
