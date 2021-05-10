Select Distinct
    Count(HWD.[Worker ID]) As [Female Count]
     
From 
    HP_WORKER_DATA As HWD
Left Join 
    TECH_JOBS_FAM As TT on TT.[Job Family Code] = HWD.[Job Family Code]
Where 
    HWD.[Report Date] Between '2019-04-01' And '2020-03-31' 
And 
    HWD.[Job Family] Not Like 'College'
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
    [Worker Reg / Temp Code] = N'R' 
And 
	[Worker Status Category Code] = N'A' 
And 
     HWD.[Gender Code] Like 'F'
And
    HWD.[Pay Group Country Desc] Like 'United States of America'
Group By 
    HWD.[Report Date]