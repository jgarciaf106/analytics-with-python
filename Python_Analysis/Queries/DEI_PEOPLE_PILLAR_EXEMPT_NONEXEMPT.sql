WITH queryDate (vGDate) as (
   values (to_date('2021-08-31', 'YYYY-MM-DD'))
)
Select
    D."Table",
    D."Metric",
    Sum(D."Headcount") As "Rep Headcount"
From (
    Select 
        "Report Date",
        'B/AA Technical' As "Metric",
        1 As "Headcount",
        'Exempt+Non-Exempt' As "Table"
    From
        "HPW_DATA" As  WD
    Left Join
        "TECHNICAL_JOBS" AS TT ON TT."Job Family Code" = WD."Job Family Code"
    Where 
        "Worker Reg / Temp Code" = 'R'
    And 
        "Worker Status Category Code" = 'A'
    And
        "Pay Group Country Desc" = 'United States of America'
    And
        "Ethnicity Group" = 'BLACK_USA'
    And
        Case
            When TT."Job Family Code" Is Null Then 'No'
            Else 'Yes'
        End = 'Yes'
        
    Union All

    Select
        "Report Date", 
        'B/AA Representation' As "Metric",
        1 As "Headcount",
        'Exempt+Non-Exempt' As "Table"
    From
    "HPW_DATA" As  WD
    Left Join
        "TECHNICAL_JOBS" AS TT ON TT."Job Family Code" = WD."Job Family Code"
    Where 
        "Worker Reg / Temp Code" = 'R'
    And 
        "Worker Status Category Code" = 'A'
    And
        "Pay Group Country Desc" = 'United States of America'
    And
        "Ethnicity Group" = 'BLACK_USA'
        
    Union All

    Select 
        "Report Date",
        'B/AA VP+ level' As "Metric",
        1 As "Headcount",
        'Exempt+Non-Exempt' As "Table"
    From 
        "HPW_DATA" As  WD
    Left Join
        "TECHNICAL_JOBS" AS TT ON TT."Job Family Code" = WD."Job Family Code"
    Where 
        "Worker Reg / Temp Code" = 'R'
    And 
        "Worker Status Category Code" = 'A'
    And
        "Pay Group Country Desc" = 'United States of America'
    And
        "Ethnicity Group" = 'BLACK_USA'
    And 
        "Management Level" In ('EXE','SFL','FEL')
) As D, queryDate
Where
    D."Report Date" = vgdate

Group By 
    D."Table",
    D."Metric"