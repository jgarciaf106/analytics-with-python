declare @maxdate date
select @maxdate = max([Report Date]) from HP_WORKER_DATA

select
	[Cohort],
	wd1.[Business Lvl 1 (Group) Code],
	count(1) [HC]

from

	PD_CATALYST tab
	left join HP_WORKER_DATA wd1 on wd1.[Worker ID] = tab.[Employee ID] and
		wd1.[Report Date] = tab.[Cohort Date]
	left join HP_WORKER_DATA wd3 on wd3.[Worker ID] = tab.[Employee ID] and
		wd3.[Report Date] = @maxdate

where

	case
		when wd3.[Worker ID] is null Then 'T'
		Else wd3.[Worker Status Category Code]
	End <> 'T' and
	wd3.[Worker Reg / Temp Code] = 'R' and
	[Cohort] <> '1 (Feb 2019)'

group by

	[Cohort],
	wd1.[Business Lvl 1 (Group) Code]

	union all

select

	'Catalyst' [Cohort],
	wd1.[Business Lvl 1 (Group) Code],
	count(1)

from

	PD_CATALYST tab
	left join HP_WORKER_DATA wd1 on wd1.[Worker ID] = tab.[Employee ID] and
		wd1.[Report Date] = tab.[Cohort Date]
	left join HP_WORKER_DATA wd3 on wd3.[Worker ID] = tab.[Employee ID] and
		wd3.[Report Date] = @maxdate
where

	case
		when wd3.[Worker ID] is null Then 'T'
		Else wd3.[Worker Status Category Code]
	End <> 'T' and
	wd3.[Worker Reg / Temp Code] = 'R' and
	[Cohort] <> '1 (Feb 2019)'

group by

	wd1.[Business Lvl 1 (Group) Code]


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

union all

select

	'HPI' [Cohort],
	[Business Lvl 1 (Group) Code],
	count(1) [HC]

from

	HP_WORKER_DATA

where

	[Worker Status Category Code] <> 'T' and
	[Worker Reg / Temp Code] = 'R' and
	[Report Date] = @maxdate
group by

	[Business Lvl 1 (Group) Code]