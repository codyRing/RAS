Declare @limit_date date = '1/1/2019'
Declare @id  nvarchar(50) =  '41540'  ---173691 174160
--exec add_Crosswalk @ID

--update a
--set LastName = 'MASTERS COLL'
--from dbo.Crosswalk a
--where aid like @id
--and mbi is null

--select * from dbo.mapping('6MP7W68WE33')
Declare @recent int = 3
Declare @hssn nvarchar(50) = (
								Select distinct HSSN from dbo.Crosswalk w
								where (
								w.mbi Like @id or
								w.ssn like @id or
								w.hicn	Like @id or
								w.aid Like @id or
								w.pin Like @id or
								w.LastName like @id
								)
							)
Declare @u table(
					mbi nvarchar(50),
					ssn nvarchar(50),
					hicn nvarchar(50),
					aid nvarchar(50),
					pin nvarchar(50),
					firstname nvarchar(50),	
					lastName nvarchar(50),	
					DOB date,	
					age int,	
					address nvarchar(50),	
					zip nvarchar(50),
					employer nvarchar(50)
				)

insert into @u
Select 
mbi,ssn,hicn,aid,pin,FirstName,LastName,dob,
DATEDIFF(YY, dob, getdate()) - CASE WHEN( (MONTH(dob)*100 + DAY(dob)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age,
address,
zip,
Employer
from dbo.Crosswalk
where HSSN like @hssn


Select
r.INDX
,r.firstname
,r.LastName
,r.Carrier
,r.ras_product_type
,r.CarrierID
,r.input_status
,r.data_status
,r.reimbursement_Status

,r.CoverageStart
,r.CoverageEnd
,r.Amount
,r.Last_Processed_date
,r.Filename
,r.Record_ID
from(
		select 
			Row_Number() over(partition by apr.carrier,apr.carrierid,a.product_type order by coveragestart desc) AS INDX,
			 apr.*,a.Input_status,a.Data_status,a.Reimbursement_status,a.Last_Processed_date,a.Product_type as ras_product_type
				from dbo.carrier_apr APR
					JOIN @u u on 
						u.firstname = apr.FirstName and
						u.lastName = apr.LastName

						--u.mbi = apr.Identifier

					left join dbo.RAS_APR a
						on apr.Record_ID = a.Record_ID
			where 
			APR.CoverageStart >= @limit_date
			and apr.Amount >0
	) r
where r.INDX < = @recent
--and CarrierID not in ('A00409251','H57282443','A00636838')




Select * from (

Select 
row_Number() over (partition by r.carrier_member_id,r.product_Type order by r.coverage_Start_Date desc) as indx,
r.First_Name,r.Last_Name,r.Carrier_Member_id,r.Carrier,r.Product_type,r.Coverage_Start_date,r.Amount,r.Input_status,r.Data_status,r.Reimbursement_status
from dbo.RAS_APR_Stage r
	join @u u on
		r.First_Name = u.firstname and
		r.Last_Name = u.lastName
		) x
		where indx <= @recent
		--and Product_type like 'vision'





Select * from @u






