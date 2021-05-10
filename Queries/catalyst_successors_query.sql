Declare @maxHcDate Date 

Select @maxHcDate = Max([Report Date]) From HP_WORKER_DATA

-- Cohort Succesors Group by Lvl1
Select 
    CAT.Cohort,
    HWD.[Business Lvl 1 (Group) Code] As [Business Lvl 1],
    Count(1) As Successor
From
    TAL06_UNIQUE_VIEW As TU6
Inner Join
    PD_CATALYST As CAT On CAT.[Employee ID] = TU6.[Employee ID]
Inner Join
    HP_WORKER_DATA As HWD On HWD.[Worker ID] = TU6.[Employee ID]
Where
    CAT.[Cohort] <> '1 (Feb 2019)'
And 
	HWD.[Report Date] = @maxHcDate

Group By 
	CAT.Cohort,
    HWD.[Business Lvl 1 (Group) Code] 

-- Catalyst Succesors Group by Lvl1
Union All 

Select 
    'Catalyst' As Cohort,
    HWD.[Business Lvl 1 (Group) Code] As [Business Lvl 1],
    Count(1) As [Successor]
From
    TAL06_UNIQUE_VIEW As TU6
Inner Join
    PD_CATALYST As CAT On CAT.[Employee ID] = TU6.[Employee ID]
Inner Join
    HP_WORKER_DATA As HWD On HWD.[Worker ID] = TU6.[Employee ID]
Where
    CAT.Cohort <> '1 (Feb 2019)'
And 
	HWD.[Report Date] = @maxHcDate

Group By 
	HWD.[Business Lvl 1 (Group) Code]

-- HPI MGR+ Succesors Group by Lvl1
union all

Select	
    'HPI MGR+' [Cohort],
	HWD.[Business Lvl 1 (Group) Code] As [Business Lvl 1],
	count(1) [Successor]
From 
	TAL06_UNIQUE_VIEW As TU6
Inner Join
    PD_CATALYST As CAT On CAT.[Employee ID] = TU6.[Employee ID]
Inner Join
    HP_WORKER_DATA As HWD On HWD.[Worker ID] = TU6.[Employee ID]
Where
    CAT.Cohort <> '1 (Feb 2019)'
And
    HWD.[Report Date] = @maxHcDate
And 
	HWD.[Worker Reg / Temp Code] = N'R' 
And 
	HWD.[Worker Status Category Code] = N'A' 
And
	HWD.[Business Lvl 4 (MRU) Code] <> 'G034' 
And
	HWD.[Management Level Category] not in ('NONE','PROF')

Group By 
	HWD.[Business Lvl 1 (Group) Code]

-- Headcount Succesors Group by Lvl1
Union All 

Select 
    'HPI' As Cohort,
    HWD.[Business Lvl 1 (Group) Code] As [Business Lvl 1],
    Count(1) As Successor
From
    TAL06_UNIQUE_VIEW As TU6
Inner Join
    HP_WORKER_DATA As HWD On HWD.[Worker ID] = TU6.[Employee ID]

Where
    HWD.[Report Date] = @maxHcDate

Group By 
	HWD.[Business Lvl 1 (Group) Code]