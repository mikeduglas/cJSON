!Using json::CreateObject with the options.
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    OptionsTest()
  END

  CODE
  OptionsTest()

OptionsTest                   PROCEDURE
Account                         GROUP, PRE(ACC)
UserName                          STRING(20)
Password                          STRING(20)
Balance                           REAL
LastVisitDate                     LONG
LastVisitTime                     LONG
                                END

object                          &cJSON
  CODE
  Account.UserName = 'LuckyGamer5371'
  Account.Password = '08AX08$tgeN'
  Account.Balance  = 1250.22
  Account.LastVisitDate = TODAY()
  Account.LastVisitTime = CLOCK()
  
  !we want following json:
  !UserName: as is
  !Password: do not include in json,                          option1 = {{"name":"Password", "ignore":true}
  !Balance: with currency symbol,                             option2 = {{"name":"Balance", "format":"@N$9.2"}
  !LastVisitDate: localized date string, name = "date",       option3 = {{"name":"LastVisitDate", "format":"@d17"}
  !LastVisitTime: localized time string, name = "time",       option4 = {{"name":"LastVisitTime", "format":"@t8"}
  !
  !Pass an array [option1, option2, option3, option4], each optionN describes one group field.
  !Do not forget to put 2 left curly braces.
  
  object &= json::CreateObject(Account, TRUE, '[{{"name":"Password", "ignore":true}, {{"name":"Balance", "format":"@N$9.2"}, {{"name":"LastVisitDate", "jsonname":"date", "format":"@d17"}, {{"name":"LastVisitTime", "jsonname":"time", "format":"@t8"}]')
  json::DebugInfo(object.ToString(FALSE))
  MESSAGE(object.ToString(TRUE))
  
  !dispose all cJSON objects at once
  object.Delete()
