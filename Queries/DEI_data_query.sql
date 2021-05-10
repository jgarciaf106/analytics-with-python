-- get HP_WORKER_DATA max date
Declare @EndDate Date

Select 	
    @EndDate = Max([Report Date]) 
From
 	HP_WORKER_DATA
Where 
	[Worker Reg / Temp Code] = N'R'
And 
	[Worker Status Category Code] = N'A'

-- get rolling date max date
Declare @RollingDate Date
Select @RollingDate = EomOnth(@EndDate, -11)

-- get WP15_DEI max date
Declare @VetDate Date
Select @VetDate = Max([Report Date]) From WFP15_VET_VIEW

-- fiscal year start date
Declare @FYStart Date = '2020-10-31'

-- regular active workers
Select 
	HWD.[Report Date],
	Case
		When HWD.[Business Lvl 2 (Unit) Code] = 'PIN' Then 'HPIB'
		Else Isnull(f1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code])
	End As [Hybrid L1],
	Isnull(F2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]) As [Hybrid L2],
	Case
		When TT.[Job Family Code] Is Null Then 'No'
	Else 'Yes'
	End As [Technical Job Family],

	Case 
		When VET.[Employee ID] Is Null Then 'U'
		Else VET.[Veteran Status]
	End As [Veteran Status],

	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Work Address - Country]
		Else 'Other'
	End As [Pay Group Country Desc],
	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Ethnicity Group]
		Else 'Other'
	End As [Ethnicity Group],
	Isnull(HWD.[GEnder Code], N'U') As [Gender Code],
	Case
		When HWD.[Management Level Category] <> N'NOnE' Then 'Yes'
		Else 'No'
	End As [Is ProfessiOnal],
	Case
		When HWD.[Original Hire Date] > @FYStart or HWD.[Hire Date] > @FYStart Then 'Yes'
		Else 'No'
	End As [Is New Hire],
	HWD.[Management Level Category],
	Count(1) As [HC],
	0 As [Voluntary Attrits]
From 
	HP_WORKER_DATA As HWD
	Left Join FEDL1 As F1 On F1.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
	Left Join FEDL2 As F2 On F2.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
	Left Join TECH_JOBS_FAM As TT On TT.[Job Family Code] = HWD.[Job Family Code]
	Left Join WFP15_VET_VIEW As VET On VET.[Employee ID] = HWD.[Worker ID] And VET.[Report Date] = @VetDate
Where 
	HWD.[Report Date] >= @RollingDate And 
	HWD.[Worker Reg / Temp Code] = N'R' And 
	HWD.[Worker Status Category Code] = N'A' And
	HWD.[Business Lvl 4 (MRU) Code] <> 'G034' And
	Not (HWD.[Business Lvl 1 (Group) Code] = 'OPER' And HWD.[Work Address - City] = 'Pantnagar')
Group By 
	HWD.[Report Date],
	Case
		When HWD.[Business Lvl 2 (Unit) Code] = 'PIN' Then 'HPIB'
		Else isnull(F1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code])
	End,
	Isnull(F2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]),
	Case 
		When VET.[Employee ID] Is Null Then 'U'
		Else VET.[Veteran Status]
	End,
	Case
		When TT.[Job Family Code] Is Null Then 'No'
	Else 'Yes'
	End,
	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Work Address - Country]
		Else 'Other'
	End,
	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Ethnicity Group]
		Else 'Other'
	End,
	Isnull(HWD.[Gender Code], N'U'),
	Case
		When HWD.[Management Level Category] <> N'NOnE' Then 'Yes'
		Else 'No'
	End,
	Case
		When HWD.[Original Hire Date] > @FYStart Or HWD.[Hire Date] > @FYStart Then 'Yes'
		Else 'No'
	End,
	HWD.[Management Level Category]

Union All

-- AttritiOn

Select 
	EomOnth(dateadd(d, 1, HWD.[Termination Date]), 0) As [Report Date],
	Case
		When HWD.[Business Lvl 2 (Unit) Code] = 'PIN' Then 'HPIB'
		Else isnull(F1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code])
	End As [Hybrid L1],
	isnull(F2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]) [Hybrid L2],
	Case
		When TT.[Job Family Code] Is Null Then 'No'
	Else 'Yes'
	End As [Technical Job Family],

	Case 
		When  VET.[Employee ID] Is Null Then 'U'
		Else VET.[Veteran Status]
	End As [Veteran Status],

	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Work Address - Country]
		Else 'Other'
	End As [Pay Group Country Desc],
	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Ethnicity Group]
		Else 'Other'
	End As [Ethnicity Group],
	Isnull(HWD.[Gender Code], N'U') As [Gender Code],
	Case
		When HWD.[Management Level Category] <> N'NOnE' Then 'Yes'
		Else 'No'
	End As [Is ProfessiOnal],
	Case
		When HWD.[Original Hire Date] > @FYStart Or HWD.[Hire Date] > @FYStart Then 'Yes'
		Else 'No'
	End As [Is New Hire],
	HWD.[Management Level Category],
	0 As [HC],
	Count(1) As [Voluntary Attrits]
From 
	HP_WORKER_DATA As HWD
	Inner Join HP_ATTRITION As TD On TD.[Report Date] = HWD.[Report Date] And HWD.[Worker ID] = TD.[Worker ID]	And HWD.[AttritiOn Type] = 'Voluntary'
	Left Join FEDL1 F1 On F1.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
	Left Join FEDL2 F2 On F2.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
	Left Join TECH_JOBS_FAM As TT On TT.[Job Family Code] = HWD.[Job Family Code]
	Left Join WFP15_VET_VIEW As  VET On VET.[Employee ID] = HWD.[Worker ID] And	VET.[Report Date] = @VetDate
Where 
	EomOnth(dateadd(d, 1, HWD.[TerminatiOn Date]), 0) >= @RollingDate And
	HWD.[Business Lvl 4 (MRU) Code] <> 'G034' And
	NOT (HWD.[Business Lvl 1 (Group) Code] = 'OPER' And HWD.[Work Address - City] = 'Pantnagar')
Group By 
	Eomonth(dateadd(d, 1, HWD.[Termination Date]), 0),
	Case
		When HWD.[Business Lvl 2 (Unit) Code] = 'PIN' Then 'HPIB'
		Else Isnull(f1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code])
	End,
	Isnull(F2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]),
	Case 
		When VET.[Employee ID] Is Null Then 'U'
		Else VET.[Veteran Status]
	End,
	Case
		When TT.[Job Family Code] Is Null Then 'No'
	Else 'Yes'
	End,
	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Work Address - Country]
		Else 'Other'
	End,
	Case
		When HWD.[Work Address - Country Code] = N'USA' Then HWD.[Ethnicity Group]
		Else 'Other'
	End,
	Isnull(HWD.[GEnder Code], N'U'),
	Case
		When HWD.[Management Level Category] <> N'NONE' Then 'Yes'
		Else 'No'
	End,
	Case
		When HWD.[Original Hire Date] > @FYStart or HWD.[Hire Date] > @FYStart Then 'Yes'
		Else 'No'
	End,
	HWD.[Management Level Category]