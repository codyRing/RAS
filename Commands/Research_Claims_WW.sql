use [RAS_APR_Reconciliation]
declare @last nvarchar(50) = 'chapman%'
declare @first nvarchar(50) = 'jennifer%'
declare @ID_Code nvarchar(50) =  '2307'
select 
--row_number() over ( partition by ID_Code order by service_start_Date desc,claim desc)
row_number() over ( partition by ID_Code order by paid_date desc)
,filename
,last_name,first_name as name
--,Patient_LastName	, Patient_FirstName as patient_name
,ID_Code
,claim
,amount
,Claim_Id
,[Paid_Date]
,Service_Start_Date	
,Service_End_Date
,Payment_type
,category
,Patient_Relationship
FROM [dbo].[WW_Claims]
where (Last_Name like @last and First_Name like @first) 
--and ID_Code like @ID_Code
--and amount = '180.97'
--and Service_Start_Date = '4/1/2019'
--and filename not like 'JM_Family_18.CSV'



select 
filename
,last_name +','+first_name as name
,ID_Code
,Available_Balance
-----Reconcile these 4 will/should equal availabile balance---------
,TOTAL_CONTRIBUTIONS_ALL --All funding including Balance Transfer
,Total_Transfers --Combine with total contributions to find New Ras funding + Migration
,0- TOTAL_PAYMENTS_AUTHORIZED as TOTAL_PAYMENTS_AUTHORIZED --Claims need to invert
,Total_Repayments---????
----------------
,Insert_date
 from (
		Select 
		Row_Number() over (partition by filename,id_Code,last_name order by insert_Date desc) as indx,
		*
		From dbo.WW_AccountActivity
		where (Last_Name like @last and First_Name like @first) 
		--and ID_Code like @ID_Code
	) a
	where indx <=3

--select 
--filename,
--max(paid_date)
--from dbo.WW_Claims
--Group by filename
--order by Filename

--select 
--filename,
--max(insert_date)
--from dbo.WW_AccountActivity
--Group by filename
--order by Filename



