!Parse following json string:
!
!{ 
!  "menu": { 
!    "id": "file", 
!    "value": "File", 
!    "popup": { 
!      "menuitem": [{ 
!        "value": "Create", 
!        "onclick": "CreateNewDoc()" 
!      },  { 
!        "value": "Open", 
!        "onclick": "OpenDoc()" 
!      },  { 
!        "value": "Close", 
!        "onclick": "CloseDoc()" 
!      }] 
!    } 
!  } 
!}




  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    ParseJSON(STRING pJsonString)
    ParseAndModifyJSON(STRING pJsonString)  !changes 1st menu item's value from "Create" to "New"
  END

jsonStr                       STRING(256), AUTO

  CODE
  jsonStr = '{{"menu": {{"id": "file", "value": "File", "popup": {{"menuitem": [{{"value": "Create", "onclick": "CreateNewDoc()"}, {{"value": "Open", "onclick": "OpenDoc()"}, {{"value": "Close", "onclick": "CloseDoc()"}]}}}'
  ParseJSON(jsonStr)
!  ParseAndModifyJSON(jsonStr)

ParseJSON                     PROCEDURE(STRING pJsonString)
jsonFactory                     cJSONFactory
root                            &cJSON
  CODE
  !parse json string, get root object
  root &= jsonFactory.Parse(pJsonString)
  IF root &= NULL
    !error
    MESSAGE('Syntax error near: '& jsonFactory.GetError() &'|at position '& jsonFactory.GetErrorPosition())
    RETURN
  END
  
  !see the resulting json
!  MESSAGE(root.ToString(FALSE)) !unformatted outpur
  json::DebugInfo(root.ToString(TRUE)) !formatted outpur
  MESSAGE(root.ToString(TRUE)) !formatted outpur
  
  !dispose all cJSON objects at once
  root.Delete()

  
ParseAndModifyJSON            PROCEDURE(STRING pJsonString)
jsonFactory                     cJSONFactory
root                            &cJSON
item                            &cJSON
  CODE
  !parse json string, get root object
  root &= jsonFactory.Parse(pJsonString)
  IF root &= NULL
    !error
    MESSAGE('Syntax error near: '& jsonFactory.GetError() &'|at position '& jsonFactory.GetErrorPosition())
    RETURN
  END
  
  !find {"value": "Create"} item and change "Create" to "New"
  
  !first, find "menu" object
  item &= root.GetObjectItem('menu')
  IF NOT item &= NULL
    !then, find "popup" object
    item &= item.GetObjectItem('popup')
    IF NOT item &= NULL
      !then, find "menuitem" array of objects
      item &= item.GetObjectItem('menuitem')
      IF NOT item &= NULL
        !then, find 1st array element (object)
        item &= item.GetArrayItem(1)
        IF NOT item &= NULL
          !find "value": "Create" string
          item &= item.GetObjectItem('value')
          IF NOT item &= NULL
            !change string value
            item.SetStringValue('New')
          END
        END
      END
    END
  END
  
  !see the resulting json
!  MESSAGE(root.ToString(FALSE)) !unformatted outpur
  json::DebugInfo(root.ToString(TRUE)) !formatted outpur
  MESSAGE(root.ToString(TRUE)) !formatted outpur
  
  !dispose all cJSON objects at once
  root.Delete()
