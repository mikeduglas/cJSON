!parse json string with unicode values like "\u0036\u0044"
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    UnicodeTest()
  END

  CODE
  UnicodeTest()
  
UnicodeTest                   PROCEDURE()
jsonFactory                     cJSONFactory
root                            &cJSON
jsonstr                         STRING(1024), AUTO
  CODE
  !"\u0036\u0044" (UTF-16) equals "6D" (UTF-8 or ASCII)
  jsonstr = '{{"menu": {{"id": "File", "utf16": "\u0036\u0044", "value": "File", "popup": {{"menuitem": [{{"value": "New", "onclick": "CreateNewDoc()"}, {{"value": "Open", "onclick": "OpenDoc()"}, {{"value": "Close", "onclick": "CloseDoc()"}]}}}'
  
  root &= jsonFactory.Parse(jsonstr)
  IF root &= NULL
    !error
    MESSAGE('Syntax error near: '& jsonFactory.GetError() &'|at position '& jsonFactory.GetErrorPosition())
    RETURN
  END
  
  !display resulting json, look at "utf16" field value (must be "6D")
  MESSAGE(root.ToString())
  
  !dispose all cJSON objects at once
  root.Delete()
