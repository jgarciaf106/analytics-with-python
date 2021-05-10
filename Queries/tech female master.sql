Declare @maxReport As Date
Set @maxReport = (Select Max([Report Date]) From HP_WORKER_DATA)

Select 
    HWD.[Worker Reg / Temp Desc] as [Worker Type],
    HWD.[Email - Primary Work],
    HWD.[Preferred Name],
    HWD.[Business Lvl 1 (Group) Code] As [Hybrid L1 Code],
    HWD.[Gender Code],
    Case
	When 
        TT.[Job Family Code] 
    Is Null Then
        'N'
	Else 
        'Y'
	End As [Technical Job],
    HWD.[TCP Job],
    HWD.[Job Family Group],
    HWD.[Job Family],
    HWD.[Management Level],
    HWD.[Work Location Theater Name],
    HWD.[Work Address - Country],
    HWD.[Work Address - State/Province],
    HWD.[Metro Area],
    'N' As [Opt In]
From 
    HP_WORKER_DATA As HWD
Left Join 
    TECH_JOBS_FAM As TT on TT.[Job Family Code] = HWD.[Job Family Code]
Where 
    HWD.[Report Date] = @maxReport
AND
    HWD.[Gender Code] Like 'F'
And 
    HWD.[Management Level] Like 'MAS'
And
    HWD.[Worker Reg / Temp Code] Like 'R' 
And 
	[Worker Status Category Code] Like 'A' 
And
    Case
        When 
            TT.[Job Family Code] 
        Is Null Then
            'N'
        Else 
            'Y'
        End Like 'Y'
And 
   HWD.[Email - Primary Work] Not In (Select [HP email address] From [TECH_FEMALE_MASTER]) 

Union All

Select 
    HWD.[Worker Reg / Temp Desc] as [Worker Type],
    HWD.[Email - Primary Work],
    HWD.[Preferred Name],
    HWD.[Business Lvl 1 (Group) Code] As [Hybrid L1 Code],
    HWD.[Gender Code],
    'Y' As [Technical Job],
    HWD.[TCP Job],
    HWD.[Job Family Group],
    HWD.[Job Family],
    HWD.[Management Level],
    HWD.[Work Location Theater Name],
    HWD.[Work Address - Country],
    HWD.[Work Address - State/Province],
    HWD.[Metro Area],
    'Y' As [Opt In] 
From 
    [TECH_FEMALE_MASTER] As TFM
Inner Join
    HP_WORKER_DATA As HWD On HWD.[Email - Primary Work] = TFM.[HP email address]
Where 
    HWD.[Report Date] = @maxReport