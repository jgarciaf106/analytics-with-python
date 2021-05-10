Set Nocount On

-- Rolling Dates Calc

Declare @EndDate As Date

Select 
	@EndDate = Max([Report Date]) 
From 
	HP_WOrKER_DATA
Where 
	[WOrker Reg / Temp Code] = N'R' 
And 
	[WOrker Status CategOry Code] = N'A'

Declare @RollingDate As Date

Select @RollingDate = EomOnth(@EndDate, -11)

-- Variable Declare fOr Vet's Last Date

Declare @VetDate As Date

Select @VetDate = Max([Report Date]) From WFP15_VET_VIEW

Declare @PWDDate As Date

Select @PWDDate = Max([Report Date]) From WFP15_PWD_VIEW


Declare @FYStart As Date = '2020-10-31'


Select	
	HWD.[Report Date],
	Isnull(f1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code]) As [Hybrid L1],
	Isnull(f2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]) As [Hybrid L2],
	Case
		When HWD.[Work Address - City] = N'Pantnagar' Then HWD.[Work Address - City]
		When HWD.[Work Address - City] = N'Boise' Then HWD.[Work Address - City]
		When HWD.[Work Address - City] = N'Vancouver' Then HWD.[Work Address - City]
		Else 'Other'
	End As [Work Address - City],
	Case
		When TT.[Job Family Code] Is Null Then 'No'
	Else 'Yes'
	End As [Technical Job Family],

-- China FactOry IndicatOr MRU G034	
	
	Case
		When HWD.[Business Lvl 4 (MRU) Code] = N'G034' Then HWD.[Business Lvl 4 (MRU) Code]
		Else 'Other'
	End As [Business Lvl 4 (MRU) Code],

-- Bring the Vets

	Case 
		When VET.[Employee ID] Is Null Then 'U'
		Else VET.[Veteran Status]
	End As [Veteran Status],
	Case 
		When HWD.[Pay Group Country Desc] In ('Austria','Belgium','Bulgaria','Croatia','Czechia','Denmark','FinlAnd','Greece','Hungary','IrelAnd','Israel','Kazakhstan','Luxembourg','MOrocco','NetherlAnds','Nigeria','NOrway','PolAnd','POrtugal','Russian FederatiOn','Saudi Arabia','Serbia','Slovakia','South Africa','Sweden','Tunisia','Turkey','United Arab Emirates') Then 'U'
		When PWD.[Employee ID] Is Null Then 'N'
		Else PWD.[PWD]
	End As [PWD Status],

	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Pay Group Country Desc]
		Else 'Other'
	End As [Pay Group Country Desc],
	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Ethnicity Group]
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
	count(1) As [HC],
	0 As [Voluntary Attrits]
From 
	HP_WORKER_DATA As HWD
	Left Join FEDL1 F1 On F1.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
	Left Join FEDL2 F2 On F2.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
	Left Join TECH_JOBS_FAM As TT On TT.[Job Family Code] = HWD.[Job Family Code]
	Left Join WFP15_VET_VIEW As VET On VET.[Employee ID] = HWD.[WOrker ID] And VET.[Report Date] = @VetDate
	Left Join WFP15_PWD_VIEW AS PWD On PWD.[Employee ID] = HWD.[WOrker ID] And PWD.[Report Date] = @PWDDate
Where 
	HWD.[Report Date] >= @RollingDate And 
	[Worker Reg / Temp Code] = N'R' And 
	[Worker Status CategOry Code] = N'A'  And
	HWD.[Business Lvl 4 (MRU) Code] <> 'G034' And
	NOT (HWD.[Business Lvl 1 (Group) Code] = 'OPER' And HWD.[WOrk Address - City] = 'Pantnagar')
Group By
	HWD.[Report Date],
	Isnull(F1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code]),
	Isnull(F2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]),
	Case
		When HWD.[Work Address - City] = N'Pantnagar' Then HWD.[Work Address - City]
		When HWD.[Work Address - City] = N'Boise' Then HWD.[Work Address - City]
		When HWD.[Work Address - City] = N'Vancouver' Then HWD.[Work Address - City]
		Else 'Other'
	End,

	-- Group the Vets

	Case 
		When VET.[Employee ID] Is Null Then 'U'
		Else VET.[Veteran Status]
	End,
	Case 
		When HWD.[Pay Group Country Desc] In ('Austria','Belgium','Bulgaria','Croatia','Czechia','Denmark','FinlAnd','Greece','Hungary','IrelAnd','Israel','Kazakhstan','Luxembourg','MOrocco','NetherlAnds','Nigeria','NOrway','PolAnd','POrtugal','Russian FederatiOn','Saudi Arabia','Serbia','Slovakia','South Africa','Sweden','Tunisia','Turkey','United Arab Emirates') Then 'U'
		When PWD.[Employee ID] Is null Then 'N'
		Else PWD.[PWD]
	End,
	Case
		When TT.[Job Family Code] Is Null Then 'No'
	Else 'Yes'
	End,
	HWD.[Business Lvl 4 (MRU) Code],
	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Pay Group Country Desc]
		Else 'Other'
	End,
	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Ethnicity Group]
		Else 'Other'
	End,
	isnull(HWD.[Gender Code], N'U'),
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
	Eomonth(dateadd(d, 1, HWD.[TerminatiOn Date]), 0) As [Report Date],
	Isnull(F1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code]) As [Hybrid L1],
	Isnull(F2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]) As [Hybrid L2],
	Case
		When HWD.[WOrk Address - City] = N'Pantnagar' Then HWD.[WOrk Address - City]
		Else 'Other'
	End As [Work Address - City],
	Case
		When TT.[Job Family Code] is null Then 'No'
	Else 'Yes'
	End As [Technical Job Family],

	-- China FactOry IndicatOr MRU G034	
	
	Case
		When HWD.[Business Lvl 4 (MRU) Code] = N'G034'Then HWD.[Business Lvl 4 (MRU) Code]
		Else 'Other'
	End AS [Business Lvl 4 (MRU) Code],

