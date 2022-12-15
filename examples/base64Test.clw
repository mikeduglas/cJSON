!- Base64 encoding and decoding.

  PROGRAM

  INCLUDE('cjson.inc'), ONCE

  MAP
    Base64Test()
    INCLUDE('printf.inc'), ONCE
  END

  CODE
  Base64Test()
  !- Expected result:
  !
  !Original data:
  !Name: Lionel, BinaryData: Some binary data
  !
  !Clarion -> JSON conversion:
  !{ 
  ! "name": "Lionel", 
  ! "binarydata": "U29tZSBiaW5hcnkgZGF0YT==" 
  !}
  !
  !JSON -> Clarion conversion:
  !Name: Lionel, BinaryData: Some binary data

  
Base64Test                    PROCEDURE()
Person                          GROUP
Name                              STRING(20)
BinaryData                        STRING(20)
                                END
jPerson                         &cJSON
  CODE
  !- Clarion to JSON
  Person.Name = 'Lionel'
  Person.BinaryData = 'Some binary data'
  printd('Original data:')
  printd('Name: %s, BinaryData: %s', Person.Name, Person.BinaryData)
  printd('%|')

  jPerson &= json::CreateObject(Person,,'{{"name":"BinaryData","isbase64":true}')
  IF NOT jPerson &= NULL
    printd('Clarion -> JSON conversion:')
    printd(jPerson.ToString(TRUE))
    printd('%|')
    
    !- JSON to Clarion
    printd('JSON -> Clarion conversion:')
    CLEAR(Person)
    IF jPerson.ToGroup(Person,,'{{"name":"BinaryData","isbase64":true}')
      printd('Name: %s, BinaryData: %s', Person.Name, Person.BinaryData)
    END
  END
  