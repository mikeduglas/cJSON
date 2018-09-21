! create following JSON string:
!
!  { 
!    "name": "Jack (\"Bee\") Nimble", 
!    "format": { 
!      "type": "rect", 
!      "width": 1920, 
!      "height": 1080, 
!      "interlace": false, 
!      "frame rate": 24 
!    }, 
!    "days of week": ["Monday",  "Tuesday",  "Wednesday",  "Thursday",  "Friday",  "Saturday",  "Sunday"] 
!  }

  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    CreateJSON()
  END

  CODE

  CreateJSON()

CreateJSON                    PROCEDURE()
jsonFactory                     cJSONFactory

root                            &cJSON  !root object
fmt                             &cJSON  !format object
dow                             &cJSON  !days of week array

strings                         STRING(9), DIM(7)
  CODE
  strings[1] = 'Monday'
  strings[2] = 'Tuesday'
  strings[3] = 'Wednesday'
  strings[4] = 'Thursday'
  strings[5] = 'Friday'
  strings[6] = 'Saturday'
  strings[7] = 'Sunday'
  
  !create format object
  fmt &= jsonFactory.CreateObject()
  fmt.AddStringToObject('type', 'rect')
  fmt.AddNumberToObject('width', 1920)  
  fmt.AddNumberToObject('height', 1080)  
  fmt.AddFalseToObject('interlace')
  fmt.AddNumberToObject('frame rate', 24)
  
  !create days of week array
  dow &= jsonFactory.CreateStringArray(strings)
  
  !create root object
  root &= jsonFactory.CreateObject()
  
  !add a string to root
  root.AddItemToObject('name', jsonFactory.CreateString('Jack ("Bee") Nimble'))
  
  !add format object to root
  root.AddItemToObject('format', fmt)

  !add days array to root
  root.AddItemToObject('days of week', dow)
  
  !json::DebugInfo(root.ToString(TRUE))
  MESSAGE(root.ToString(TRUE))
  
  !dispose all cJSON objects at once
  root.Delete()
