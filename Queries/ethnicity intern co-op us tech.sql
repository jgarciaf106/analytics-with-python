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
    HWD.[Report Date] Between '2020-01-31' And '2020-12-31' 
And 
    HWD.[Job Family] Like 'College'
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