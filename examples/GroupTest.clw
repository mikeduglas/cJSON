!converts GROUP to json object
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    GroupTest()
  END

  CODE
  GroupTest()

GroupTest                     PROCEDURE()
personGrp                       GROUP
FirstName                         STRING(20)
LastName                          STRING(20)
Gender                            STRING(1)
Age                               LONG
Hobbies                           STRING(20), DIM(2)
Digits                            REAL, DIM(3)
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
  
  !dispose all cJSON objects at once
  root.Delete()
