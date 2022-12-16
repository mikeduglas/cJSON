!- Base64 encoding and decoding.

  PROGRAM

  INCLUDE('cjson.inc'), ONCE

  MAP
    Base64Test()
    FileToBase64Test()
    FileToBase64RuleHelperTest()
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

  
  FileToBase64Test()
  FileToBase64RuleHelperTest()

  
Base64Test                    PROCEDURE()
Person                          GROUP
Name                              STRING(20)
BinaryData                        STRING(20)
                                END
jPerson                         &cJSON
  CODE
  printd('Base64Test....')

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
  printd('%|')

  
FileToBase64Test              PROCEDURE()
Person                          GROUP
Name                              STRING(20)
Photo                             STRING(MAX_PATH)
                                END
jPerson                         &cJSON
  CODE
  printd('FileToBase64Test....')

  Person.Name = 'Bob'
  Person.Photo = 'photo_12345.bmp'  !- enter existing image file
  
  !- "options" allow to load base64 encoded file content into "photo" item, instead of filename originally stored in Person.Photo.
  jPerson &= json::CreateObject(Person,, '' | 
    & '['                                                                         |
    & '  {{"name":"Photo","isfile":true,"isbase64":true,"emptystring":"ignore"}'  |
    & ']')
  
  IF NOT jPerson &= NULL
    printd(jPerson.ToString(TRUE))
    jPerson.Delete()
  END
  printd('%|')

  
FileToBase64RuleHelperTest    PROCEDURE()
Person                          GROUP
Name                              STRING(20)
Photo                             STRING(MAX_PATH)
                                END
jPerson                         &cJSON
rh                              CLASS(TCJsonRuleHelper)
ApplyCB                           PROCEDURE(STRING pFldName, *typCJsonFieldRule pRule, ? pValue), ?, DERIVED
                                END
  CODE
  printd('FileToBase64RuleHelperTest....')

  Person.Name = 'Bob'
  Person.Photo = 'photo_12345.bmp'  !- enter existing image file
  
  !- "options" allow to load base64 encoded file content into "photo" item, instead of filename originally stored in Person.Photo.
  jPerson &= json::CreateObject(Person,, | 
    printf(  '' |
    & '['                                                           |
    & '  {{"name":"*","rulehelper":%i},'                            |
    & '  {{"name":"Photo","isbase64":true,"emptystring":"ignore"}'  |
    & ']', ADDRESS(rh)))
  
  IF NOT jPerson &= NULL
    printd(jPerson.ToString(TRUE))
    jPerson.Delete()
  END
  
  
rh.ApplyCB                    PROCEDURE(STRING pFldName, *typCJsonFieldRule pRule, ? pValue)
fContent                        &STRING, AUTO
  CODE
  IF pFldName = 'photo'
    !- Person.Photo contains a file path.
    !- Load this file and return the content as a field value.
    !- Base64 encoding will be perfomed by "isbase64" rule.
    fContent &= json::LoadFile(pValue)
    pValue = fContent
    DISPOSE(fContent)
  END
  RETURN pValue