-- Bring the Vets

	Case 
		When VET.[Employee ID] Is Null Then 'U'
		Else VET.[Veteran Status]
	End As [Veteran Status],
	Case 
		When HWD.[Pay Group Country Desc] in ('Austria','Belgium','Bulgaria','Croatia','Czechia','Denmark','FinlAnd','Greece','Hungary','IrelAnd','Israel','Kazakhstan','Luxembourg','MOrocco','NetherlAnds','Nigeria','NOrway','PolAnd','POrtugal','Russian FederatiOn','Saudi Arabia','Serbia','Slovakia','South Africa','Sweden','Tunisia','Turkey','United Arab Emirates') Then 'U'
		When PWD.[Employee ID] is null Then 'N'
		Else PWD.[PWD]
	End As [PWD Status],
	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Pay Group Country Desc]
		Else 'Other'
	End As [Pay Group Country Desc],
	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Ethnicity Group]
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
	count(1) AS [Voluntary Attrits]
From HP_WORKER_DATA As HWD

Inner Join HP_ATTRITION As TD On TD.[Report Date] = HWD.[Report Date]
	And TD.[WOrker ID] = HWD.[WOrker ID]
	And HWD.[AttritiOn Type] = 'Voluntary'
	
--Inner Join @HPI_Orgs hp On hp.[Business Lvl 1 (Group) Code] = wd.[Business Lvl 1 (Group) Code]

Left Join FEDL1 F1 On F1.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
Left Join FEDL2 F2 On F2.[Business Lvl 4 (MRU) Code] = HWD.[Business Lvl 4 (MRU) Code]
Left Join TECH_JOBS_FAM As TT On TT.[Job Family Code] = HWD.[Job Family Code]
--Left Join TechnicalJobs tj On tj.[Job Family] = wd.[Job Family]

-- Vets pulling
	Left Join WFP15_VET_VIEW As VET On VET.[Employee ID] = HWD.[WOrker ID] And
		VET.[Report Date] = @VetDate
	Left Join WFP15_PWD_VIEW As PWD On PWD.[Employee ID] = HWD.[WOrker ID] And
		PWD.[Report Date] = @PWDDate

Where 
	EomOnth(dateadd(d, 1, HWD.[TerminatiOn Date]), 0) >= @RollingDate  And
	HWD.[Business Lvl 4 (MRU) Code] <> 'G034' And
	NOT (HWD.[Business Lvl 1 (Group) Code] = 'OPER' And HWD.[Work Address - City] = 'Pantnagar')
Group by 
	EomOnth(dateadd(d, 1, HWD.[TerminatiOn Date]), 0),
	isnull(f1.[Business Lvl 1 (Group) Code], HWD.[Business Lvl 1 (Group) Code]),
	isnull(f2.[Business Lvl 2 (Unit) Code], HWD.[Business Lvl 2 (Unit) Code]),
	Case
		When HWD.[Business Lvl 4 (MRU) Code] = N'G034'Then HWD.[Business Lvl 4 (MRU) Code]
		Else 'Other'
	End,

	-- Group the Vets

	Case 
		When VET.[Employee ID] is null Then 'U'
		Else VET.[Veteran Status]
	End,
	Case 
		When HWD.[Pay Group Country Desc] in ('Austria','Belgium','Bulgaria','Croatia','Czechia','Denmark','FinlAnd','Greece','Hungary','IrelAnd','Israel','Kazakhstan','Luxembourg','MOrocco','NetherlAnds','Nigeria','NOrway','PolAnd','POrtugal','Russian FederatiOn','Saudi Arabia','Serbia','Slovakia','South Africa','Sweden','Tunisia','Turkey','United Arab Emirates') Then 'U'
		When PWD.[Employee ID] is null Then 'N'
		Else PWD.[PWD]
	End,
	Case
		When HWD.[WOrk Address - City] = N'Pantnagar' Then HWD.[WOrk Address - City]
		Else 'Other'
	End,
	Case
		When TT.[Job Family Code] is null Then 'No'
	Else 'Yes'
	End,
	HWD.[Business Lvl 4 (MRU) Code],
	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Pay Group Country Desc]
		Else 'Other'
	End,
	Case
		When HWD.[Pay Group Country Code] = N'USA' Then HWD.[Ethnicity Group]
		Else 'Other'
	End,
	isnull(HWD.[Gender Code], N'U'),
	Case
		When HWD.[Management Level Category] <> N'NOnE' Then 'Yes'
		Else 'No'
	End,
	Case
		When HWD.[Original Hire Date] > @FYStart Or HWD.[Hire Date] > @FYStart Then 'Yes'
		Else 'No'
	End,
	HWD.[Management Level Category]