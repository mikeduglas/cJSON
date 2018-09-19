  PROGRAM

  INCLUDE('cjson.inc')

  MAP
    CreateJSON()
    ParseJSON()
  END

  CODE
!  CreateJSON()
  ParseJSON()
  
ParseJSON                     PROCEDURE()
jsonFactory                     cJSONFactory
root                            &cJSON
jsonstr                         STRING(1024), AUTO
  CODE
  jsonstr = '{{"menu": {{"id": "file", "value": "File", "popup": {{"menuitem": [{{"value": "New", "onclick": "CreateNewDoc()"}, {{"value": "Open", "onclick": "OpenDoc()"}, {{"value": "Close", "onclick": "CloseDoc()"}]}}}'
  root &= jsonFactory.Parse(jsonstr)
  MESSAGE(root.ToString(FALSE))
!  MESSAGE(root.ToString(TRUE))
  root.Delete()

CreateJSON                    PROCEDURE()
jsonFactory                     cJSONFactory

root                            &cJSON
fmt                             &cJSON
dow                             &cJSON

strings                         STRING(9), DIM(7)
  CODE
  strings[1] = 'Monday'
  strings[2] = 'Tuesday'
  strings[3] = 'Wednesday'
  strings[4] = 'Thursday'
  strings[5] = 'Friday'
  strings[6] = 'Saturday'
  strings[7] = 'Sunday'
  
  MESSAGE('Start')
  
  fmt &= jsonFactory.CreateObject()
  fmt.AddStringToObject('type', 'rect')
  fmt.AddNumberToObject('width', 1920)  
  fmt.AddNumberToObject('height', 1080)  
  fmt.AddFalseToObject('interlace')
  fmt.AddNumberToObject('frame rate', 24)
  
  dow &= jsonFactory.CreateStringArray(strings)
  
  root &= jsonFactory.CreateObject()
  root.AddItemToObject('name', jsonFactory.CreateString('Jack ("Bee") Nimble'))
  root.AddItemToObject('format', fmt)
  root.AddItemToObject('days of week', dow)
  
  
  MESSAGE(root.ToString())
  root.Delete()
!  MESSAGE('See debuglog!')
  
  MESSAGE('Finish')