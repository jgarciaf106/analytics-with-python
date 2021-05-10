declare @FYStart date = '2018-10-31'

Select Distinct
    HWD.[Worker ID],
    Case
    When 
        HWD.[Gender Code] Is Null Then 'U'
    Else
        HWD.[Gender Code]
    End As [Gender Code]
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
    HWD.[Pay Group Country Desc] Like 'United States of America'
And 
	Case
		When HWD.[Original Hire Date] > @FYStart or HWD.[Hire Date] > @FYStart then 'Yes'
		Else 'No'
	End Like 'Yes' 