USE [RAS_APR_Reconciliation]
GO

/****** Object:  Table [dbo].[Carrier_Aetna]    Script Date: 5/3/2019 1:49:09 PM ******/
DROP TABLE [dbo].[Carrier_Aetna]
GO

/****** Object:  Table [dbo].[Carrier_Aetna]    Script Date: 5/3/2019 1:49:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Carrier_UHC](
	[Identifier] [nvarchar](100) NULL,
	[Identifier_Two] [nvarchar](100) NULL,
	[FirstName] [nvarchar](max) NULL,
	[LastName] [nvarchar](max) NULL,
	[CarrierID] [nvarchar](100) NULL,
	[Address] [nvarchar](max) NULL,
	[Date_Of_Birth] [date] NULL,
	[CoverageStart] [date] NULL,
	[CoverageEnd] [date] NULL,
	[Amount] [decimal](18, 2) NULL,
	[PaymentID] [nvarchar](max) NULL,
	[RecordType] [nvarchar](max) NULL,
	[Product_Type] [nvarchar](100) NULL,
	[Filename] [nvarchar](max) NULL,
	[Text_One] [nvarchar](max) NULL,
	[Text_Two] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO



Truncate table dbo.research_id
insert into dbo.Research_ID(
CarrierID,
Identifier,
Identifier_Two,
FirstName,
LastName,
Address,
date_of_Birth)

Select 
distinct
carrier.CarrierID,
carrier.Identifier,
carrier.Identifier_Two,
carrier.FirstName,
carrier.LastName,
carrier.Address,
carrier.date_of_Birth
From dbo.Carrier_Aetna carrier
	left join dbo.RAS_MemberPremiumPayments r
		on carrier.CarrierID = r.Carrier_Member_id
			where r.Carrier_Member_id is null
			
			
			


--SQL start of month
--DATEADD(month, DATEDIFF(month, 0, coverage_start_date), 0

--20190401
--[date] NULL,
--Unicode string [DT_WSTR] have to import as text then convert in data flow with fast parse true

--05012019
--Unicode string [DT_WSTR] have to import as text and used derived column to parse and replace
-- (DT_DBDATE)(SUBSTRING([BIRTH-DATE],1,2) + "-" + SUBSTRING([BIRTH-DATE],3,2) + "-" + SUBSTRING([BIRTH-DATE],5,4))
-- TRIM(SUBSCRIBER)




--17.2
--[decimal](18, 2) NULL,
--decimal [DT_DECIMAL]

--FINDSTRING( @[User::Filename] , @[User::LoadFile] ,1) > 0

--Derived Column
--TRIM(SUBSCRIBER)