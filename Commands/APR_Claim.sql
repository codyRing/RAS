use RAS_APR_Reconciliation
Declare @hssn table(HSSN nvarchar(50))

insert into @hssn
			select distinct Holderssn 
			from dbo.MMAMembers
--------------Add Criteria to search Users------------------------			
			where aid like ''			
Declare @user table
			(
			sort int,
			Employer nvarchar(50),
			AID nvarchar(50),
			First_name nvarchar(50),
			last_name nvarchar(50),
			pin nvarchar(50),
			relation_code nvarchar(50),
			ssn nvarchar(50),
			holderssn nvarchar(50),
			Zip nvarchar (50),
			Date_Of_Birth nvarchar (50),
			age nvarchar (50),
			SubsidyStartDate date,
			SubsidyEndDate date,
			EmployerSubsidyContrib nvarchar(50),
			Employer_Subsidy_Contribution_1 nvarchar(50), 
			Employer_Subsidy_Contribution_2 nvarchar(50), 
			Employer_Subsidy_Contribution_3 nvarchar(50),
			filename nvarchar(100)
			)

		insert into @user
		select 
		Row_number() over(partition by holderssn order by Relation_Code) as sort,
		employer,aid,First_Name,Last_Name,PIN,Relation_Code,ssn,holderssn,Zip,Date_Of_Birth,
		DATEDIFF(YY, Date_Of_Birth, getdate()) - CASE WHEN( (MONTH(Date_Of_Birth)*100 + DAY(Date_Of_Birth)) > (MONTH(getdate())*100 + DAY(getdate())) ) THEN 1 ELSE 0 END as age,
		SubsidyStartDate,SubsidyEndDate,
		EmployerSubsidyContrib,Employer_Subsidy_Contribution_1,Employer_Subsidy_Contribution_2,Employer_Subsidy_Contribution_3,	
		filename
		from dbo.MMAMembers m
			join @hssn h
				on m.Holderssn= h.HSSN


Select
Row_Number() over(partition by carrier,carrier_member_id,product_type order by coverage_Start_Date desc) AS INDX,
claim.Patient_FirstName,
claim.Patient_LastName,
apr.Carrier_Member_id,
apr.Carrier,
apr.Product_type,
apr.Coverage_Start_date,
apr.Amount,
apr.Reimbursement_status,
apr.file_date,
claim.Claim_Id,
claim.Paid_Date

FROM	(
		select 
		--Row_Number() over(partition by carrier,carrier_member_id,product_type order by coverage_Start_Date desc) AS INDX
		--Row_Number() over(partition by carrier,product_type order by coverage_Start_Date desc) AS INDX
		a.Carrier,a.Product_type,a.Coverage_Start_date,a.Amount,a.Payment_ID,a.File_date,a.Reimbursement_status,a.Carrier_Member_id
		,a.Covered_First_name
		,a.Covered_Last_name
		,u.holderssn
		,u.pin
		,u.AID
		from dbo.RAS_APR_Records a
			JOIN	@user u on
					A.Last_Name = u.Last_Name and
					A.First_Name = u.First_Name
		where 
		Reimbursement_status in ('sent','pending','none')
		and Coverage_Start_date >= '1/1/2019'
		) apr

	
	Left Join
		(
		Select
		--row_number() over ( partition by ID_Code order by service_start_Date desc,claim desc) as indx
		--row_number() over ( partition by ID_Code order by paid_date desc) as indx
		c.Claim_Id,c.Amount,c.claim,c.Service_Start_Date,c.Paid_Date,c.Patient_FirstName,c.Patient_LastName
		,u.holderssn
		,u.pin
		,u.AID
		FROM [dbo].[WW_Claims] C
			Join @user u on
			c.Patient_LastName = u.last_name and
			c.Patient_FirstName = u.First_name
			) claim
			on
			---------Sub/spouse join?----------------
			--apr.holderssn = claim.holderssn and
			claim.Patient_FirstName = apr.Covered_First_name and
			claim.Patient_LastName = apr.Covered_Last_name and
			apr.Coverage_Start_date = claim.Service_Start_Date and
			apr.Amount = claim.claim


--Select * from @user
	

