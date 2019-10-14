Declare @id nvarchar(50) = '' 
Declare @limit_date date = '1/1/2019'
declare @rank int = 4

Declare @who table
			(
			Employer nvarchar(50),
			First_name nvarchar(50),
			last_name nvarchar(50),
			AID nvarchar(50),
			pin nvarchar(50),
			ssn nvarchar(50),
			holderssn nvarchar(50),
			Date_Of_Birth Date,
			age nvarchar (50),
			relation_code nvarchar(50),
			zip nvarchar(50),
			address_1 nvarchar(50)	
			)

Insert into @who

Select
	employer, 
	First_Name, 
	Last_Name, 
	aid, 
	pin, 
	ssn, 
	m.Holderssn, 
	Date_Of_Birth, 
	DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age, 
	RELATION_CODE, 
	zip, 
	Address_1
	from dbo.MMAMembers m
		Join (
				select distinct holderssn
				from dbo.MMAMembers
				where (
				Last_name Like @id or
				ssn	Like @id or
				Holderssn Like @id or
				aid Like @id or
				pin Like @id )
			) m_two
		on m.holderssn = m_two.holderssn

Select
r.INDX
,r.[First_Name] 
,r.[Last_Name]
,r.[Carrier]
,r.[Product_type]
,r.Carrier_Member_id
,R.Input_status
,r.Data_status
,r.Reimbursement_status
,r.Coverage_Start_date,r.Coverage_End_date
,r.amount
--,round(r.amount,0,1)
,r.File_date
,r.Last_Processed_date

From(

	select 
	Row_Number() over(partition by apr.carrier,apr.carrier_member_id,apr.product_type order by coverage_Start_Date desc) AS INDX,
	 apr.*
		from dbo.RAS_MemberPremiumPayments APR
			JOIN @who w on 
				w.Last_Name = APR.Last_Name and
				w.First_Name = apr.First_name
		where 
			Coverage_Start_date >= @limit_date		
			--and apr.Carrier_member_id not in('')
			--and apr.Product_type in ('')
			--and apr.Carrier like '%%'
			--and apr.Reimbursement_status in ('sent','pending')
		
	) R

where r.INDX <= @rank

Select * from @who