!- Demonstrates field rule inheritance.

  PROGRAM

  INCLUDE('cjson.inc'), ONCE

  MAP
    RuleInheritanceTest()
    INCLUDE('printf.inc'), ONCE
  END

  CODE
  RuleInheritanceTest()
 
!Expected result:
![{ 
!  "jobname": "Job 1", 
!  "startdate": "2022-12-07", 
!  "starttime": "12:35", 
!  "enddate": "2022-12-08", 
!  "endtime": "16:00", 
!  "completed": true, 
!  "abandoned": false 
! },  { 
!  "jobname": "Job 2", 
!  "startdate": "2022-12-07", 
!  "starttime": "14:30", 
!  "enddate": null, 
!  "abandoned": true 
!}]
  
  
RuleInheritanceTest           PROCEDURE()
JobQ                            QUEUE
JobName                           STRING(32)
StartDate                         STRING(10)
StartTime                         STRING(5)
EndDate                           STRING(10)
EndTime                           STRING(5)
Completed                         BOOL
Abandoned                         BOOL
                                END

jRoot                           &cJSON

  CODE
  !- Fill queue
  CLEAR(JobQ)
  JobQ.JobName = 'Job 1'
  JobQ.StartDate = '2022-12-07'
  JobQ.StartTime = '12:35'
  JobQ.EndDate = '2022-12-08'
  JobQ.EndTime = '16:00'
  JobQ.Completed = TRUE
  ADD(JobQ)
  
  CLEAR(JobQ)
  JobQ.JobName = 'Job 2'
  JobQ.StartDate = '2022-12-07'
  JobQ.StartTime = '14:30'
  JobQ.Abandoned = TRUE
  ADD(JobQ)
  
  !- Default rule "EmptyString":"null" overwritten in "EndTime" field rule.
  !- Default rule "IgnoreFalse":true overwritten in "Abandoned" field rule.
  jRoot &= json::CreateArray(JobQ, TRUE,   '' |
    & '['                                                         |
    & '  {{"name":"*","IgnoreFalse":true,"EmptyString":"null"},'  |
    & '  {{"name":"EndTime","EmptyString":"ignore"},'             |
    & '  {{"name":"Completed","IsBool":true},'                    |
    & '  {{"name":"Abandoned","IsBool":true,"IgnoreFalse":false}' |
    & ']')
  printd(jRoot.ToString(TRUE))
  jRoot.Delete()
