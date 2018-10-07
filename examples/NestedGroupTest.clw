!converts GROUP with nested GROUPs to json object and vice versa
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    GroupTest()
  END

  CODE
  GroupTest()

GroupTest                     PROCEDURE()
person                          GROUP
Name                              STRING(20)
Address                           GROUP
Line1                               STRING(20)
Line2                               STRING(20)
                                  END
Contact                           GROUP
email                               STRING(64)
web                                 STRING(64)
Phone                               GROUP
Home                                  STRING(20)
Mobile                                STRING(20)
                                    END
                                  END
Gender                            STRING(1)
                                END

root                            &cJSON
  CODE
  person.Name = 'Mike Duglas'
  person.Gender = 'M'
  person.Address.Line1 = 'Main st.'
  person.Address.Line2 = 'Park ave.'
  person.Contact.email = 'mikeduglas@yandex.ru'
  person.Contact.web = 'https://github.com/mikeduglas/cJSON'
  person.Contact.Phone.Home = '(499) 123-45-67'
  person.Contact.Phone.Mobile = '(985) 987-65-43'
  
  !- convert GROUP to json string
  root &= json::CreateObject(person)
  json::DebugInfo('*** GROUP ->> json ***')
  json::DebugInfo(root.ToString(TRUE))
  MESSAGE(root.ToString(TRUE))
  
  !- remove person information
  CLEAR(person)
  
  !- reload person information from json
  root.ToGroup(person)
  
  !- check person info in debugview
  json::DebugInfo('*** json ->> GROUP ***')
  json::DebugInfo('Name '& person.Name)
  json::DebugInfo('Gender '& person.Gender)
  json::DebugInfo('Address.Line1 '& person.Address.Line1)
  json::DebugInfo('Address.Line2 '& person.Address.Line2)
  json::DebugInfo('Contact.email '& person.Contact.email)
  json::DebugInfo('Contact.web '& person.Contact.web)
  json::DebugInfo('Phone.Home '& person.Contact.Phone.Home)
  json::DebugInfo('Phone.Mobile '& person.Contact.Phone.Mobile)
  
  !dispose all cJSON objects at once
  root.Delete()

!   output:
!
!  [17340] [cJSON] *** GROUP ->> json ***
!  [17340] [cJSON] { 
!  [17340]  "name": "Mike Duglas", 
!  [17340]  "address": { 
!  [17340]   "line1": "Main st.", 
!  [17340]   "line2": "Park av." 
!  [17340]  }, 
!  [17340]  "contact": { 
!  [17340]   "email": "mikeduglas@yandex.ru", 
!  [17340]   "web": "https://github.com/mikeduglas/cJSON", 
!  [17340]   "phone": { 
!  [17340]    "home": "(499) 123-45-67", 
!  [17340]    "mobile": "(985) 987-65-43" 
!  [17340]   } 
!  [17340]  }, 
!  [17340]  "gender": "M" 
!  [17340] }
!  [17340] [cJSON] *** json ->> GROUP ***
!  [17340] [cJSON] Name Mike Duglas
!  [17340] [cJSON] Gender M
!  [17340] [cJSON] Address.Line1 Main st.
!  [17340] [cJSON] Address.Line2 Park av.
!  [17340] [cJSON] Contact.email mikeduglas@yandex.ru
!  [17340] [cJSON] Contact.web https://github.com/mikeduglas/cJSON
!  [17340] [cJSON] Phone.Home (499) 123-45-67
!  [17340] [cJSON] Phone.Mobile (985) 987-65-43
