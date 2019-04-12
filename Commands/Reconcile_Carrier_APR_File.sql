  use RAS_APR_Reconciliation
Declare @mindate date = '1/1/19'

  select 
  Row_number() over (partition by carrier.memberid order by coverageperiodstart desc) as indx
  ,carrier.memberid
  ,carrier.identifier
  ,carrier.coverageperiodstart
  ,carrier.amount
  ,carrier.firstname
  ,carrier.lastname
  ,r.Payment_ID
  ,r.Coverage_Start_date
  ,r.Coverage_End_date
  ,r.Data_status
  ,r.Input_status
  ,r.Reimbursement_status
  ,Product_type
  ,r.Amount
  ,r.Carrier_Member_id
  ,r.file_date
  ,r.Data_status
  ,r.Input_status
  ,r.Reimbursement_status
  ,carrier.filename
  FROM (
		SELECT  
		row_number() over (partition by b.memberid order by b.coverageperiodstart desc) as indx,
		b.*
		FROM [RAS_APR_Reconciliation].[dbo].UHC b		
		
			where 
				CoveragePeriodStart >= @mindate 
		) carrier

	 left join dbo.[RAS_MemberPremiumPayments] R
		on 
			carrier.memberid = r.Carrier_Member_id and
			carrier.CoveragePeriodStart = r.Coverage_Start_date and
			carrier.amount = r.amount
Where
	carrier.Amount > 0 AND
	Payment_ID is  null

