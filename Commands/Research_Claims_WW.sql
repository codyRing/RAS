use [RAS_APR_Reconciliation]
declare @last nvarchar(50) = 'luxa%'
declare @first nvarchar(50) = 'donald'
declare @ID_Code nvarchar(50) =  ''
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
--and amount = '37.50'
--and Service_Start_Date = '1/1/2019'
--and Claim_Id not in (
--'91921694', '91533894', '90686952', '89797698', '88203283')
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

--Delete from dbo.WW_AccountActivity where isnull(id_code,'') like ''




--select paid_date, count(*) from dbo.WW_Claims
--group by Paid_Date
--order by paid_Date desc

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

--Select * from dbo.WW_AccountActivity
--where filename like 'SR_Nuclear.csv'
--and cast(Insert_date as date) = '2019-03-14'
--and PPT_EE_ID like '227771'

--		Select 
--		Row_Number() over (partition by filename,id_Code,last_name order by insert_Date desc) as indx,
--		*
--		From dbo.WW_AccountActivity
--		where PPT_EE_ID like '227771'
		
		
--		 Last_Name like 'Doyong' 
--		and First_Name like 'Kim') 