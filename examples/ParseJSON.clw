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
    !display parse error
    MESSAGE('Syntax error near: '& jsonFactory.GetError() &'|at position '& jsonFactory.GetErrorPosition())
    RETURN
  END
  
  json::DebugInfo(root.ToString(TRUE)) !formatted outpur

  !find {"value": "Create"} item and change "Create" to "New"
  
  !find 1st element (object) in "menuitem" array
  item &= root.FindArrayItem('menuitem', 1)
  IF NOT item &= NULL
    !now item points to the object {"value": "Create", "onclick": "CreateNewDoc()"}
    !get "value" item
    item &= item.GetObjectItem('value')
    IF NOT item &= NULL
      !change item value from "Create" to "New"
      item.SetStringValue('New')
    END
  END
  
  !same code, no error checking
!  item &= root.FindArrayItem('menuitem', 1)
!  item &= item.GetObjectItem('value')
!  item.SetStringValue('New')
  
  !see the resulting json
!  MESSAGE(root.ToString(FALSE)) !unformatted outpur
  json::DebugInfo(root.ToString(TRUE)) !formatted outpur
  MESSAGE(root.ToString(TRUE)) !formatted outpur
  
  !dispose all cJSON objects at once
  root.Delete()
