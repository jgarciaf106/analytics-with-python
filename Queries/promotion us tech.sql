Select  Distinct   
	HWD1.[Worker ID],
    Case
    When 
        HWD1.[Gender Code] Is Null Then 'U'
    Else
        HWD1.[Gender Code]
    End As [Gender Code]
From 
	HC_TRACK_CHANGES As HTC
	Inner Join JOB_MOVES As JM On JM.[Move Type] = HTC.[ChangeSubCategory]
	Left Join HP_WORKER_DATA As HWD1 On HWD1.[Report Date] = HTC.[ReportDate] And HWD1.[Worker ID] = HTC.EmployeeID
	Left Join HP_WORKER_DATA As HWD2 On HWD2.[Report Date] = HTC.[PreviousReportDate] And HWD2.[Worker ID] = HTC.EmployeeID
	Left Join TECH_JOBS_FAM AS TJ1 On TJ1.[Job Family] = HWD1.[Job Family]
	Left Join TECH_JOBS_FAM As TJ2 On TJ2.[Job Family] = HWD2.[Job Family]
Where 
	HTC.ReportDate Between '2019-04-01' And '2020-03-31'
And 
    HWD1.[Job Family] Not Like 'College'
And     
	HTC.[ChangeDescription] Like '%Promotion%'
And
    Case
	When 
        TJ1.[Job Family Code] 
    Is Null Then
        'No'
	Else 
        'Yes'
	End Like 'Yes'
And
    HWD1.[Pay Group Country Desc] Like 'United States of America'