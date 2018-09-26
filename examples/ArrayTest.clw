!creates string array and iterates each item
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    ArrayTest()
  END

  CODE
  ArrayTest()

ArrayTest                     PROCEDURE()
dows                            &cJSON
item                            &cJSON
strings                         STRING(9), DIM(7)
aIndex                          LONG, AUTO
  CODE
  strings[1] = 'Monday'
  strings[2] = 'Tuesday'
  strings[3] = 'Wednesday'
  strings[4] = 'Thursday'
  strings[5] = 'Friday'
  strings[6] = 'Saturday'
  strings[7] = 'Sunday'
  
  dows &= json::CreateStringArray(strings)
  
  !check the type
  IF dows.GetType() = cJSON_Array
    !loop through the array
    LOOP aIndex = 1 TO dows.GetArraySize()
      item &= dows.GetArrayItem(aIndex)
      IF NOT item &= NULL
        !existing element
        MESSAGE('Day['& aIndex &']: '& item.GetStringValue())
      ELSE
        !error
        MESSAGE('Day['& aIndex &']: error')
        BREAK
      END
    END
  ELSE
    !wrong type of json object
    MESSAGE('Wrong type: '& dows.GetType())
  END
  
  !dispose all cJSON objects at once
  dows.Delete()
