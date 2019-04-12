Declare @hssn table(HSSN nvarchar(50))

insert into @hssn
			select distinct Holderssn 
			from dbo.MMAMembers
	where aid Like ''

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
	--where filename not like 'irregular%'

--Select * from @user


select
'BW_Enrollment' as 'source',
Row_number() over(partition by e.aid order by file_Creation_Date desc)as indx,
u.aid,u.First_name,u.last_name,u.holderssn,e.File_Creation_Date,
e.ssn,
e.last_name,
e.First_Name,
e.Trans_Eff_Date,
e.Policy_Amount,
e.Xerox_Disposition,
e.BenefitWallet_Disposition
from dbo.BW_Enrollments e
	 join @user u
		on e.aid =u.aid
where u.relation_code like 'self'


------select aid,sum(funding_amount) as funding from(
Select
'BW_Funding' as 'source',
Row_number () over( partition by f.aid order by pay_date desc) as indx,
f.aid,
f.Account_SSN,
f.Last_Name,
f.First_Name,
f.Funding_AID,
f.Funding_Amount,
f.Pay_Date,f.Record_Loaded_On,
f.Xerox_Disposition,
f.BenefitWallet_Disposition
From dbo.bw_funding f
	join @user u	
		on f.Aid = u.aid	
where BenefitWallet_Disposition  like 'none'
--) x
--group by aid



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





-- Select
-- 'WW_Funding' as 'source',
-- Row_number () over( partition by f.pin order by pay_date desc),
-- f.pin,
-- f.Account_SSN,
-- f.Last_Name,
-- f.First_Name,
-- f.Funding_AID,
-- f.Funding_Amount,
-- f.Pay_Date,
-- f.Xerox_Disposition,
-- f.Wageworks_Disposition
-- From dbo.Ww_funding f
	-- join @user u	
		-- on f.pin = u.pin

