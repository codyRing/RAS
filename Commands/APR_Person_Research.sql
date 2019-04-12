use RAS_APR_Reconciliation


Declare @hssn table(HSSN nvarchar(50))

insert into @hssn
			select distinct Holderssn 
			from dbo.MMAMembers
			where aid IN ('202059')
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



-------------------------------------------------------
SELECT
	INDX 
	--Row_number () over(partition by u.holderssn order by carrier)
	--,u.holderssn
	,[Carrier]
	,[Product_type]
	,p.[First_Name] ,p.[Last_Name]
	--,p.Covered_First_name,p.Covered_Last_name
	--,[Holder_AID]
	--,[Covered_HICN] 
	--,[HICN]
	,[Carrier_Member_id]
	,Amount
	,cast(DATEADD(month, DATEDIFF(month, 0, [Coverage_Start_date]), 0) as date) as coverage_start_Date
	,Coverage_End_date
	--,DATEDIFF(d,[Coverage_Start_date],[File_date]) as pay_lag
	,[Payment_ID]
	
	,[Input_status]
	,[Data_status]	
	,Reimbursement_status	
	,Last_Processed_date
	,[File_date]
FROM	(
		select 
		Row_Number() over(partition by carrier,carrier_member_id,product_Type order by coverage_Start_Date desc) AS INDX
		--Row_Number() over(partition by carrier,product_type order by coverage_Start_Date desc) AS INDX
		,x.*
		from dbo.RAS_MemberPremiumPayments x
			JOIN	@user u
					on x.Last_Name = u.Last_Name and
					x.First_Name = u.First_name
			
where
	Coverage_Start_date  >= '1/1/2018' 
		) P
		where
			p.INDX <= 4





Select * from @user