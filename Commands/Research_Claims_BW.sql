-----Benefit Wallet--------------------------------
use [RAS_APR_Reconciliation]
Declare @importdate date = '2018-01-01'
Declare @name nvarchar(50) = '%SCHEIDERER%'
select 
row_number() over(partition by provider order by participantname,  servicedate desc, claimamount desc) as indx
,ParticipantName
,ServiceDate
,DATEDIFF(d,servicedate,importdate) as pay_lag
,Provider
,ExternalClaimNumber
,ClaimAmount
,ClaimNumberOrReason
,ImportDate
,ImportFilename
from [dbo].[BW_Claims]
where ImportDate >= @importdate
and ServiceDate >= '3/1/2019'
and ParticipantName like @name
--and ClaimAmount = '19.60'
--and Provider like '%dental%'



 --select 
 --importfilename,
 --importdate,
 --SuccessCount,
 --FailureCount,
 --TotalCount,
 --count(*)
 --from dbo.[BW_Claims]
 --Group by	importfilename,importdate,
	--		 SuccessCount,FailureCount,
	--		 TotalCount
 --order by importdate desc


-----------------------------------------------------------------------------