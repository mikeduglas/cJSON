!converts FILE to json array and vice versa
!
  PROGRAM
  PRAGMA('project(#pragma link(C%V%TPS%X%%L%.LIB))')
  INCLUDE('cjson.inc')
  MAP
    FileTest()
    FileTest_WithBlobs()
  END

  CODE
  FileTest()
!  FileTest_WithBlobs()

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

simple                          FILE, DRIVER('Topspeed'),PRE(SIM),CREATE,BINDABLE,THREAD
ByName                            KEY(SIM:LastName, SIM:FirstName),NOCASE,OPT
ByAge                             KEY(SIM:Age, SIM:LastName, SIM:FirstName),NOCASE,OPT
Record                            RECORD,PRE()
FirstName                           STRING(20)
LastName                            STRING(20)
Gender                              STRING(1)
Age                                 LONG
                                  END
                                END
fIndex                          LONG, AUTO

root                            &cJSON
  CODE
  CREATE(persons)
  IF ERRORCODE()
    MESSAGE('CREATE(persons) fails: '& ERROR())
    RETURN
  END
  
  OPEN(persons)
  IF ERRORCODE()
    MESSAGE('OPEN(persons) fails: '& ERROR())
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
  
  root &= json::CreateArray(persons)
  MESSAGE(root.ToString(TRUE))

  CLOSE(persons)

  !convert json array to simple table, by pos
  CREATE(simple)
  IF ERRORCODE()
    MESSAGE('CREATE(simple) fails: '& ERROR())
    RETURN
  END

  OPEN(simple)
  IF ERRORCODE()
    MESSAGE('OPEN(simple) fails: '& ERROR())
    RETURN
  END
  
  root.ToFile(simple, TRUE)
  !check the result
  json::DebugInfo('ToFile BY FIELD POS')
  
  fIndex = 0
  SET(simple)
  LOOP
    NEXT(simple)
    IF ERRORCODE()
      BREAK
    END
    
    fIndex += 1
    
    json::DebugInfo('Record#'& fIndex)
    json::DebugInfo('FirstName: '& simple.FirstName)
    json::DebugInfo('LastName '& simple.LastName)
    json::DebugInfo('Gender '& simple.Gender)
    json::DebugInfo('Age '& simple.Age)
  END
  
  CLOSE(simple)

  !dispose all cJSON objects at once
  root.Delete()

FileTest_WithBlobs            PROCEDURE
persons                         FILE, DRIVER('Topspeed'),PRE(PER),CREATE,BINDABLE,THREAD
ByName                            KEY(PER:LastName, PER:FirstName),NOCASE,OPT
ByAge                             KEY(PER:Age, PER:LastName, PER:FirstName),NOCASE,OPT
Biography                         BLOB
Record                            RECORD,PRE()
FirstName                           STRING(20)
LastName                            STRING(20)
Gender                              STRING(1)
Age                                 LONG
Hobbies                             STRING(20), DIM(2)
Digits                              REAL, DIM(3)
                                  END
                                END

simple                          FILE, DRIVER('Topspeed'),PRE(SIM),CREATE,BINDABLE,THREAD
ByName                            KEY(SIM:LastName, SIM:FirstName),NOCASE,OPT
ByAge                             KEY(SIM:Age, SIM:LastName, SIM:FirstName),NOCASE,OPT
Biography                         BLOB
Record                            RECORD,PRE()
FirstName                           STRING(20)
LastName                            STRING(20)
Gender                              STRING(1)
Age                                 LONG
                                  END
                                END
fIndex                          LONG, AUTO

root                            &cJSON
  CODE
  CREATE(persons)
  IF ERRORCODE()
    MESSAGE('CREATE(persons) fails: '& ERROR())
    RETURN
  END
  
  OPEN(persons)
  IF ERRORCODE()
    MESSAGE('OPEN(persons) fails: '& ERROR())
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
  persons.Biography{PROP:Size} = LEN('He is a Thai Jedi who defines himself as pansexual. He started studying philosophy, politics and economics at college but never finished the course.')
  persons.Biography[0 : persons.Biography{PROP:Size} - 1] = 'He is a Thai Jedi who defines himself as pansexual. He started studying philosophy, politics and economics at college but never finished the course.'
  ADD(persons)

  CLEAR(persons)
  persons.FirstName = 'Anna'
  persons.LastName = 'Karenina'
  persons.Gender = 'F'
  persons.Age = 25
  persons.Hobbies[1] = 'Vronsky'
  persons.Hobbies[2] = 'Railway trains'
  persons.Biography{PROP:Size} = LEN('She grew up in a middle class neighbourhood. Her parents separated when she was small, but remained friends and provided a happy, stable home.')
  persons.Biography[0 : persons.Biography{PROP:Size} - 1] = 'She grew up in a middle class neighbourhood. Her parents separated when she was small, but remained friends and provided a happy, stable home.'
  ADD(persons)
  
  !sort by ages
  SET(PER:ByAge)

  root &= json::CreateArray(persons,,,TRUE)
  MESSAGE(root.ToString(TRUE))

  CLOSE(persons)

  !convert json array to simple table, by pos
  CREATE(simple)
  IF ERRORCODE()
    MESSAGE('CREATE(simple) fails: '& ERROR())
    RETURN
  END

  OPEN(simple)
  IF ERRORCODE()
    MESSAGE('OPEN(simple) fails: '& ERROR())
    RETURN
  END
  
  root.ToFile(simple, TRUE, , TRUE)
  !check the result
  json::DebugInfo('ToFile BY FIELD POS')

  fIndex = 0
  SET(simple)
  LOOP
    NEXT(simple)
    IF ERRORCODE()
      BREAK
    END
    
    fIndex += 1
    
    json::DebugInfo('Record#'& fIndex)
    json::DebugInfo('FirstName: '& simple.FirstName)
    json::DebugInfo('LastName '& simple.LastName)
    json::DebugInfo('Gender '& simple.Gender)
    json::DebugInfo('Age '& simple.Age)
    
    IF simple.Biography{PROP:Size}
      json::DebugInfo('Biography '& simple.Biography[0 : simple.Biography{PROP:Size} - 1])
    END
  END
  
  CLOSE(simple)

  !dispose all cJSON objects at once
  root.Delete()
