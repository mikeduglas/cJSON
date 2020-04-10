!converts QUEUE with nested QUEUEs and arrays of GROUPs to json array
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    ComplexQueueTest()
  END

  CODE
  ComplexQueueTest()
  
  

ComplexQueueTest              PROCEDURE

PhonesQueueType                 QUEUE, TYPE
PhoneNumber                       STRING(20),NAME('Number')
PhoneType                         STRING(10),NAME('Type')
                                END

persons                         QUEUE
FirstName                         STRING(20),NAME('FirstName')
LastName                          STRING(20),NAME('LastName')

!- list of emails as an array, up to 2 items
EmailsGroup                       GROUP,DIM(2),NAME('Emails')
EmailGroup                          GROUP,NAME('Email')
EmailAddress                          STRING(256),NAME('Address')
EmailType                             STRING(10),NAME('Type')
                                    END
                                  END
!- list of phone numbers as dynamic queue
PhonesQueue                       &PhonesQueueType,NAME('Phones')
!- this field is an INSTANCE of PhonesQueue
PhonesQueueInstance               LONG
                                END

root                            &cJSON
qIndex                          LONG, AUTO

  CODE
  !- add 1st person
  CLEAR(persons)
  persons.FirstName = 'John'
  persons.LastName = 'Smith'

  !- add emails
  persons.EmailsGroup[1].EmailGroup.EmailAddress = 'jsmith@xyz.org'
  persons.EmailsGroup[1].EmailGroup.EmailType = 'work'
  persons.EmailsGroup[2].EmailGroup.EmailAddress = 'johnsmith@abc.com'
  persons.EmailsGroup[2].EmailGroup.EmailType = 'home'

  !- add phones
  persons.PhonesQueue &= NEW PhonesQueueType
  persons.PhonesQueueInstance = INSTANCE(persons.PhonesQueue,THREAD())
  CLEAR(persons.PhonesQueue)
  persons.PhonesQueue.PhoneNumber = '999-123-45-67'
  persons.PhonesQueue.PhoneType = 'work'
  ADD(persons.PhonesQueue)
  CLEAR(persons.PhonesQueue)
  persons.PhonesQueue.PhoneNumber = '888-333-22-11'
  persons.PhonesQueue.PhoneType = 'mobile'
  ADD(persons.PhonesQueue)

  !- save prson
  ADD(persons)

  
  !- add 2nd person
  CLEAR(persons)
  persons.FirstName = 'Kathy'
  persons.LastName = 'Holmes'

  !- add emails
  persons.EmailsGroup[1].EmailGroup.EmailAddress = 'kholmes@xyz.org'
  persons.EmailsGroup[1].EmailGroup.EmailType = 'work'
  persons.EmailsGroup[2].EmailGroup.EmailAddress = 'cat736@abc.com'
  persons.EmailsGroup[2].EmailGroup.EmailType = 'home'

  !- add phones
  persons.PhonesQueue &= NEW PhonesQueueType
  persons.PhonesQueueInstance = INSTANCE(persons.PhonesQueue,THREAD())
  CLEAR(persons.PhonesQueue)
  persons.PhonesQueue.PhoneNumber = '999-876-54-32'
  persons.PhonesQueue.PhoneType = 'work'
  ADD(persons.PhonesQueue)
  CLEAR(persons.PhonesQueue)
  persons.PhonesQueue.PhoneNumber = '888-001-02-03'
  persons.PhonesQueue.PhoneType = 'mobile'
  ADD(persons.PhonesQueue)

  !- save person
  ADD(persons)
  
  !- note "isQueue" option applied to "Phones" member.
  root &= json::CreateArray(persons,FALSE,'[{{"name":"Phones", "isQueue":true}]')
  json::DebugInfo(root.ToString(TRUE))
  MESSAGE(root.ToString(TRUE))
  
  !dispose all cJSON objects at once
  root.Delete()
  
  !- dispose dynamic queues
  LOOP qIndex = 1 TO RECORDS(persons)
    GET(persons, qIndex)
    IF NOT persons.PhonesQueue &= NULL
      FREE(persons.PhonesQueue)
      DISPOSE(persons.PhonesQueue)
      persons.PhonesQueue &= NULL
      PUT(persons)
    END
  END
  