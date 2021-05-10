Select Distinct
    HWD.[Worker ID],
    Case
    When 
        HWD.[Gender Code] Is Null Then 'U'
    Else
        HWD.[Gender Code]
    End As [Gender Code],
    HWD.[Ethnicity]
     
From 
    HP_WORKER_DATA As HWD
Left Join 
    TECH_JOBS_FAM As TT on TT.[Job Family Code] = HWD.[Job Family Code]
Where 
    HWD.[Report Date] Like '2020-12-31' 
And 
    HWD.[Management Level] Like 'ENT'
And 
    HWD.[Ethnicity] Not Like 'Unknown'
And
    [Worker Reg / Temp Code] = N'R' 
And 
	[Worker Status Category Code] = N'A' 
And
    Case
	When 
        TT.[Job Family Code] 
    Is Null Then
        'No'
	Else 
        'Yes'
	End Like 'Yes'
And
    HWD.[Pay Group Country Desc] Like 'United States of America'