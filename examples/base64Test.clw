!- Base64 encoding and decoding.

  PROGRAM

  INCLUDE('cjson.inc'), ONCE

  MAP
    Base64Test()
    FileToBase64Test()
    FileToBase64RuleHelperTest()
    FileFromBase64RuleHelperTest()

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
  FileFromBase64RuleHelperTest()
  
  MESSAGE('Done!', 'base64Test', ICON:Asterisk)
  
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
Persons                         QUEUE
Name                              STRING(20)
Photo                             STRING(MAX_PATH)
                                END
jPerson                         &cJSON
rh                              CLASS(TCJsonRuleHelper)
ApplyCB                           PROCEDURE(STRING pFldName, *typCJsonFieldRule pRule, ? pValue), ?, DERIVED
                                END
  CODE
  printd('FileToBase64RuleHelperTest....')

  Persons.Name = 'Bob'
  Persons.Photo = 'photo_12345.bmp'  !- enter existing image file
  ADD(Persons)
  Persons.Name = 'Greg'
  Persons.Photo = 'photo_67890.bmp'  !- enter existing image file
  ADD(Persons)

  !- "options" allow to load base64 encoded file content into "photo" item, instead of filename originally stored in Person.Photo.
  jPerson &= json::CreateArray(Persons,, | 
    printf(  '' |
    & '['                                                           |
    & '  {{"name":"*","rulehelper":%i},'                            |
    & '  {{"name":"Photo","isbase64":true,"emptystring":"ignore"}'  |
    & ']', ADDRESS(rh)))
  
  IF NOT jPerson &= NULL
!    printd(jPerson.ToString(TRUE))
    json::SaveFile('Persons_base64.json', jPerson.ToString())
    jPerson.Delete()
  END
  printd('Done!')
  printd('%|')

  
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

  
FileFromBase64RuleHelperTest  PROCEDURE()
Persons                         QUEUE
Name                              STRING(20)
Photo                             ANY
                                END
jParser                         cJSONFactory
jPerson                         &cJSON
rh                              CLASS(TCJsonRuleHelper)
AutoCB                            PROCEDURE(STRING pFldName, cJSON pItem), DERIVED
                                END
i                               LONG, AUTO
  CODE
  printd('FileFromBase64RuleHelperTest....')

  jPerson &= jParser.ParseFile('Persons_base64.json')
  IF NOT jPerson &= NULL
    jPerson.ToQueue(Persons,, | 
      printf(  '' |
      & '['                                |
      & '  {{"name":"*","rulehelper":%i},' |
      & '  {{"name":"Photo","auto":true}'  |
      & ']', ADDRESS(rh)))
       
    jPerson.Delete()
 
    LOOP i=1 TO RECORDS(Persons)
      GET(Persons, i)
      !- save each person photo
      json::SaveFile(printf('Photo_%s.bmp', Persons.Name), Persons.Photo)
    END
  END
  printd('Done!')

    
rh.AutoCB                     PROCEDURE(STRING pFldName, cJSON pItem)
  CODE
  IF pFldName = 'PHOTO' !- name in UPPERCASE as returned by WHO() w/o a prefix
    !- set Photo to base64 decoded value.
    Persons.Photo = printf('%w', pItem.GetStringValue())
  END
