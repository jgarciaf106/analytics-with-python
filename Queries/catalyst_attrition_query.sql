-- Rolling Dates Calc

Declare @EndDate Date

Select 
	@EndDate = max([Report Date]) 
From 
	HP_WORKER_DATA
Where 
	[Worker Reg / Temp Code] = N'R' and 
	[Worker Status Category Code] = N'A'

Declare @RollingDate Date

Select @RollingDate = Eomonth(@EndDate, -11)

-- Variable Declare for Vet's Last Date

Declare @VetDate Date

Select @VetDate = Max([Report Date]) From WFP15_VET_VIEW

-- Variable for Tech Latest definition

Declare @TechDate Date

Select @TechDate = Max([Report Date]) From TECH_JOBS_MAP

-- FY Start Date

Declare @FYStart Date = '2020-10-31'

-- HPI Orgs

Declare @HPI_Orgs table (
	[Business Lvl 1 (Group) Code] nvarchar(5) not null)

Insert Into @HPI_Orgs Values 
	('CMP'),
	('FIN'),
	('GCOM'),
	('HFED'),
	('HPAM'),
	('HPAP'),
	('HPCS'),
	('HPEM'),
	('HCCO'),
	('HPGC'),
	('HPHQ'),
	('HPHR'),
	('HPIP'),
	('HPTO'),
	('HPIT'),
	('OPER'),
	('PSYS'),
	('SBM'),
	('OTHS')

-- Regular Active

select	
	wd.[Report Date],
	wd.[Business Lvl 1 (Group) Code],
	tab.[Cohort],
	count(1) [HC],
	0 [Voluntary Attrits]
from 
	WorkerData wd
	inner join @tablita tab on tab.EID = wd.[Worker ID]
	left join FEDL1 f1 on f1.[Business Lvl 4 (MRU) Code] = wd.[Business Lvl 4 (MRU) Code]
	left join FEDL2 f2 on f2.[Business Lvl 4 (MRU) Code] = wd.[Business Lvl 4 (MRU) Code]
	left join TechnicalJobsMapping tj on tj.[Job Family] = wd.[Job Family] and
	tj.[Report Date] = @TechDate

where 
	wd.[Report Date] >= @RollingDate and 
	[Worker Reg / Temp Code] = N'R' and 
	[Worker Status Category Code] = N'A' and
	tab.Cohort <> '1 (Feb 2019)'

group by 
	wd.[Report Date],
	wd.[Business Lvl 1 (Group) Code],
	tab.[Cohort]

union all

-- Attrition

select	
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0) [Report Date],
	wd.[Business Lvl 1 (Group) Code],
	tab.[Cohort],
	0 [HC],
	count(1) [Voluntary Attrits]
from WorkerData wd
inner join @tablita tab on tab.EID = wd.[Worker ID]
inner join AttritionData td on td.[Report Date] = wd.[Report Date]
	and td.[Worker ID] = wd.[Worker ID]
	and wd.[Attrition Type] = 'Voluntary'
	
inner join @HPI_Orgs hp on hp.[Business Lvl 1 (Group) Code] = wd.[Business Lvl 1 (Group) Code]

left join FEDL1 f1 on f1.[Business Lvl 4 (MRU) Code] = wd.[Business Lvl 4 (MRU) Code]
left join FEDL2 f2 on f2.[Business Lvl 4 (MRU) Code] = wd.[Business Lvl 4 (MRU) Code]
left join TechnicalJobs tj on tj.[Job Family] = wd.[Job Family]

-- Vets pulling
	--left join TMVet tv on tv.[Employee ID] = wd.[Worker ID] and
	--	tv.[Report Date] = @VetDate
where 
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0) >= @RollingDate and
	tab.Cohort <> '1 (Feb 2019)'
group by 
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0),
	wd.[Business Lvl 1 (Group) Code],
	tab.[Cohort]

union all

select	
	wd.[Report Date],
	wd.[Business Lvl 1 (Group) Code],
	'HPI MGR+' [Cohort],
	count(1) [HC],
	0 [Voluntary Attrits]
from 
	WorkerData wd

where 
	wd.[Report Date] >= @RollingDate and 
	[Worker Reg / Temp Code] = N'R' and 
	[Worker Status Category Code] = N'A' and
	[Business Lvl 4 (MRU) Code] <> 'G034' and
	wd.[Management Level Category] not in ('NONE','PROF')

group by 
	wd.[Report Date] ,
	wd.[Business Lvl 1 (Group) Code]
	--[Cohort]


union all

-- Attrition

select	
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0) [Report Date],
	wd.[Business Lvl 1 (Group) Code],
	'HPI MGR+' [Cohort],
	0 [HC],
	count(1) [Voluntary Attrits]
from WorkerData wd
--inner join @tablita tab on tab.EID = wd.[Worker ID]
inner join AttritionData td on td.[Report Date] = wd.[Report Date]
	and td.[Worker ID] = wd.[Worker ID]
	and wd.[Attrition Type] = 'Voluntary'

where 
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0) >= @RollingDate and
	wd.[Business Lvl 4 (MRU) Code] <> 'G034' and
	wd.[Management Level Category] not in ('NONE','PROF')
group by 
    wd.[Business Lvl 1 (Group) Code],
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0)

-- HPI all attrit minus CF

union all

select	
	wd.[Report Date],
	wd.[Business Lvl 1 (Group) Code],
	'HPI' [Cohort],
	count(1) [HC],
	0 [Voluntary Attrits]
from 
	WorkerData wd

where 
	wd.[Report Date] >= @RollingDate and 
	[Worker Reg / Temp Code] = N'R' and 
	[Worker Status Category Code] = N'A' and
	[Business Lvl 4 (MRU) Code] <> 'G034'

group by 
	wd.[Business Lvl 1 (Group) Code],
	wd.[Report Date] --,
	--[Cohort]


union all

-- Attrition

select	
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0) [Report Date],    
    [Business Lvl 1 (Group) Code],
	'HPI' [Cohort],
	0 [HC],
	count(1) [Voluntary Attrits]
from WorkerData wd
--inner join @tablita tab on tab.EID = wd.[Worker ID]
inner join AttritionData td on td.[Report Date] = wd.[Report Date]
	and td.[Worker ID] = wd.[Worker ID]
	and wd.[Attrition Type] = 'Voluntary'

where 
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0) >= @RollingDate and
	wd.[Business Lvl 4 (MRU) Code] <> 'G034'
group by 
    
    [Business Lvl 1 (Group) Code],
	eomonth(dateadd(d, 1, wd.[Termination Date]), 0)