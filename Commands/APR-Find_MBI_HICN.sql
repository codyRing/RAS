use RAS_APR_Reconciliation
Declare @coverageStartdate date = '1/1/19'
Declare @sentlimit date = '1/1/19'
Declare @coverageenddate date = '10/1/2019'

Declare @CarrierType table(
Carrier nvarchar(50),
product_Type nvarchar(50))



Truncate table DBO.research_id
insert into dbo.Research_ID(Identifier,Identifier_Two,CarrierID,FirstName,LastName,Date_Of_Birth,Address)

Select distinct
 Identifier,Identifier_Two,carrierid,FirstName,LastName,Date_Of_Birth,Address 
	from dbo.Carrier_humana Carrier
			left join dbo.APR_Sent x
				on Carrier.CarrierID = x.Carrier_Member_id
					
			left join dbo.APR_Not_Sent y
				on Carrier.CarrierID = y.Carrier_Member_id

			left join dbo.RAS_MemberPremiumPayments r
				on 
				carrier.CarrierID = r.Carrier_Member_id and
				carrier.CoverageStart = r.Coverage_Start_date and
				round(carrier.amount,0,1) = round(r.amount,0,1)
			where 
				CoverageStart >= @coverageStartdate and
				carrier.Amount >1 


			--and r.input_status like 'person not found'
			and r.Payment_ID is null
	       -- and (x.Carrier_Member_id is not null and y.carrier_member_id is  null) ----Members getting paid monthly
			--and (x.Carrier_Member_id is  null and y.carrier_member_id is  null) ----Never been mapped or Person not found
			--and (x.Carrier_Member_id is  null and y.carrier_member_id is not null) --None No Opt In, Person Not Found. All of these could potentially be mapped

-------------Delete records you already have mappings for
Delete R 
from dbo.Research_ID R
	join RAS_MBI.dbo.crosswalk c
		on R.Identifier = c.MBI
				--where HICN is not null

-----------Delete non MBI identifiers
delete from dbo.Research_ID
			where 
				(
				case 
					when 
						len(Identifier)>= 11 and 
						SUBSTRING(identifier,1,1) like '[0-9]' and 
						SUBSTRING(identifier,5,1) like '[a-zA-Z]'
						then 'mbi'
					else null
				end
				) is null
--				--(
--				--case 
--				--	when 
--				--		len(Identifier_two) = 10 and 
--				--		right(Identifier_two,1) like '[a-zA-Z]'
--				--		--SUBSTRING(identifier,1,1) like '[0-9]' and 
--				--		--SUBSTRING(Identifier_two,1,10) like '[a-zA-Z]'
--				--		then 'hicn'
--				--	else null
--				--end
--				--) is null


Select * from dbo.Research_ID

select 
Row_number() over(partition by r.identifier order by r.lastname) as indx,
r.Identifier,
r.Identifier_Two,r.CarrierID,
m.SSN,m.AID,
--m.Employer,
m.Date_Of_Birth as RAS_DOB,
r.Date_Of_Birth as carrier_dob,
--aid,
--ssn,
First_Name,
Last_Name,
Address_1 as RAS_address,r.Address as carrier_addres,
State,
zip,
Concat('add-MbiMapping -MBI ',r.identifier,' -SSN ',m.ssn,' -HICN ',m.ssn,'A')
--Concat('Add-MbiMapping -MBI ',r.identifier,' -SSN ',m.ssn)

--r.Identifier,m.ssn,r.identifier_two

from dbo.MMAMembers m
	join dbo.Research_ID r
		on 
		m.First_Name = r.firstname and
		m.Last_Name = r.lastname 
		--and m.Date_Of_Birth = r.Date_Of_Birth 
		--and m.SSN = left(r.Identifier_Two,9)
where m.Employer not  in ('Xerox','Obsolete - DTE','ConAgra')
order by r.CarrierID


--Select * from dbo.MMAMembers 
--where SSN like '255946537'

--select * from dbo.Research_ID

--select 
--c.mbi,
--c.ssn,
--c.hicn,
--Concat('set-MbiMapping -MBI ',C.MBI,' -SSN ',C.ssn,' -HICN ',C.ssn,'A') 
--from ras_mbi.dbo.Crosswalk c
--where mbi like '1EA2JH9EE01'

--select c.*
--from ras_mbi.dbo.Crosswalk c
--	join dbo.research_id r
--		on c.mbi = r.identifier
