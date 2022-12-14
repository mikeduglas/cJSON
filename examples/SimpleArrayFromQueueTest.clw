!- How to create simple arrays from queues.

  PROGRAM

  INCLUDE('cjson.inc'),ONCE

  MAP
    CreateSimpleArrayTest()
    CreateObjectWithSimpleArrayTest()

    INCLUDE('printf.inc'),ONCE
  END

  CODE
  CreateSimpleArrayTest()
  !- Expected result
  !Names array: ["Ippolit",  "Ostap"]
  !Ages array: [74,  42]
  !Weights array: [73.5,  69.8]
  !Contacts array: []
  
  CreateObjectWithSimpleArrayTest()
  !- Expected result
  !Company: { 
  !   "name": "Roga & Copyta", 
  !   "location": "Chernomorsk", 
  !   "staff": ["Bender",  "Balaganov"] 
  ! }


CreateSimpleArrayTest         PROCEDURE()
Persons                         QUEUE
Name                              STRING(20)
Age                               LONG
Weight                            REAL
                                END

jNameArray                      &CJSON
jAgeArray                       &CJSON
jWeightArray                    &CJSON
jContactArray                   &CJSON
  CODE
  !- fill Persons queue
  Persons.Name = 'Ippolit'
  Persons.Age = 74
  Persons.Weight = 73.5
  ADD(Persons)
  Persons.Name = 'Ostap'
  Persons.Age = 42
  Persons.Weight = 69.8
  ADD(Persons)
  
  !- create simple arrays
  jNameArray &= json::CreateSimpleArray(Persons, 1)     !- 1 is an ordinal position of "Name" field.
  jAgeArray &= json::CreateSimpleArray(Persons, 2)      !- 2 is an ordinal position of "Age" field.
  jWeightArray &= json::CreateSimpleArray(Persons, 3)   !- 3 is an ordinal position of "Weight" field.
  jContactArray &= json::CreateSimpleArray(Persons, 4)  !- 4: invalid ordinal position
  
  IF NOT jNameArray &= NULL
    printd('Names array: %s', jNameArray.ToString(TRUE))
    jNameArray.Delete()
  END
  
  IF NOT jAgeArray &= NULL
    printd('Ages array: %s', jAgeArray.ToString(TRUE))
    jAgeArray.Delete()
  END
  
  IF NOT jWeightArray &= NULL
    printd('Weights array: %s', jWeightArray.ToString(TRUE))
    jWeightArray.Delete()
  END
  
  IF NOT jContactArray &= NULL
    printd('Contacts array: %s', jContactArray.ToString(TRUE))
    jContactArray.Delete()
  END

  
CreateObjectWithSimpleArrayTest   PROCEDURE()
Company                             GROUP
Name                                  STRING(32)
Location                              STRING(32)
Staff                                 &QUEUE
                                    END

Persons                             QUEUE
Position                              STRING(20)
Name                                  STRING(20)
                                    END

jCompany                            &cJSON

  CODE
  !- fill Persons queue
  Persons.Position = 'President'
  Persons.Name = 'Bender'
  ADD(Persons)

  Persons.Position = 'Driver'
  Persons.Name = 'Balaganov'
  ADD(Persons)
  
  !- fill Company
  Company.Name = 'Roga & Copyta'
  Company.Location = 'Chernomorsk'
  Company.Staff &= Persons
  
  jCompany &= json::CreateObject(Company,, printf('{{"name":"Staff","instance":%i,"fieldnumber":%i}', |
    INSTANCE(Persons, THREAD()), | 
    2))  !- 2 is an ordinal position of "Name" field.
  
  IF NOT jCompany &= NULL
    printd('Company: %s', jCompany.ToString(TRUE))
    jCompany.Delete()
  END
