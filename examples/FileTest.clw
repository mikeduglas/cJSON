!converts FILE to json array
!
  PROGRAM
  PRAGMA('project(#pragma link(C%V%TPS%X%%L%.LIB))')
  INCLUDE('cjson.inc')
  MAP
    FileTest()
  END

  CODE
  FileTest()

FileTest                      PROCEDURE
persons                         FILE, DRIVER('Topspeed'),PRE(PER),CREATE,BINDABLE,THREAD
ByName                            KEY(PER:LastName, PER:FirstName),NOCASE,OPT
ByAge                             KEY(PER:Age, PER:LastName, PER:FirstName),NOCASE,OPT
Record                            RECORD,PRE()
FirstName                           STRING(20)
LastName                            STRING(20)
Gender                              STRING(1)
Age                                 LONG
Hobbies                             STRING(20), DIM(2)
Digits                              REAL, DIM(3)
                                  END
                                END
jsonFactory                     cJSONFactory
root                            &cJSON
  CODE
  CREATE(persons)
  IF ERRORCODE()
    MESSAGE('CREATE fails: '& ERROR())
    RETURN
  END
  
  OPEN(persons)
  IF ERRORCODE()
    MESSAGE('OPEN fails: '& ERROR())
    RETURN
  END

  CLEAR(persons)
  persons.FirstName = 'Mike'
  persons.LastName = 'Duglas'
  persons.Gender = 'M'
  persons.Age = 30
  persons.Hobbies[1] = 'Asphalt 8'
  persons.Hobbies[2] = 'Asphalt 9'
  persons.Digits[1] = 1
  persons.Digits[2] = 2.5
  persons.Digits[3] = 10 / 3
  ADD(persons)

  CLEAR(persons)
  persons.FirstName = 'Anna'
  persons.LastName = 'Karenina'
  persons.Gender = 'F'
  persons.Age = 25
  persons.Hobbies[1] = 'Vronsky'
  persons.Hobbies[2] = 'Railway trains'
  ADD(persons)
  
  !sort by ages
  SET(PER:ByAge)
  
  root &= jsonFactory.CreateArray(persons)
  MESSAGE(root.ToString(TRUE))
   
  CLOSE(persons)

  !dispose all cJSON objects at once
  root.Delete()
