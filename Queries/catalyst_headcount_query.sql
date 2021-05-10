Declare @maxDate Date 

Select @maxDate = Max([Report Date]) From HP_WORKER_DATA

-- Cohort headcount Group By Lvl1
Select
	CAT.Cohort,
    HWD1.[Business Lvl 1 (Group) Code] As [Business Lvl 1],
	Count(1) As HC
From
	PD_CATALYST As CAT
	Left Join HP_WORKER_DATA As HWD1 On HWD1.[Worker ID] = CAT.[Employee ID] And HWD1.[Report Date] = CAT.[Cohort Date]
	Left Join HP_WORKER_DATA As HWD2 On HWD2.[Worker ID] = CAT.[Employee ID] And HWD2.[Report Date] = @maxDate
Where
	Case
		When HWD2.[Worker ID] Is Null Then 'T'
		Else HWD2.[Worker Status Category Code]
	End <> 'T' 
	And
	HWD2.[Worker Reg / Temp Code] = 'R' And	CAT.Cohort <> '1 (Feb 2019)'
    
Group By
	CAT.Cohort,
	HWD1.[Business Lvl 1 (Group) Code]

-- Catalyst headcount Group By Lvl1
Union All

Select
	'Catalyst' As Cohort,
	HWD1.[Business Lvl 1 (Group) Code] As [Business Lvl 1],
	Count(1) As HC
From

	PD_CATALYST As CAT
	Left Join HP_WORKER_DATA As HWD1 On HWD1.[Worker ID] = CAT.[Employee ID] And HWD1.[Report Date] = CAT.[Cohort Date]
	Left Join HP_WORKER_DATA As HWD2 On HWD2.[Worker ID] = CAT.[Employee ID] And HWD2.[Report Date] = @maxDate
Where
	Case
		When HWD2.[Worker ID] Is Null Then 'T'
		Else HWD2.[Worker Status Category Code]
	End <> 'T' And
	HWD2.[Worker Reg / Temp Code] = 'R' And
	CAT.Cohort <> '1 (Feb 2019)'

Group By
	HWD1.[Business Lvl 1 (Group) Code]

-- HPI MGR+ Headcount Group by Lvl1
union all

Select	
    'HPI MGR+' [Cohort],
	HWD1.[Business Lvl 1 (Group) Code] As [Business Lvl 1],
	count(1) [HC]
From 
	PD_CATALYST As CAT
Left Join 
	HP_WORKER_DATA As HWD1 On HWD1.[Worker ID] = CAT.[Employee ID] And HWD1.[Report Date] = CAT.[Cohort Date]
Left Join 
	HP_WORKER_DATA As HWD2 On HWD2.[Worker ID] = CAT.[Employee ID] And HWD2.[Report Date] = @maxDate

Where
Case
	When HWD2.[Worker ID] Is Null Then 'T'
	Else HWD2.[Worker Status Category Code]
End <> 'T' And
HWD2.[Worker Reg / Temp Code] = 'R' 
And
	CAT.Cohort <> '1 (Feb 2019)'
And
	HWD2.[Report Date] = @maxDate
And 
	HWD2.[Worker Reg / Temp Code] = N'R' 
And 
	HWD2.[Worker Status Category Code] = N'A' 
And
	HWD2.[Business Lvl 4 (MRU) Code] <> 'G034' 
And
	HWD2.[Management Level Category] not in ('NONE','PROF')

Group By 
	HWD1.[Business Lvl 1 (Group) Code]

-- HPI headcount Group By Lvl1
Union All

Select
	'HPI' As Cohort,
	[Business Lvl 1 (Group) Code]  As [Business Lvl 1],
	count(1) As HC
From
	HP_WORKER_DATA
Where
	[Worker Status Category Code] <> 'T' And
	[Worker Reg / Temp Code] = 'R' And
	[Report Date] = @maxDate
Group By
	[Business Lvl 1 (Group) Code]