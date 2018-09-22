!converts GROUP to json object and vice versa
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    GroupTest()
  END

  CODE
  GroupTest()

GroupTest                     PROCEDURE()
personGrp                       GROUP, PRE(PER)
FirstName                         STRING(20)
LastName                          STRING(20)
Gender                            STRING(1)
Age                               LONG
Hobbies                           STRING(20), DIM(2)
Digits                            REAL, DIM(3)
                                END

shortGrp                        GROUP, PRE(SHO)
FirstName                         STRING(20)
LastName                          STRING(20)
Gender                            STRING(1)
Age                               LONG
                                END

jsonFactory                     cJSONFactory
root                            &cJSON
  CODE
  personGrp.FirstName = 'Mike'
  personGrp.LastName = 'Duglas'
  personGrp.Gender = 'M'
  personGrp.Age = 30
  personGrp.Hobbies[1] = 'Asphalt 8'
  personGrp.Hobbies[2] = 'Asphalt 9'
  personGrp.Digits[1] = 1
  personGrp.Digits[2] = 2.5
  personGrp.Digits[3] = 10 / 3
  
  root &= jsonFactory.CreateObject(personGrp)
  MESSAGE(root.ToString(TRUE))
  
  !convert json object to simple group, by names
  CLEAR(shortGrp)
  root.ToGroup(shortGrp, FALSE)
  !check the result
  json::DebugInfo('ToGroup BY NAMES')
  json::DebugInfo('FirstName: '& SHO:FirstName)
  json::DebugInfo('LastName '& SHO:LastName)
  json::DebugInfo('Gender '& SHO:Gender)
  json::DebugInfo('Age '& SHO:Age)

  !convert json to simple group, by field pos
  CLEAR(shortGrp)
  root.ToGroup(shortGrp, TRUE)
  !check the result
  json::DebugInfo('ToGroup BY POS')
  json::DebugInfo('FirstName: '& SHO:FirstName)
  json::DebugInfo('LastName '& SHO:LastName)
  json::DebugInfo('Gender '& SHO:Gender)
  json::DebugInfo('Age '& SHO:Age)
  
  !dispose all cJSON objects at once
  root.Delete()
