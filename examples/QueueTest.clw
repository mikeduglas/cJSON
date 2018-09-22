!converts QUEUE to json array and vice versa
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    QueueTest()
  END

  CODE
  QueueTest()

QueueTest                     PROCEDURE
persons                         QUEUE
FirstName                         STRING(20)
LastName                          STRING(20)
Gender                            STRING(1)
Age                               LONG
Hobbies                           STRING(20), DIM(2)
Digits                            REAL, DIM(3)
                                END

simpleQ                         QUEUE
FirstName                         STRING(20)
LastName                          STRING(20)
Gender                            STRING(1)
Age                               LONG
                                END
qIndex                          LONG, AUTO

jsonFactory                     cJSONFactory
root                            &cJSON
  CODE
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
  
  root &= jsonFactory.CreateArray(persons)
  MESSAGE(root.ToString(TRUE))
  
  !convert json array to simple queue, by pos
  root.ToQueue(simpleQ, TRUE)
  !check the result
  json::DebugInfo('ToQueue BY FIELD POS')
  LOOP qIndex = 1 TO RECORDS(simpleQ)
    GET(simpleQ, qIndex)
    json::DebugInfo('Record#'& qIndex)
    json::DebugInfo('FirstName: '& simpleQ.FirstName)
    json::DebugInfo('LastName '& simpleQ.LastName)
    json::DebugInfo('Gender '& simpleQ.Gender)
    json::DebugInfo('Age '& simpleQ.Age)
  END
  
  !dispose all cJSON objects at once
  root.Delete()
