!- How to load simple arrays to queues.

  PROGRAM

  INCLUDE('cjson.inc'),ONCE

  MAP
    SimpleArrayToQueue()

    INCLUDE('printf.inc'),ONCE
  END

  CODE
  SimpleArrayToQueue()
  !- Expected result:
  !  Company:
  !    Name: Roga & Copyta
  !    Location: Chernomorsk
  !    Person[1]=Bender
  !    Person[2]=Balaganov


SimpleArrayToQueue            PROCEDURE()
sJson                           STRING('{{"name": "Roga & Copyta", "location": "Chernomorsk", "staff": ["Bender",  "Balaganov"]}')
Company                         GROUP
Name                              STRING(32)
Location                          STRING(32)
Staff                             &QUEUE    !- a reference to Persons queue
                                END
Persons                         QUEUE
Position                          STRING(20)
Name                              STRING(20)
                                END

jParser                         cJSONFactory
i                               LONG, AUTO
  CODE
  IF jParser.ToGroup(sJson, Company,, printf('{{"name":"Staff","instance":%i,"fieldnumber":%i}', |
    INSTANCE(Persons, THREAD()), | 
    2))  !- 2 is an ordinal position of "Name" field.

    !- test
    printd('Company:')
    printd('  Name: %s', Company.Name)
    printd('  Location: %s', Company.Location)
    LOOP i=1 TO RECORDS(Persons)
      GET(Persons, i)
      printd('  Person[%i]=%s', i, Persons.Name)
    END
  END
  