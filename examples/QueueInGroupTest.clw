!Parse json containing arrays:
!{
!  "name": "Carl", 
!  "addresses": [{
!    "city": "Rivercity",
!    "street": "Main st",
!    "house": 123
!  },
!  {
!    "city": "Rivertown",
!    "street": "Park st",
!    "house": 987
!  }],
!  "phones": ["1234567", "7654321"]
!}

  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    QueueInGroup()
  END

  CODE
  QueueInGroup()

QueueInGroup                  PROCEDURE()
!- json parser
parser                          cJSONFactory

!- json string
testString                      STRING('{{"name": "Carl", "addresses": [{{"city": "Rivercity","street": "Main st","house": 123},{{"city": "Rivertown","street": "Park st","house": 987}], "phones": ["1234567", "7654321"]}')

!- address queue
AddressQ                        QUEUE
City                              STRING(20)
Street                            STRING(20)
House                             LONG
                                END

!- phone queue
PhonesQ                         QUEUE
Phone                             STRING(20)
                                END

!- person group
PersonGrp                       GROUP
Name                              STRING(20)
Addresses                         &QUEUE      !- reference to AddressQ
Phones                            &QUEUE      !- reference to PhonesQ
                                END

Addr::Inst                      LONG, AUTO    !- INSTANCE(AddressQ, THREAD())
Phones::Inst                    LONG, AUTO    !- INSTANCE(PhonesQ, THREAD())


qIndex                          LONG, AUTO
  CODE
  !- initialize queue references
  PersonGrp.Addresses &= AddressQ
  PersonGrp.Phones &= PhonesQ
    
  !- read instances of queues in this thread
  Addr::Inst = INSTANCE(AddressQ, THREAD())
  Phones::Inst = INSTANCE(PhonesQ, THREAD())
  
  !- parse json
  IF NOT parser.ToGroup(testString, PersonGrp, FALSE, '[{{"name":"Phones", "instance":'& Phones::Inst &'},{{"name":"Addresses", "instance":'& Addr::Inst &'}]')
    MESSAGE('Syntax error near: '& parser.GetError() &'|at position '& parser.GetErrorPosition())
    RETURN
  END

  !- check result
  MESSAGE('Name: '& PersonGrp.Name)
  
  LOOP qIndex = 1 TO RECORDS(AddressQ)
    GET(AddressQ, qIndex)
    MESSAGE('Address: '& CLIP(AddressQ.City) &', '& CLIP(AddressQ.Street) &', '& AddressQ.House)
  END
  LOOP qIndex = 1 TO RECORDS(PhonesQ)
    GET(PhonesQ, qIndex)
    MESSAGE('Phone: '& PhonesQ.Phone)
  END
  
  MESSAGE('Done')
