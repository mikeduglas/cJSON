!- Demonstrates RuleHelperTest class purpose.

  PROGRAM

  INCLUDE('cjson.inc'), ONCE

  MAP
    RuleHelperTest()
    INCLUDE('printf.inc'), ONCE
  END

  CODE
  RuleHelperTest()
 
!Expected result:
![{ 
!  "jobname": "Job 1", 
!  "startdate": "2022-12-07", 
!  "starttime": "12:35", 
!  "enddate": "2022-12-08", 
!  "endtime": "16:00" 
! },  { 
!  "jobname": "Job 2", 
!  "startdate": "2022-12-10", 
!  "starttime": "14:30", 
!  "enddate": "2022-12-11", 
!  "endtime": "20:00" 
!}]
  
  
RuleHelperTest                PROCEDURE()
JobQ                            QUEUE
JobName                           STRING(32)
StartDate                         LONG
StartTime                         LONG
EndDate                           LONG
EndTime                           LONG
                                END

rh                              CLASS(TCJsonRuleHelper)
FindCB                            PROCEDURE(STRING fldName, *typCJsonFieldRule rule), DERIVED
                                END

jRoot                           &cJSON

  CODE
  !- Fill queue
  JobQ.JobName = 'Job 1'
  JobQ.StartDate = DATE(12, 7, 2022)
  JobQ.StartTime = DEFORMAT('12:35', @t1)
  JobQ.EndDate = DATE(12, 8, 2022)
  JobQ.EndTime = DEFORMAT('16:00', @t1)
  ADD(JobQ)
  JobQ.JobName = 'Job 2'
  JobQ.StartDate = DATE(12, 10, 2022)
  JobQ.StartTime = DEFORMAT('14:30', @t1)
  JobQ.EndDate = DATE(12, 11, 2022)
  JobQ.EndTime = DEFORMAT('20:00', @t1)
  ADD(JobQ)
  
  !- Pass TCJsonRuleHelper instance and format json inside FindCB method.
  jRoot &= json::CreateArray(JobQ, , printf('{{"name":"*","RuleHelper":%s}', ADDRESS(rh)))
  printd(jRoot.ToString(TRUE))
  jRoot.Delete()
  
rh.FindCB                     PROCEDURE(STRING fldName, *typCJsonFieldRule rule)
  CODE
  IF INSTRING('date', fldName, 1, 1)
    !- format dates
    rule.FormatLeft = '@d10-'
  ELSIF INSTRING('time', fldName, 1, 1)
    !- format times
    rule.FormatLeft = '@t1'
  END
