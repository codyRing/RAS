Declare @id nvarchar(50) = '156710'
Declare @user table
			(
			Employer nvarchar(50),
			First_name nvarchar(50),
			last_name nvarchar(50),
			AID nvarchar(50),
			Date_Of_Birth Date,
			ssn nvarchar(50),
			holderssn nvarchar(50),
			pin nvarchar(50),
			relation_code nvarchar(50),
			eligible nvarchar(50),
			Subsidy nvarchar(50),
			subsidy_Date date						
			)

Insert into @user

Select 
Employer,First_Name,Last_Name,aid,Date_Of_Birth,SSN,u.Holderssn,pin,RELATION_CODE,Eligible,EmployerSubsidyContrib,SubsidyStartDate
	from dbo.MMAMembers u
		Join (
				select distinct holderssn
				from dbo.MMAMembers
				where (
				Last_name Like @id or
				ssn	Like @id or
				Holderssn Like @id or
				aid Like @id or
				pin Like @id )
			) u_two
		on u.holderssn = u_two.holderssn
		

--select
--'BW_Enrollment' as 'source',
--Row_number() over(partition by e.aid order by file_Creation_Date desc)as indx,
--u.aid,u.First_name,u.last_name,u.holderssn,e.File_Creation_Date,
--e.ssn,
--e.last_name,
--e.First_Name,
--e.Trans_Eff_Date,
--e.Policy_Amount,
--e.Xerox_Disposition,
--e.BenefitWallet_Disposition
--from dbo.BW_Enrollments e
--	 join @user u
--		on e.aid =u.aid
--where u.relation_code like 'self'


Select
'BW_Funding' as 'source',
Row_number () over( partition by f.aid order by pay_date desc) as indx,
f.aid,
f.Account_SSN,
f.Last_Name,
f.First_Name,
f.Funding_AID,
f.Funding_Amount,
f.Pay_Date,
CONVERT(VARCHAR(7), f.Pay_Date, 120) AS 'Pay_Month',
f.Record_Loaded_On,
f.Xerox_Disposition,
f.BenefitWallet_Disposition,
f.Filename,
f.Batch_Id
From dbo.bw_funding f
	join @user u	
		--on f.Aid = u.aid
		on f.Funding_AID = u.AID	
where BenefitWallet_Disposition  like 'none'






--select
--'WW_Enrollment' as 'source',
--Row_number() over(partition by e.aid order by file_Creation_Date desc)as indx,
--e.aid,
--e.ssn,
--e.last_name,
--e.First_Name,
--e.CoverageEffectiveDate,
--e.Policy_Amount,
--e.Xerox_Disposition,
--e.WageWorks_Disposition,
--e.Plan_Code
--from dbo.WW_Enrollments e
--	join @user u
--		on 
--		e.aid =u.aid or
--		e.pin = u.pin





Select
'WW_Funding' as 'source',
Row_number () over( partition by f.pin,f.funding_aid order by pay_date desc),
f.pin,
f.Account_SSN,
f.Last_Name,
f.First_Name,
f.Funding_AID,
f.Funding_Amount,
f.Pay_Date,
 CONVERT(VARCHAR(7), f.Pay_Date, 120) as pay_month,
f.Xerox_Disposition,
f.Wageworks_Disposition,
File_Creation_Date
From dbo.Ww_funding f
	join @user u	
		on f.pin = u.pin


Select * from @user