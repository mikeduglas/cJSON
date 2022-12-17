!** cJSON for Clarion v1.34
!** 17.12.2022
!** mikeduglas@yandex.com
!** mikeduglas66@gmail.com


  MEMBER
  
  INCLUDE('cjson.inc'), ONCE

typPrintBuffer                GROUP, TYPE
printed                         &TStringBuilder
depth                           LONG  !current nesting depth (for formatted printing)
format                          BOOL  !is this print a formatted print
codePage                        LONG  !original code page to convert to utf 8; -1 - don't convert
                              END

typParseBuffer                GROUP, TYPE
content                         &STRING
len                             LONG
pos                             LONG  !1..len(clip(input))
depth                           LONG  !How deeply nested (in arrays/objects) is the input at the current offset.
codePage                        LONG  !code page to convert from utf 8; -1 - don't convert
                              END

typCJsonFieldRules            QUEUE(typCJsonFieldRule), TYPE
                              END

!jPath
typJsonItem                   GROUP, TYPE
item                            &cJSON
                              END
typJsonItems                  QUEUE(typJsonItem), TYPE.

typJPathConditions            GROUP, TYPE
itemName                        STRING(256)
filterExpr                      STRING(256)
                              END


  MAP
    MODULE('win api')
      winapi::memcpy(LONG lpDest,LONG lpSource,LONG nCount),LONG,PROC,NAME('_memcpy')
   
      winapi::MultiByteToWideChar(UNSIGNED Codepage, ULONG dwFlags, ULONG LpMultuByteStr, |
        LONG cbMultiByte, ULONG LpWideCharStr, LONG cchWideChar), RAW, ULONG, PASCAL, PROC, NAME('MultiByteToWideChar')

      winapi::WideCharToMultiByte(UNSIGNED Codepage, ULONG dwFlags, ULONG LpWideCharStr, LONG cchWideChar, |
        ULONG lpMultuByteStr, LONG cbMultiByte, ULONG LpDefalutChar, ULONG lpUsedDefalutChar), RAW, ULONG, PASCAL, PROC, NAME('WideCharToMultiByte')
 
      winapi::GetLastError(),lONG,PASCAL,NAME('GetLastError')
   
      winapi::CreateFile(*CSTRING,ULONG,ULONG,LONG,ULONG,ULONG,UNSIGNED=0),UNSIGNED,RAW,PASCAL,NAME('CreateFileA')
      winapi::CloseHandle(UNSIGNED),BOOL,PASCAL,PROC,NAME('CloseHandle')
      winapi::WriteFile(LONG, *STRING, LONG, *LONG, LONG),LONG,RAW,PASCAL,NAME('WriteFile')
      winapi::GetFileSize(HANDLE hFile, *LONG FileSizeHigh),LONG,RAW,PASCAL,NAME('GetFileSize')
      winapi::ReadFile(HANDLE hFile, LONG lpBuffer, LONG dwBytes, *LONG dwBytesRead, LONG lpOverlapped),BOOL,RAW,PASCAL,NAME('ReadFile')
    END

    INCLUDE('CWUTIL.inc'), ONCE
    INCLUDE('printf.inc'), ONCE

    !static functions
    suffix_object(*cJSON prev, *cJSON item), PRIVATE
    add_item_to_object(*cJSON object, *STRING str, *cJSON item, BOOL constant_key), BOOL, PROC, PRIVATE
    add_item_to_array(*cJSON array, *cJSON item), BOOL, PROC, PRIVATE
    replace_item_in_object(*cJSON object, *STRING str, *cJSON replacement, BOOL case_sensitive), BOOL, PROC, PRIVATE
    get_object_item(*cJSON object, *STRING name, BOOL case_sensitive), *cJSON, PRIVATE
    get_array_item(*cJSON array, LONG index), *cJSON, PRIVATE
    create_reference(*cJSON item), *cJSON, PRIVATE

    print_value(*cJSON item, *typPrintBuffer buffer), BOOL, PROC, PRIVATE
    print_number(*cJSON item, *typPrintBuffer buffer), BOOL, PRIVATE
    print_string(*cJSON item, *typPrintBuffer buffer), BOOL, PRIVATE
    print_string_ptr(*STRING input, *typPrintBuffer buffer), BOOL, PRIVATE
    print_array(*cJSON item, *typPrintBuffer buffer), BOOL, PRIVATE
    print_object(*cJSON item, *typPrintBuffer buffer), BOOL, PRIVATE

    parse_value(*cJSON item, *typParseBuffer buffer), BOOL, PRIVATE
    parse_number(*cJSON item, *typParseBuffer buffer), BOOL, PRIVATE
    parse_string(*cJSON item, *typParseBuffer buffer), BOOL, PRIVATE
    parse_array(*cJSON item, *typParseBuffer buffer), BOOL, PRIVATE
    parse_object(*cJSON item, *typParseBuffer buffer), BOOL, PRIVATE

    !parse 4 digit hexadecimal number
    parse_hex4(typParseBuffer buffer, LONG pos), UNSIGNED, PRIVATE
    !converts a UTF-16 literal to UTF-8. A literal can be one or two sequences of the form \uXXXX
    utf16_literal_to_utf8(*typParseBuffer buffer, LONG input_pos, LONG input_end, *DynStr output), BYTE, PRIVATE
    !skip the UTF-8 BOM (byte order mark) if it is at the beginning of a buffer
    skip_utf8_bom(*typParseBuffer buffer), PRIVATE
    !Utility to jump whitespace and cr/lf
    buffer_skip_whitespace(*typParseBuffer buffer), PRIVATE
  
    json::Compare_In_Module(*cJSON a, *cJSON b, BOOL case_sensitive), BOOL, PRIVATE

    CharToHex4(STRING pChar), STRING, PRIVATE
    RemoveFieldPrefix(*STRING fldName), PRIVATE
    FindRuleHelper(typCJsonFieldRule rule), *TCJsonRuleHelper, PRIVATE
    ParseFieldRules(STRING json, *typCJsonFieldRules rules), PRIVATE
    FindFieldRule(STRING fldName, *typCJsonFieldRules rules), PRIVATE
    ApplyFieldRule(STRING fldName, ? value, typCJsonFieldRule rule), ?, PRIVATE
    ProcessAutoField(STRING fldName, cJSON item, typCJsonFieldRule rule), PRIVATE
    IsFieldInGroup(*GROUP pGrp, STRING pFieldName), BOOL, PRIVATE
    IsAnyNullRef(? value), BOOL, PRIVATE

    json::BlobsToObject(*cJSON pItem, *FILE pFile, BOOL pNamesInLowerCase = TRUE, <STRING options>), PRIVATE
    json::ObjectToBlobs(*cJSON pItem, *FILE pFile, <STRING options>), PRIVATE

    AddItemReferenceToObject(cJSON pDst, cJSON pSrc, STRING pItemName), PRIVATE
  END

INT_MAX                       EQUATE(2147483647)
INT_MIN                       EQUATE(-2147483648)

!ASCII control codes
_Backspace_                   EQUATE('<08h>')     !\b
_Tab_                         EQUATE('<09h>')     !\t
_LF_                          EQUATE('<0Ah>')     !\n
_FF_                          EQUATE('<0Ch>')     !\f
_CR_                          EQUATE('<0Dh>')     !\r
_CRLF_                        EQUATE('<0Dh,0Ah>') !\r\n

!- json::LoadFile/json::SaveFile
OS_INVALID_HANDLE_VALUE       EQUATE(-1)
  

!!!region TCJsonRuleHelper
TCJsonRuleHelper.FindCB       PROCEDURE(STRING fldName, *typCJsonFieldRule rule)
  CODE
  !- stub

TCJsonRuleHelper.ApplyCB      PROCEDURE(STRING pFldName, *typCJsonFieldRule pRule, ? pValue)
  CODE
  !- stub
  RETURN pValue

TCJsonRuleHelper.AutoCB       PROCEDURE(STRING pFldName, cJSON pItem)
  CODE
  !- stub
!!!endregion

!!!region public functions
CharToHex4                    PROCEDURE(STRING pChar)
  CODE
  RETURN printf('00%X', VAL(pChar))
  
RemoveFieldPrefix             PROCEDURE(*STRING fldName)
first_colon_pos                 LONG, AUTO
  CODE
  first_colon_pos = INSTRING(':', fldName, 1, 1)
  IF first_colon_pos
    fldName = fldName[first_colon_pos + 1 : LEN(fldName)]
  END

ParseFieldRules               PROCEDURE(STRING options, *typCJsonFieldRules rules)
factory                         cJSONFactory
jOptions                        &cJSON
jOption                         &cJSON
jArray                          &cJSON
jDefaultOption                  &cJSON
defaultRule                     LIKE(typCJsonFieldRule), AUTO
i                               LONG, AUTO
  CODE
  FREE(rules)
  IF options
    jOptions &= factory.Parse(options)
    IF NOT jOptions &= NULL
      IF jOptions.IsArray()
        !- Array []
        jArray &= jOptions
      ELSIF jOptions.IsObject()
        !- Object {}, put it into an array
        jArray &= json::CreateArray()
        jArray.AddItemToArray(jOptions)
      ELSE
        !- Invalid json type
        json::DebugInfo('[ParseFieldRules] Unable to parse options.')
        jOptions.Delete()
        RETURN
      END
      
      !- find default rule (name='*')
      LOOP i=1 TO jArray.GetArraySize()
        jOption &= jArray.GetArrayItem(i)
        IF jOption.GetValue('name') = '*'
          jDefaultOption &= jOption
          jDefaultOption.ToGroup(defaultRule)
          BREAK
        END
      END
      
      !- default rule not found, so create it
      IF jDefaultOption &= NULL
        CLEAR(defaultRule)
        defaultRule.name = '*'
        jDefaultOption &= json::CreateObject(defaultRule)
        jArray.AddItemToArray(jDefaultOption)
      END
      
      !- copy default rules if field rules are missing
      LOOP i=1 TO jArray.GetArraySize()
        jOption &= jArray.GetArrayItem(i)

        IF NOT jOption &= jDefaultOption
          !- these rules are inherited:
          !JsonName
          !EmptyString
          !IgnoreFalse
          !IgnoreZero
          !IgnoreEmptyArray
          !IgnoreEmptyObject
          !Format
          !FormatLeft
          !Deformat
          !Ignore
          !IsStringRef
          !IsBool
          !IsRaw
          !IsBase64
          !IsFile
          !Auto
          jOption.AddItemReferenceToObject(jDefaultOption, 'JsonName')
          jOption.AddItemReferenceToObject(jDefaultOption, 'EmptyString')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IgnoreFalse')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IgnoreZero')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IgnoreEmptyArray')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IgnoreEmptyObject')
          jOption.AddItemReferenceToObject(jDefaultOption, 'Format')
          jOption.AddItemReferenceToObject(jDefaultOption, 'FormatLeft')
          jOption.AddItemReferenceToObject(jDefaultOption, 'Deformat')
          jOption.AddItemReferenceToObject(jDefaultOption, 'Ignore')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IsStringRef')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IsBool')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IsRaw')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IsBase64')
          jOption.AddItemReferenceToObject(jDefaultOption, 'IsFile')
          jOption.AddItemReferenceToObject(jDefaultOption, 'Auto')
          
          !- Propagate RuleHelper to field rule to allow call ApplyCB from ApplyFieldRule.
          jOption.AddItemReferenceToObject(jDefaultOption, 'RuleHelper')
        END
      END
              
      !- load the rules into queue
      jArray.ToQueue(rules)

      jArray.Delete()
    ELSE
      json::DebugInfo('[ParseFieldRules] Syntax error near "'& factory.GetError() &'" at position '& factory.GetErrorPosition())
    END
  END
  
FindRuleHelper                PROCEDURE(typCJsonFieldRule rule)
rh                              &TCJsonRuleHelper, AUTO
  CODE
  IF rule.RuleHelper
    rh &= (rule.RuleHelper)
    RETURN rh
  END
  RETURN NULL
  
FindFieldRule                 PROCEDURE(STRING fldName, *typCJsonFieldRules rules)
i                               LONG, AUTO
rh                              &TCJsonRuleHelper
  CODE
  !- search for rule helper
  rh &= FindRuleHelper(rules)

  !- search for field rule
  LOOP i = 1 TO RECORDS(rules)
    GET(rules, i)
    IF LOWER(rules.Name) = LOWER(fldName)
      !- found field rule
      IF NOT rh &= NULL
        !- callback
        rh.FindCB(fldName, rules)
      END
      RETURN
    END
  END
  
  !- if a generic rule exists, apply it
  rules.Name = '*'
  GET(rules, 'Name')
  IF NOT ERRORCODE()
    IF NOT rh &= NULL
      !- callback
      rh.FindCB(fldName, rules)
    END
    RETURN
  END
  
  !- no rule found, use default behavior
  CLEAR(rules)
  
ApplyFieldRule                PROCEDURE(STRING fldName, ? value, typCJsonFieldRule rule)
fldValue                        ANY
vGrp                            GROUP
adr                               LONG
len                               LONG
                                END
sValue                          STRING(8), OVER(vGrp)
sRefValue                       &STRING, AUTO
rh                              &TCJsonRuleHelper
sFileContent                    &STRING, AUTO
  CODE
  !- search for rule helper
  rh &= FindRuleHelper(rule)

  IF rule.IsStringRef
    !- Passed value is &STRING.
    !- Assigning to sValue we get an address of underlying string and its length.
    sValue = value
    !- Getting a reference to underlying string.
    sRefValue &= (vGrp.adr) &':'& vGrp.len
    !- Get actual string value.
    fldValue = sRefValue
  ELSE
    fldValue = value
  END
  
  IF NOT rh &= NULL
    !- callback
    fldValue = rh.ApplyCB(fldName, rule, fldValue)
  END
  
  IF rule.IsFile
    !- load file content
    sFileContent &= json::LoadFile(fldValue)
    fldValue = sFileContent
    DISPOSE(sFileContent)
  END
  
  IF rule.Format
    RETURN FORMAT(fldValue, rule.Format)
  ELSIF rule.FormatLeft
    RETURN LEFT(FORMAT(fldValue, rule.FormatLeft))
  ELSIF rule.Deformat
    RETURN DEFORMAT(fldValue, rule.Deformat)
  ELSE
    RETURN fldValue
  END
  
ProcessAutoField              PROCEDURE(STRING fldName, cJSON item, typCJsonFieldRule rule)
rh                              &TCJsonRuleHelper
  CODE
  !- search for rule helper
  rh &= FindRuleHelper(rule)
  IF NOT rh &= NULL
    !- callback
    rh.AutoCB(fldName, item)
  END
  
IsFieldInGroup                PROCEDURE(*GROUP grp, STRING pFieldName)
i                               LONG, AUTO
fldRef                          ANY
  CODE
  LOOP i = 1 TO 99999
    fldRef &= WHAT(grp, i)
    IF fldRef &= NULL
      !end of group
      BREAK
    END
    
    IF WHO(grp, i) = pFieldName
      RETURN TRUE
    END
  END
  
  RETURN FALSE
  
IsAnyNullRef                  PROCEDURE(? value)
vGrp                            GROUP
adr                               LONG
                                END
sValue                          STRING(4), OVER(vGrp)
  CODE
  sValue = value
  RETURN CHOOSE(vGrp.adr=0)

AddItemReferenceToObject      PROCEDURE(cJSON pDst, cJSON pSrc, STRING pItemName)
  CODE
  IF pSrc.HasItem(pItemName) AND NOT pDst.HasItem(pItemName)
    !- src has the item "pItemName", dst hasn't.
    pDst.AddItemReferenceToObject(pItemName, pSrc.GetObjectItem(pItemName))
  END

json::DebugInfo               PROCEDURE(STRING pMsg)
  CODE
  printd('[cJSON] %s', pMsg)
  
json::Minify                  PROCEDURE(*STRING pJson)
into                            &STRING
len                             LONG, AUTO
srcpos                          LONG, AUTO
dstpos                          LONG, AUTO
  CODE
  into &= pJson
  IF into &= NULL OR into = ''
    RETURN
  END
  
  len = LEN(CLIP(pJson))

  srcpos = 1
  dstpos = 1
  LOOP WHILE srcpos <= len
    IF pJson[srcpos] = ' ' OR pJson[srcpos] = _Tab_ OR pJson[srcpos] = _CR_ OR pJson[srcpos] = _LF_
      !Whitespace characters.
      srcpos += 1
    ELSIF srcpos < len AND pJson[srcpos] = '/' AND pJson[srcpos + 1] = '/'
      !double-slash comments, to end of line.
      LOOP WHILE srcpos <= len AND pJson[srcpos] <> _LF_
        srcpos += 1
      END
    ELSIF srcpos < len AND pJson[srcpos] = '/' AND pJson[srcpos + 1] = '*'
      ! multiline comments.
      LOOP WHILE srcpos <= len AND NOT (pJson[srcpos] = '*' AND pJson[srcpos + 1] = '/')
        srcpos += 1
      END
      srcpos += 2
    ELSIF pJson[srcpos] = '"'
      !string literals, which are " sensitive.
      into[dstpos] = pJson[srcpos]
      srcpos += 1; dstpos += 1
      LOOP WHILE srcpos <= len AND pJson[srcpos] <> '"'
        IF pJson[srcpos] = '\'
          into[dstpos] = pJson[srcpos]
          srcpos += 1; dstpos += 1
        END
        into[dstpos] = pJson[srcpos]
        srcpos += 1; dstpos += 1
      END
      into[dstpos] = pJson[srcpos]
      srcpos += 1; dstpos += 1
    ELSE
      !All other characters.
      into[dstpos] = pJson[srcpos]
      srcpos += 1; dstpos += 1
    END
  END
  
  !clear string tail
  LOOP WHILE dstpos <= len
    into[dstpos] = ' '
    dstpos += 1
  END

json::Compare                 PROCEDURE(*cJSON a, *cJSON b, BOOL case_sensitive)
  CODE
  RETURN json::Compare_In_Module(a, b, case_sensitive)

json::Compare_In_Module       PROCEDURE(*cJSON a, *cJSON b, BOOL case_sensitive)
a_element                       &cJSON
b_element                       &cJSON
  CODE
  IF (a &= NULL) OR (b &= NULL) OR (BAND(a.GetType(), 0FFh) <> BAND(b.GetType(), 0FFh)) OR a.IsInvalid()
    RETURN FALSE
  END
  
  !check if type is valid
  CASE BAND(a.GetType(), 0FFh)
  OF   cJSON_False
  OROF cJSON_True
  OROF cJSON_NULL
  OROF cJSON_Number
  OROF cJSON_String
  OROF cJSON_Raw
  OROF cJSON_Array
  OROF cJSON_Object
    !nop
  ELSE
    RETURN FALSE
  END
  
  !identical objects are equal
  IF a &= b
    RETURN TRUE
  END

  CASE BAND(a.GetType(), 0FFh)
  OF   cJSON_False
  OROF cJSON_True
  OROF cJSON_NULL
    !in these cases and equal type is enough
    RETURN TRUE
    
  OF cJSON_Number
    IF a.valuedouble = b.valuedouble
      RETURN TRUE
    END
    RETURN FALSE
    
  OF cJSON_String
  OROF cJSON_Raw
    IF a.valuestring &= NULL OR b.valuestring &= NULL
      RETURN FALSE
    END
    IF a.valuestring = b.valuestring
      RETURN TRUE
    END
    RETURN FALSE
    
  OF cJSON_Array
    a_element &= a.child
    b_element &= b.child
    
    LOOP WHILE (NOT a_element &= NULL) AND (NOT b_element &= NULL)
      IF NOT json::Compare(a_element, b_element, case_sensitive)
        RETURN FALSE
      END
      a_element &= a_element.next
      b_element &= b_element.next
    END
    
    !one of the arrays is longer than the other
    IF NOT a_element &= b_element
      RETURN FALSE
    END
    RETURN TRUE
    
  OF cJSON_Object
    a_element &= a.child
    b_element &= NULL
    LOOP WHILE NOT a_element &= NULL
      !TODO This has O(n^2) runtime, which is horrible!
      b_element &= get_object_item(b, a_element.name, case_sensitive)
      IF b_element &= NULL
        RETURN FALSE
      END
      
      IF NOT json::Compare(a_element, b_element, case_sensitive)
        RETURN FALSE
      END
      
      a_element &= a_element.next
    END
    
    !doing this twice, once on a and b to prevent true comparison if a subset of b
    !TODO: Do this the proper way, this is just a fix for now
    b_element &= b.child
    LOOP WHILE NOT b_element &= NULL
      a_element &= get_object_item(a, b_element.name, case_sensitive)
      IF a_element &= NULL
        RETURN FALSE
      END

      IF NOT json::Compare(b_element, a_element, case_sensitive)
        RETURN FALSE
      END

      b_element &= b_element.next
    END
    
    RETURN TRUE
    
  ELSE
    RETURN FALSE
  END
!!!endregion
  
!!!region private functions
suffix_object                 PROCEDURE(*cJSON prev, *cJSON item)
  CODE
  prev.next &= item
  item.prev &= prev
  
add_item_to_object            PROCEDURE(*cJSON object, *STRING str, *cJSON item, BOOL constant_key)
new_key                         &STRING
new_type                        cJSON_Type(cJSON_Invalid)
  CODE
  IF (object &= NULL) OR (NOT str) OR (item &= NULL)
    RETURN FALSE
  END
  
  IF constant_key
    new_key &= str
    new_type = BOR(item.type, cJSON_StringIsConst)
  ELSE
    new_key &= NEW STRING(LEN(CLIP(str)))
    new_key = CLIP(str)
    new_type = BAND(item.type, cJSON_StringIsNotConst)
  END
  
  IF (NOT BAND(item.type, cJSON_StringIsConst)) AND (NOT item.name &= NULL)
    DISPOSE(item.name)
    item.name &= NULL
  END

  item.name &= new_key
  item.type = new_type

  RETURN add_item_to_array(object, item)
    
add_item_to_array             PROCEDURE(*cJSON array, *cJSON item)
child                           &cJSON
  CODE
  IF item &= NULL OR array &= NULL
    RETURN FALSE
  END
  
  child &= array.child

  IF child &= NULL
    !list is empty, start new one
    array.child &= item
  ELSE
    !append to the end
    LOOP WHILE NOT child.next &= NULL
      child &= child.next
    END
    suffix_object(child, item)
  END
  
  RETURN TRUE

replace_item_in_object        PROCEDURE(*cJSON object, *STRING str, *cJSON replacement, BOOL case_sensitive)
  CODE
  IF replacement &= NULL !OR str &= NULL
    RETURN FALSE
  END
  
  !replace the name in the replacement
  IF (NOT BAND(replacement.type, cJSON_StringIsConst)) AND (NOT replacement.name &= NULL)
    DISPOSE(replacement.name)
    replacement.name &= NULL
  END

  replacement.name &= NEW STRING(LEN(str))
  replacement.name = str
  replacement.type = BAND(replacement.type, cJSON_StringIsNotConst)

  object.ReplaceItemViaPointer(get_object_item(object, str, case_sensitive), replacement)
  RETURN TRUE
  
get_object_item               PROCEDURE(*cJSON object, *STRING name, BOOL case_sensitive)
current_element                 &cJSON
  CODE
  IF object &= NULL !OR name &= NULL
    RETURN NULL
  END
  
  current_element &= object.child
  IF case_sensitive
    LOOP WHILE (NOT current_element &= NULL) AND name <> current_element.name
      current_element &= current_element.next
    END
  ELSE
    LOOP WHILE (NOT current_element &= NULL) AND LOWER(name) <> LOWER(current_element.name)
      current_element &= current_element.next
    END
  END

  RETURN current_element

get_array_item                PROCEDURE(*cJSON array, LONG index)
current_child                   &cJSON
  CODE
  IF array &= NULL
    RETURN NULL
  END
  
  current_child &= array.child
  LOOP WHILE (NOT current_child &= NULL) AND (index > 1)
    index -= 1
    current_child &= current_child.next
  END

  RETURN current_child

create_reference              PROCEDURE(*cJSON item)
reference                       &cJSON
  CODE
  IF item &= NULL
    RETURN NULL
  END
  
  reference &= NEW cJSON
!  reference :=: item  !doesn't work for classes
  winapi::memcpy(ADDRESS(reference), ADDRESS(item), SIZE(cJSON))
  reference.prev &= NULL
  reference.next &= NULL
  reference.name &= NULL
  reference.type = BOR(reference.type, cJSON_IsReference)
  
  RETURN reference

print_value                   PROCEDURE(*cJSON item, *typPrintBuffer buffer)
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END

  CASE BAND(item.type, 0FFh)
  OF cJSON_NULL
    buffer.printed.Cat('null')
    RETURN TRUE
  OF cJSON_False
    buffer.printed.Cat('false')
    RETURN TRUE
  OF cJSON_True
    buffer.printed.Cat('true')
    RETURN TRUE
  OF cJSON_Number
    RETURN print_number(item, buffer)
  OF cJSON_Raw
    IF item.valuestring &= NULL
      RETURN FALSE
    END
    buffer.printed.Cat(item.valuestring)
    RETURN TRUE
  OF cJSON_String
    RETURN print_string(item, buffer)
  OF cJSON_Array
    RETURN print_array(item, buffer)
  OF cJSON_Object
    RETURN print_object(item, buffer)
  END
  
  RETURN FALSE

!Render the number nicely from the given item into a string.
print_number                  PROCEDURE(*cJSON item, *typPrintBuffer buffer)
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END

  buffer.printed.Cat(item.valuedouble)
  RETURN TRUE

!Render the cstring provided to an escaped version that can be printed.
print_string_ptr              PROCEDURE(*STRING input, *typPrintBuffer buffer)
escape_characters               LONG, AUTO  !numbers of additional characters needed for escaping
cIndex                          LONG, AUTO
oIndex                          LONG, AUTO
output                          &STRING
  CODE
  IF buffer.printed &= NULL
    RETURN FALSE
  END

  IF NOT input
    buffer.printed.Cat('""')
    RETURN TRUE
  END
  
  escape_characters = 0
  LOOP cIndex = 1 TO LEN(input)
    CASE input[cIndex]
    OF   '"'
    OROF '\'
    OROF _Backspace_  !\b
    OROF _FF_         !\f
    OROF _LF_         !\n
    OROF _CR_         !\r
    OROF _Tab_        !\t
      !one character escape sequence
      escape_characters += 1
      
    ELSE
      IF VAL(input[cIndex]) < 32
        !UTF-16 escape sequence uXXXX
        escape_characters += 5
      END
    END
  END

  !no characters have to be escaped
  IF escape_characters = 0
    IF buffer.codePage = -1
      buffer.printed.Cat('"'& input &'"')
    ELSE
      !convert to utf8
      buffer.printed.Cat('"'& json::ToUtf8(input, buffer.codePage) &'"')
    END
    
    RETURN TRUE
  END
  
  output &= NEW STRING(SIZE(input) + escape_characters)
  
  oIndex = 0
  LOOP cIndex = 1 TO SIZE(input)
    oIndex += 1
    IF VAL(input[cIndex]) > 31 AND input[cIndex] <> '"' AND input[cIndex] <> '\'
      !normal character, copy
      output[oIndex] = input[cIndex]
    ELSE
      !character needs to be escaped
      output[oIndex] = '\'
      oIndex += 1
      CASE input[cIndex]
      OF '\'
        output[oIndex] =  '\'
      OF '"'
        output[oIndex] = '"'
      OF _Backspace_          !\b
        output[oIndex] = 'b'
      OF _FF_                 !\f
        output[oIndex] = 'f'
      OF _LF_                 !\n
        output[oIndex] = 'n'
      OF _CR_                 !\r
        output[oIndex] = 'r'
      OF _Tab_                !\t
        output[oIndex] = 't'
      ELSE
        !escape and print as unicode codepoint
        output[oIndex : oIndex + 4] = 'u'& CharToHex4(input[cIndex])
        oIndex += 4
      END
    END
  END
  
  IF buffer.codePage = -1
    buffer.printed.Cat('"'& output &'"')
  ELSE
    !convert to utf8
    buffer.printed.Cat('"'& json::ToUtf8(output, buffer.codePage) &'"')
  END
  
  DISPOSE(output)
  
  RETURN TRUE

print_string                  PROCEDURE(*cJSON item, *typPrintBuffer buffer)
  CODE
  RETURN print_string_ptr(item.valuestring, buffer)
  
print_array                   PROCEDURE(*cJSON item, *typPrintBuffer buffer)
current_element                 &cJSON
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END
  
  !Compose the output array.
  !opening square bracket
  buffer.printed.Cat('[')
  buffer.depth += 1
  
  current_element &= item.child
  LOOP WHILE NOT current_element &= NULL
    IF NOT print_value(current_element, buffer)
      RETURN FALSE
    END
    
    IF NOT current_element.next &= NULL
      buffer.printed.Cat(', ')
      IF buffer.format
        buffer.printed.Cat(' ')
      END
    END
    
    current_element &= current_element.next
  END
  
  !closing square bracket
  buffer.printed.Cat(']')
  buffer.depth -= 1

  RETURN TRUE

print_object                  PROCEDURE(*cJSON item, *typPrintBuffer buffer)
current_item                    &cJSON
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END
  
  !Compose the output.
  !opening curly bracket
  buffer.printed.Cat('{{')
  buffer.depth += 1
  IF buffer.format
    buffer.printed.Cat(_CRLF_)
  END
  
  current_item &= item.child
  LOOP WHILE NOT current_item &= NULL
    IF buffer.format
      LOOP buffer.depth TIMES
        buffer.printed.Cat(_Tab_)
      END
    END
    
    !print key
    IF NOT print_string_ptr(current_item.name, buffer)
      RETURN FALSE
    END
    
    buffer.printed.Cat(':')
    IF buffer.format
      buffer.printed.Cat(_Tab_)
    END

    !print value
    IF NOT print_value(current_item, buffer)
      RETURN FALSE
    END

    !print comma if not last
    IF NOT current_item.next &= NULL
      buffer.printed.Cat(',')
    END
    
    IF buffer.format
      buffer.printed.Cat(_CRLF_)
    END
  
    current_item &= current_item.next
  END
  
  IF buffer.format
    LOOP buffer.depth - 1 TIMES
      buffer.printed.Cat(_Tab_)
    END
  END

  buffer.printed.Cat('}')
  buffer.depth -= 1
  RETURN TRUE

!Parser core - when encountering text, process appropriately.
parse_value                   PROCEDURE(*cJSON item, *typParseBuffer buffer)
start_char                      STRING(1), AUTO
  CODE
  IF buffer.content &= NULL OR buffer.content = ''
    RETURN FALSE    !no input
  END
  
  start_char = SUB(buffer.content, buffer.pos, 1)
  
  !parse the different types of values
  !null
  IF SUB(buffer.content, buffer.pos, 4) = 'null'
    item.type = cJSON_Null
    buffer.pos += 4
    RETURN TRUE
  END
  !false
  IF SUB(buffer.content, buffer.pos, 5) = 'false'
    item.type = cJSON_False
    item.valueint = 0
    buffer.pos += 5
    RETURN TRUE
  END
  !true
  IF SUB(buffer.content, buffer.pos, 4) = 'true'
    item.type = cJSON_True
    item.valueint = 1
    buffer.pos += 4
    RETURN TRUE
  END
  !string
  IF start_char = '"'
    RETURN parse_string(item, buffer)
  END
  !number
  IF start_char = '-' OR INRANGE(VAL(start_char), VAL('0'), VAL('9'))
    RETURN parse_number(item, buffer)
  END
  !array
  IF start_char = '['
    RETURN parse_array(item, buffer)
  END
  !object
  IF start_char = '{{'
    RETURN parse_object(item, buffer)
  END
  
  RETURN FALSE

!Parse the input text to generate a number, and populate the result into item.
parse_number                  PROCEDURE(*cJSON item, *typParseBuffer buffer)
number                          REAL(0)
number_c_string                 STRING(64)
decimal_point                   STRING(1), AUTO
i                               LONG, AUTO
digitPos                        LONG AUTO
  CODE
  IF item &= NULL
    RETURN FALSE
  END
  
  !copy the number into a temporary buffer
!  decimal_point = get_decimal_point()
  decimal_point = '.'
  digitPos = 0
  LOOP i = buffer.pos TO buffer.len
    digitPos += 1
    IF digitPos > LEN(number_c_string)
      BREAK
    END
    
    CASE buffer.content[i]
    OF '0' TO '9'
    OROF '+'
    OROF '-'
    OROF 'e'
    OROF 'E'
      number_c_string[digitPos] = buffer.content[i]
    OF '.'
      number_c_string[digitPos] = decimal_point
    ELSE
      i -= 1
      BREAK !end of loop
    END
  END
  
  IF NOT NUMERIC(number_c_string)
    RETURN FALSE
  END
  
  item.valuedouble = number_c_string

  IF number_c_string + 0 >= INT_MAX
    item.valueint = INT_MAX
  ELSIF number_c_string + 0 <= INT_MIN
    item.valueint = INT_MIN
  ELSE
    item.valueint = number_c_string
  END

  item.type = cJSON_Number
  
  buffer.pos = i + 1

  RETURN TRUE

!Parse the input text into an unescaped cinput, and populate item.
parse_string                  PROCEDURE(*cJSON item, *typParseBuffer buffer)
cur_char                        STRING(1)
next_char                       STRING(1)
skipped_bytes                   LONG(0)
output                          DynStr
decoded                         DynStr
input_pos                       LONG, AUTO
input_end                       LONG, AUTO
sequence_length                 LONG, AUTO
  CODE
  input_pos = buffer.pos + 1
  input_end = buffer.pos + 1

  !not a string
  IF SUB(buffer.content, buffer.pos, 1) <> '"'
    DO Fail
  END

  LOOP WHILE input_end <= buffer.len
    cur_char = SUB(buffer.content, input_end, 1)
    IF cur_char = '"'
      BREAK
    END
    
    !is escape sequence
    IF cur_char = '\'
      skipped_bytes += 1
      input_end += 1
    END

    input_end += 1
  END
  
  IF cur_char <> '"'
    !string ended unexpectedly
    DO Fail
  END

  
  !buffer.pos points to opening "
  !input_pos points to first char after opening "
  !input_end points to closing "
  
  !loop through the string literal
  LOOP WHILE input_pos < input_end
    cur_char = SUB(buffer.content, input_pos, 1)
    IF cur_char <> '\'
      output.Cat(cur_char)
      input_pos += 1
    ELSE
      sequence_length = 2
      
      next_char = SUB(buffer.content, input_pos + 1, 1)
      CASE next_char
      OF 'b'
        output.Cat(_Backspace_)
      OF 'f'
        output.Cat(_FF_)
      OF 'n'
        output.Cat(_LF_)
      OF 'r'
        output.Cat(_CR_)
      OF 't'
        output.Cat(_Tab_)
      OF '"' OROF '\' OROF '/'
        output.Cat(next_char)
      OF 'u'
        !UTF-16 literal
        sequence_length = utf16_literal_to_utf8(buffer, input_pos, input_end, output)
        IF sequence_length = 0
          !failed to convert UTF16-literal to UTF-8
          DO Fail
        END
      ELSE
        DO Fail
      END
  
      input_pos += sequence_length
    END
  END
  
  item.type = cJSON_String
  
  IF buffer.codePage = -1
    item.valuestring &= NEW STRING(output.StrLen())
    item.valuestring = output.Str()
  ELSE
    !- convert utf8 to another code page
    decoded.Cat(json::FromUtf8(output.Str(), buffer.codePage))
    item.valuestring &= NEW STRING(decoded.StrLen())
    item.valuestring = decoded.Str()
  END
  
  buffer.pos = input_end + 1
  RETURN TRUE
  
Fail                          ROUTINE
  buffer.pos = input_pos
  RETURN FALSE
  
!Build an array from input text.
parse_array                   PROCEDURE(*cJSON item, *typParseBuffer buffer)
head                            &cJSON  !head of the linked list
current_item                    &cJSON
new_item                        &cJSON
  CODE
  IF buffer.content[buffer.pos] <> '['
    !not an array
    DO Fail
  END
  
  buffer.pos += 1
  
  !skip whitespaces
  buffer_skip_whitespace(buffer)

  IF buffer.pos <= buffer.len AND buffer.content[buffer.pos] = ']'
    !empty array
    DO Success
  END
  
  !check if we skipped to the end of the buffer
  IF buffer.pos > buffer.len
    buffer.pos -= 1
    DO Fail
  END
  
  !step back to character in front of the first element
  buffer.pos -= 1

  !loop through the comma separated array elements
  LOOP
    !allocate next item
    new_item &= NEW cJSON
    !attach next item to list
    IF head &= NULL
      !start the linked list
      current_item &= new_item
      head &= new_item
    ELSE
      !add to the end and advance
      current_item.next &= new_item
      new_item.prev &= current_item
      current_item &= new_item
    END
    
    !parse next value
    buffer.pos += 1
    buffer_skip_whitespace(buffer)
    IF NOT parse_value(current_item, buffer)
      DO Fail !failed to parse value
    END
    
    buffer_skip_whitespace(buffer)

  WHILE buffer.pos < buffer.len AND buffer.content[buffer.pos] = ','
  
  IF buffer.pos > buffer.len OR buffer.content[buffer.pos] <> ']'
    DO Fail   !expected end of array
  END
  
  DO Success

Success                       ROUTINE
  item.type = cJSON_Array
  item.child &= head
  buffer.pos += 1
  RETURN TRUE

Fail                          ROUTINE
  IF NOT head &= NULL
    head.Delete()
  END
  RETURN FALSE
  
!Build an object from the text.
parse_object                  PROCEDURE(*cJSON item, *typParseBuffer buffer)
head                            &cJSON  !head of the linked list
current_item                    &cJSON
new_item                        &cJSON
  CODE
  IF buffer.content[buffer.pos] <> '{{'
    !not an object
    DO Fail
  END
  
  buffer.pos += 1
  
  !skip whitespaces
  buffer_skip_whitespace(buffer)

  IF buffer.content[buffer.pos] = '}'
    !empty object
    DO Success
  END
  
  !check if we skipped to the end of the buffer
  IF buffer.pos > buffer.len
    buffer.pos -= 1
    DO Fail
  END
  
  !step back to character in front of the first element
  buffer.pos -= 1

  !loop through the comma separated array elements
  LOOP
    !allocate next item
    new_item &= NEW cJSON
    !attach next item to list
    IF head &= NULL
      !start the linked list
      current_item &= new_item
      head &= new_item
    ELSE
      !add to the end and advance
      current_item.next &= new_item
      new_item.prev &= current_item
      current_item &= new_item
    END
    
    !parse the name of the child
    buffer.pos += 1
    buffer_skip_whitespace(buffer)
    IF NOT parse_string(current_item, buffer)
      DO Fail !failed to parse name
    END
    buffer_skip_whitespace(buffer)

    !swap valuestring and string, because we parsed the name
    current_item.name &= current_item.valuestring
    current_item.valuestring &= NULL
    
    IF buffer.pos > buffer.len OR buffer.content[buffer.pos] <> ':'
      DO Fail   !invalid object
    END

    !parse the value
    buffer.pos += 1
    buffer_skip_whitespace(buffer)
    IF NOT parse_value(current_item, buffer)
      DO Fail !failed to parse value
    END
    
    buffer_skip_whitespace(buffer)

  WHILE buffer.pos <= buffer.len AND buffer.content[buffer.pos] = ','
  
  IF buffer.pos > buffer.len OR buffer.content[buffer.pos] <> '}'
    DO Fail   !expected end of object
  END
  
  DO Success

Success                       ROUTINE
  item.type = cJSON_Object
  item.child &= head
  buffer.pos += 1
  RETURN TRUE

Fail                          ROUTINE
  IF NOT head &= NULL
    head.Delete()
  END
  RETURN FALSE

parse_hex4                    PROCEDURE(*typParseBuffer buffer, LONG pos)
h                               UNSIGNED(0)
i                               LONG, AUTO
char                            STRING(1), AUTO
  CODE
  LOOP i = 1 TO 4
    !parse digit
    char = SUB(buffer.content, pos + i - 1, 1)
    IF INRANGE(VAL(char), VAL('0'), VAL('9'))
      h += VAL(char) - VAL('0')
    ELSIF INRANGE(VAL(char), VAL('A'), VAL('F'))
      h += 10 + VAL(char) - VAL('A')
    ELSIF INRANGE(VAL(char), VAL('a'), VAL('f'))
      h += 10 + VAL(char) - VAL('a')
    ELSE
      !invalid
      RETURN 0
    END
    
    IF i < 4
      !shift left to make place for the next nibble
      h = BSHIFT(h, 4)
    END
  END
  
  RETURN h
  
utf16_literal_to_utf8         PROCEDURE(*typParseBuffer buffer, LONG input_pos, LONG input_end, *DynStr output)
codepoint                       DECIMAL(10, 0)  !uint64
first_sequence                  LONG, AUTO
second_sequence                 LONG, AUTO
sequence_length                 BYTE(0)
first_code                      LONG, AUTO
second_code                     LONG, AUTO
utf8_length                     BYTE(0)
first_byte_mark                 BYTE(0)
utf8_position                   LONG, AUTO
tempstr                         STRING(4)
  CODE
  first_sequence = input_pos
  
  IF input_end - first_sequence + 1 < 6
    !input ends unexpectedly
    json::DebugInfo('input ends unexpectedly')
    RETURN 0
  END
  
  !get the first utf16 sequence
  first_code = parse_hex4(buffer, first_sequence + 2)

  !check that the code is valid
  IF first_code >= 0DC00h AND first_code <= 0DFFFh
    json::DebugInfo('the code is invalid')
    RETURN 0
  END

  !UTF16 surrogate pair
  IF first_code >= 0D800h AND first_code <= 0DBFFh
    second_sequence = first_sequence + 6
    second_code = 0
    sequence_length = 12  ! \uXXXX\uXXXX
      
    IF input_end - second_sequence < 6
      !input ends unexpectedly
      json::DebugInfo('input ends unexpectedly #2')
      RETURN 0
    END

    IF buffer.content[second_sequence] <> '\' OR buffer.content[second_sequence + 1] <> 'u'
      !missing second half of the surrogate pair
      json::DebugInfo('missing second half of the surrogate pair')
      RETURN 0
    END
    
    !get the second utf16 sequence
    second_code = parse_hex4(buffer, second_sequence + 2)
    !check that the code is valid
    IF second_code < 0DC00h OR second_code > 0DFFFh
      !invalid second half of the surrogate pair
      json::DebugInfo('invalid second half of the surrogate pair')
      RETURN 0
    END
    
    !calculate the unicode codepoint from the surrogate pair
    codepoint = 010000h + BOR(BSHIFT(BAND(first_code, 03FFh), 10), BAND(second_code, 03FFh))
  ELSE
    sequence_length = 6 ! \uXXXX
    codepoint = first_code
  END
  
  !encode as UTF-8
  !takes at maximum 4 bytes to encode:
  !11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
  IF codepoint < 080h
    !normal ascii, encoding 0xxxxxxx
    utf8_length = 1
  ELSIF codepoint < 0800h
    !two bytes, encoding 110xxxxx 10xxxxxx
    utf8_length = 2
    first_byte_mark = 0C0h  ! 11000000
  ELSIF codepoint < 010000h
    !three bytes, encoding 1110xxxx 10xxxxxx 10xxxxxx
    utf8_length = 3
    first_byte_mark = 0E0h  ! 11100000
  ELSIF codepoint < 010FFFFh
    !four bytes, encoding 1110xxxx 10xxxxxx 10xxxxxx 10xxxxxx
    utf8_length = 4
    first_byte_mark = 0F0h  ! 11110000
  ELSE
    !invalid unicode codepoint
    json::DebugInfo('invalid unicode codepoint')
    RETURN 0
  END

  !encode as utf8
  LOOP utf8_position = utf8_length TO 2 BY -1
    !10xxxxxx
    tempstr[utf8_position] = CHR(BAND(BOR(codepoint, 080h), 0BFh))
    codepoint = BSHIFT(codepoint, -6)
  END

  !encode first byte
  IF utf8_length > 1
    tempstr[1] = CHR(BAND(BOR(codepoint, first_byte_mark), 0FFh))
  ELSE
    tempstr[1] = CHR(BAND(codepoint, 07Fh))
  END

  output.Cat(CLIP(tempstr))
  RETURN sequence_length

skip_utf8_bom                 PROCEDURE(*typParseBuffer buffer)
  CODE
  IF buffer.pos <> 1 OR buffer.len < 3
    RETURN
  END
  
  IF buffer.content[1 : 3] = '<0EFh,0BBh,0BFh>'
    buffer.pos += 3
  END

buffer_skip_whitespace        PROCEDURE(*typParseBuffer buffer)
i                               LONG, AUTO
  CODE
  LOOP i = buffer.pos TO buffer.len
    IF VAL(buffer.content[i]) > 32
      BREAK
    END
    
    buffer.pos += 1
  END
  IF buffer.pos > buffer.len
    buffer.pos -= 1
  END

json::ConvertEncoding         PROCEDURE(STRING pInput, UNSIGNED pInputCodepage, UNSIGNED pOutputCodepage)
szInput                         CSTRING(LEN(pInput) + 1)
UnicodeText                     CSTRING(LEN(pInput)*2+2)
DecodedText                     CSTRING(LEN(pInput)*2+2)
Len                             LONG, AUTO
CP_UTF16                        EQUATE(-1)
  CODE
  IF NOT pInput
    RETURN ''
  END
  
  IF pInputCodepage <> CP_UTF16
    szInput = pInput
    !- get length of UnicodeText in characters
    Len = winapi::MultiByteToWideChar(pInputCodePage, 0, ADDRESS(szInput), -1, 0, 0)
    IF Len = 0
      json::DebugInfo('MultiByteToWideChar failed, error '& winapi::GetLastError())
      RETURN ''
    END
    !- get UnicodeText terminated by <0,0>
    winapi::MultiByteToWideChar(pInputCodePage, 0, ADDRESS(szInput), -1, ADDRESS(UnicodeText), Len)
  ELSE
    Len = LEN(pInput) / 2
    UnicodeText = pInput & '<0,0>'
  END
  
  IF pOutputCodepage = CP_UTF16
    RETURN UnicodeText[1 : Len*2]
  END
  
  !- get length of DecodedText in bytes
  Len = winapi::WideCharToMultiByte(pOutputCodePage, 0, ADDRESS(UnicodeText), -1, 0, 0, 0, 0)
  IF Len = 0
    json::DebugInfo('WideCharToMultiByte failed, error '& winapi::GetLastError())
    RETURN ''
  END
  winapi::WideCharToMultiByte(pOutputCodePage, 0, ADDRESS(UnicodeText), -1, ADDRESS(DecodedText), Len, 0, 0)
  RETURN DecodedText

json::FromUtf8                PROCEDURE(STRING pInput, UNSIGNED pCodepage = CP_ACP)
  CODE
  RETURN json::ConvertEncoding(pInput, CP_UTF8, pCodepage)
  
json::ToUtf8                  PROCEDURE(STRING pInput, UNSIGNED pCodepage = CP_ACP)
  CODE
  RETURN json::ConvertEncoding(pInput, pCodepage, CP_UTF8)

json::StringToULiterals       PROCEDURE(STRING pInput, UNSIGNED pInputCodepage = CP_ACP)
AChar                           STRING(1)
WChar                           STRING(2)
UnicodeText                     STRING(LEN(pInput) * 6) !\uXXXX
cIndex                          LONG
  CODE
  IF NOT pInput
    RETURN ''
  END
  
  LOOP cIndex = 1 TO LEN(pInput)
    AChar = pInput[cIndex]
    winapi::MultiByteToWideChar(pInputCodepage, 0, ADDRESS(AChar), 1, ADDRESS(WChar), 2)
    UnicodeText[(cIndex-1)*6+1 : cIndex*6] = '\u' & ByteToHex(VAL(WChar[2]), 1) & ByteToHex(VAL(WChar[1]), 1)
  END
  
  RETURN UnicodeText
  
json::LoadFile                PROCEDURE(STRING pFile)
szFile                          CSTRING(LEN(pFile) + 1)
sData                           &STRING
hFile                           HANDLE
dwFileSize                      LONG
lpFileSizeHigh                  LONG
pvData                          LONG
dwBytesRead                     LONG
bRead                           BOOL
  CODE
  szFile=CLIP(pFile)
  hFile = winapi::CreateFile(szFile,GENERIC_READ,0,0,OPEN_EXISTING,0,0)
  IF hFile <> OS_INVALID_HANDLE_VALUE
    dwFileSize = winapi::GetFileSize(hFile,lpFileSizeHigh)
    IF dwFileSize > 0
      sData &= NEW STRING(dwFileSize)
      bRead = winapi::ReadFile(hFile,ADDRESS(sData),dwFileSize,dwBytesRead,0)
    END
    winapi::CloseHandle(hFile)
  END

  RETURN sData

json::SaveFile                PROCEDURE(STRING pFilename, STRING pData)
szFile                          CSTRING(256)
hFile                           HANDLE
dwBytesWritten                  LONG
bRC                             LONG, AUTO
  CODE
  szFile=CLIP(pFilename)
  hFile = winapi::CreateFile(szFile,GENERIC_WRITE,0,0,CREATE_ALWAYS,0,0)
  IF hFile = OS_INVALID_HANDLE_VALUE
    RETURN FALSE
  END
  
  bRC = winapi::WriteFile(hFile, pData, LEN(pData), dwBytesWritten, 0)
  winapi::CloseHandle(hFile)

  IF NOT bRC
    !-- error
    json::DebugInfo('WriteFile failed with Win error code '& winapi::GetLastError())
  END
  
  RETURN bRC

!!!endregion

!!!region shortcuts
json::CreateNull              PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Null
  RETURN item
  
json::CreateTrue              PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_True
  RETURN item

json::CreateFalse             PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_False
  RETURN item

json::CreateBool              PROCEDURE(BOOL b)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = CHOOSE(b = TRUE, cJSON_True, cJSON_False)
  RETURN item

json::CreateNumber            PROCEDURE(REAL num)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Number
  item.SetNumberValue(num)

  RETURN item

json::CreateString            PROCEDURE(STRING str)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_String
  IF str
    item.valuestring &= NEW STRING(LEN(CLIP(str)))
    item.valuestring = CLIP(str)
  END
  
  RETURN item

json::CreateRaw               PROCEDURE(STRING rawJson)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Raw
  IF rawJson
    item.valuestring &= NEW STRING(LEN(CLIP(rawJson)))
    item.valuestring = CLIP(rawJson)
  END
  
  RETURN item

json::CreateArray             PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Array
  
  RETURN item

json::CreateObject            PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Object
  
  RETURN item

json::CreateStringReference   PROCEDURE(*STRING str)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = BOR(cJSON_String, cJSON_IsReference)
  item.valuestring &= str
  
  RETURN item

json::CreateObjectReference   PROCEDURE(*cJSON child)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = BOR(cJSON_Object, cJSON_IsReference)
  item.child &= child
  
  RETURN item

json::CreateArrayReference    PROCEDURE(*cJSON child)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = BOR(cJSON_Array, cJSON_IsReference)
  item.child &= child
  
  RETURN item

json::CreateIntArray          PROCEDURE(LONG[] numbers)
i                               LONG, AUTO
n                               &cJSON
p                               &cJSON
a                               &cJSON
  CODE
  a &= json::CreateArray()
  
  LOOP i = 1 TO MAXIMUM(numbers, 1)
    IF NOT a &= NULL
      n &= json::CreateNumber(numbers[i])
      IF n &= NULL
        a.Delete()
        RETURN NULL
      END
      
      IF i = 1
        a.child &= n
      ELSE
        suffix_object(p, n)
      END
      
      p &= n
    END
  END
  
  RETURN a

json::CreateDoubleArray       PROCEDURE(REAL[] numbers)
i                               LONG, AUTO
n                               &cJSON
p                               &cJSON
a                               &cJSON
  CODE
  a &= json::CreateArray()
  
  LOOP i = 1 TO MAXIMUM(numbers, 1)
    IF NOT a &= NULL
      n &= json::CreateNumber(numbers[i])
      IF n &= NULL
        a.Delete()
        RETURN NULL
      END
      
      IF i = 1
        a.child &= n
      ELSE
        suffix_object(p, n)
      END
      
      p &= n
    END
  END
  
  RETURN a

json::CreateStringArray       PROCEDURE(STRING[] strings, <STRING pIfEmpty>)
i                               LONG, AUTO
j                               LONG, AUTO
n                               &cJSON
p                               &cJSON
a                               &cJSON
  CODE
  a &= json::CreateArray()
  
  j = 0
  LOOP i = 1 TO MAXIMUM(strings, 1)
    IF NOT a &= NULL
      IF CLIP(strings[i])
        n &= json::CreateString(strings[i])
      ELSE
        CASE pIfEmpty
        OF 'null'
          n &= json::CreateNull()
        OF 'ignore'
          CYCLE
        ELSE
          n &= json::CreateString(strings[i])
        END
      END
      
      IF n &= NULL
        a.Delete()
        RETURN NULL
      END
      
      j += 1
      IF j = 1
        a.child &= n
      ELSE
        suffix_object(p, n)
      END
      
      p &= n
    END
  END
  
  RETURN a

json::CreateObject            PROCEDURE(*GROUP grp, BOOL pNamesInLowerCase = TRUE, <STRING options>)
ndx                             LONG, AUTO
fldRef                          ANY
fldName                         STRING(256), AUTO
fldDim                          LONG, AUTO
item                            &cJSON
fldRules                        QUEUE(typCJsonFieldRules)
                                END
fldValue                        ANY
jsonName                        &STRING
nestedGrpRef                    &GROUP
nestedQueRef                    &QUEUE
nestedItem                      &cJSON
arrSize                         LONG, AUTO
  CODE
  !- field convertion rules
  ParseFieldRules(options, fldRules)

  item &= json::CreateObject()
  
  LOOP ndx = 1 TO 99999
    fldRef &= WHAT(grp, ndx)
    IF fldRef &= NULL
      !end of group
      BREAK
    END
    
    fldName = WHO(grp, ndx)
    IF NOT fldName
      !skip fields with blank names
      CYCLE
    END
    
    IF NOT nestedGrpRef &= NULL AND IsFieldInGroup(nestedGrpRef, fldName)
      !- this field has already been processed in a nested group
      CYCLE
    ELSE
      !- this field is not in a nested group - process it
      nestedGrpRef &= NULL
    END

    RemoveFieldPrefix(fldName)
    
    IF pNamesInLowerCase
      fldName = LOWER(fldName)
    END
    
    !- find field rules
    FindFieldRule(fldName, fldRules)
    
    !- map Field name to Json name
    IF fldRules.JsonName
      jsonName &= fldRules.JsonName
    ELSE
      jsonName &= fldName
    END
    
    IF fldRules.Ignore <> TRUE
      fldDim = HOWMANY(grp, ndx)
      IF fldDim = 1
        !not an array (NOTE: DIM(1) also returns 1, which causes runtime error later.)
       
        IF fldRules.IsQueue
          DO CreateQueueArray
        ELSE
          !- apply field rules
          fldValue = ApplyFieldRule(fldName, fldRef, fldRules)
          IF fldRules.IsBase64
            !- encode to base64
            fldValue = printf('%v', fldValue)
          END

          IF ISGROUP(grp, ndx)
            !- recursively add nested group as json object
            nestedGrpRef &= GETGROUP(grp, ndx)
            nestedItem &= json::CreateObject(nestedGrpRef, pNamesInLowerCase, options)
  
            IF fldRules.IgnoreEmptyObject AND nestedItem.GetArraySize() = 0
              !- delete empty object
              nestedItem.Delete()
              nestedItem &= NULL
            END

            item.AddItemToObject(jsonName, nestedItem)
          ELSIF fldRules.Instance
            !- fldRules.Instance is an address of a queue, so create json array
            nestedQueRef &= (fldRules.Instance)
            IF fldRules.FieldNumber = 0
              nestedItem &= json::CreateArray(nestedQueRef, pNamesInLowerCase, options)
            ELSE
              !- an array of one q field
              nestedItem &= json::CreateSimpleArray(nestedQueRef, fldRules.FieldNumber, pNamesInLowerCase, options)
            END
            
            IF fldRules.IgnoreEmptyArray AND nestedItem.GetArraySize() = 0
              !- don't add empty array
              nestedItem.Delete()
              nestedItem &= NULL
            END

            item.AddItemToObject(jsonName, nestedItem)

          ELSIF fldRules.IsBool
            IF NOT (fldRules.IgnoreFalse AND fldValue=0)
              item.AddBoolToObject(jsonName, fldValue)  !- create bool regardless of field type (so if fieldType is STRING, then non empty string will produce true, empty - false).
            END
          ELSIF fldRules.IsRaw
            item.AddRawToObject(jsonName, fldValue)   !- raw json
          ELSIF ISSTRING(fldValue)
            DO CreateString
          ELSIF NUMERIC(fldValue)
            IF NOT (fldRules.IgnoreZero AND fldValue=0)
              item.AddNumberToObject(jsonName, fldValue)
            END
          ELSE
            !neither STRING nor NUMERIC: process as a STRING
            DO CreateString
          END
        END
      ELSE
        !arrays
        arrSize = CHOOSE(fldRules.ArraySize > 0 AND fldRules.ArraySize < fldDim, fldRules.ArraySize, fldDim)
  
        IF ISGROUP(grp,ndx)
          DO CreateGroupArray
        ELSIF ISSTRING(fldRef)
          !string array
          DO CreateStringArray
        
          !ELSIF NUMERIC(fldRef)  - this line throws runtime error
        ELSE  !assume this is numeric array
          DO CreateNumericArray
        END
      END
    END
  END
  
  RETURN item

CreateString                  ROUTINE
  DATA
bIsNullRef  BOOL, AUTO
  CODE
  bIsNullRef = IsAnyNullRef(fldValue)
  IF CLIP(fldValue) <> '' AND NOT bIsNullRef
    !- not empty string / not null reference to a string / not null ref to a queue
    item.AddStringToObject(jsonName, fldValue)
  ELSE
    !- empty string
    CASE fldRules.EmptyString
    OF 'ignore'
      ! do nothing
    OF 'null'
      item.AddNullToObject(jsonName)
    ELSE
      IF NOT bIsNullRef
        item.AddStringToObject(jsonName, '')
      ELSE
        !- null ref
        item.AddNullToObject(jsonName)
      END
    END
  END

CreateStringArray             ROUTINE
  DATA
strings STRING(256), DIM(arrSize)
elemRef ANY
elemNdx LONG, AUTO
  CODE
  !copy array
  LOOP elemNdx = 1 TO arrSize
    elemRef &= WHAT(grp, ndx, elemNdx)
    strings[elemNdx] = ApplyFieldRule(fldName, elemRef, fldRules)
  END
  item.AddItemToObject(jsonName, json::CreateStringArray(strings, fldRules.EmptyString))

CreateNumericArray            ROUTINE
  DATA
numbers REAL, DIM(arrSize)
elemRef ANY
elemNdx LONG, AUTO
  CODE
  !copy array
  LOOP elemNdx = 1 TO arrSize
    elemRef &= WHAT(grp, ndx, elemNdx)
    numbers[elemNdx] = ApplyFieldRule(fldName, elemRef, fldRules)
  END
  item.AddItemToObject(jsonName, json::CreateDoubleArray(numbers))
  
CreateGroupArray              ROUTINE
  DATA
grpRef      &GROUP
grpArray    &cJSON
grpItem     &cJSON
elemNdx     LONG, AUTO
  CODE
  grpArray &= json::CreateArray()
  LOOP elemNdx = 1 TO arrSize
    grpRef &= GETGROUP(grp,ndx,elemNdx)
    grpItem &= json::CreateObject(grpRef, pNamesInLowerCase, options)
    grpArray.AddItemToObject(jsonName, grpItem)
  END
  !- I dont't check IgnoreEmptyObject rule here because an empty array in this case is possible only with "GROUP,DIM(0)" declaraion.
  item.AddItemToObject(jsonName, grpArray)
  !- don't process anymore the fields from this group array
  nestedGrpRef &= grpRef

CreateQueueArray              ROUTINE
  DATA
fla         ANY
queRef      &QUEUE
queArray    &cJSON
  CODE
  ndx += 1  !- we assume that next field is INSTANCE of queue.
  fla &= WHAT(grp,ndx)
  queRef &= (fla)
  IF fldRules.FieldNumber = 0
    queArray &= json::CreateArray(queRef, pNamesInLowerCase, options)
  ELSE
    !- an array of one q field
    queArray &= json::CreateSimpleArray(queRef, fldRules.FieldNumber, pNamesInLowerCase, options)
  END
  
  IF fldRules.IgnoreEmptyArray AND queArray.GetArraySize() = 0
    !- don't add empty array
    queArray.Delete()
    queArray &= NULL
  END

  item.AddItemToObject(jsonName, queArray)
  
json::CreateArray             PROCEDURE(*QUEUE que, BOOL pNamesInLowerCase = TRUE, <STRING options>)
array                           &cJSON
grp                             &GROUP
ndx                             LONG, AUTO
  CODE
  array &= json::CreateArray()
  LOOP ndx = 1 TO RECORDS(que)
    GET(que, ndx)
    grp &= que
    array.AddItemToArray(json::CreateObject(grp, pNamesInLowerCase, options))
  END

  RETURN array

json::CreateSimpleArray       PROCEDURE(*QUEUE que, LONG pFieldNumber, BOOL pNamesInLowerCase = TRUE, <STRING options>)
array                           &cJSON
grp                             &GROUP
fldRef                          ANY
fldName                         STRING(256), AUTO
fldRules                        QUEUE(typCJsonFieldRules)
                                END
fldValue                        ANY
ndx                             LONG, AUTO
  CODE
  array &= json::CreateArray()
  
  IF pFieldNumber
    fldName = WHO(que, pFieldNumber)
    IF fldName
      RemoveFieldPrefix(fldName)
    
      IF pNamesInLowerCase
        fldName = LOWER(fldName)
      END
    
      !- field convertion rules
      ParseFieldRules(options, fldRules)

      !- find field rules
      FindFieldRule(fldName, fldRules)

      !- loop thru queue records
      LOOP ndx = 1 TO RECORDS(que)
        GET(que, ndx)
        grp &= que
        fldRef &= WHAT(grp, pFieldNumber)
        IF fldRef &= NULL
          BREAK
        END
      
        fldValue = ApplyFieldRule(fldName, fldRef, fldRules)
        IF fldRules.IsBase64
          !- encode to base64
          fldValue = printf('%v', fldValue)
        END

        IF ISSTRING(fldValue)
          array.AddItemToArray(json::CreateString(fldValue))
        ELSE
          array.AddItemToArray(json::CreateNumber(fldValue))
        END
      END
    END
  END
  
  RETURN array

json::CreateArray             PROCEDURE(*FILE pFile, BOOL pNamesInLowerCase = TRUE, <STRING options>, BOOL pWithBlobs = FALSE)
array                           &cJSON
item                            &cJSON
ferr                            LONG, AUTO
grp                             &GROUP
doCloseFile                     BOOL(FALSE)
  CODE
  IF STATUS(pFile) = 0
    OPEN(pFile, 40h)  !- Read Only/Deny None
    IF ERRORCODE()
      RETURN NULL
    END
    
    doCloseFile = TRUE
    SET(pFile)  !- sort by physical order
  END

  grp &= pFile{PROP:Record}

  array &= json::CreateArray()
  LOOP
    NEXT(pFile)
    ferr = ERRORCODE()
    IF ferr
      IF ferr <> 33
        !real error, not end of file
        json::DebugInfo('NEXT(file) failed: '& ERROR())
      END
      BREAK
    END
    
    item &= json::CreateObject(grp, pNamesInLowerCase, options)
    
    IF pWithBlobs
      json::BlobsToObject(item, pFile, pNamesInLowerCase, options)
    END
    
    array.AddItemToArray(item)
  END
  
  IF doCloseFile
    CLOSE(pFile)
  END

  RETURN array
  
json::BlobsToObject           PROCEDURE(*cJSON pItem, *FILE pFile, BOOL pNamesInLowerCase = TRUE, <STRING options>)
fldRules                        QUEUE(typCJsonFieldRules)
                                END
cIndex                          BYTE, AUTO
fldName                         STRING(256), AUTO
fldValue                        ANY
jsonName                        &STRING
  CODE
  !- field convertion rules
  ParseFieldRules(options, fldRules)

  LOOP cIndex = 1 TO pFile{PROP:Memos} + pFile{PROP:Blobs}
    fldName = pFile{PROP:Label, -cIndex}
    IF NOT fldName
      !skip fields with blank names
      CYCLE
    END
    
    RemoveFieldPrefix(fldName)
    
    IF pNamesInLowerCase
      fldName = LOWER(fldName)
    END
    
    !- find field rules
    FindFieldRule(fldName, fldRules)
    
    !- map Field name to Json name
    IF fldRules.JsonName
      jsonName &= fldRules.JsonName
    ELSE
      jsonName &= fldName
    END
    
    IF fldRules.Ignore <> TRUE
      !- apply field rules
      fldValue = ApplyFieldRule(fldName, pFile{PROP:Value, -cIndex}, fldRules)
      IF fldRules.IsBase64
        !- encode to base64
        fldValue = printf('%v', fldValue)
      END
      pItem.AddStringToObject(jsonName, fldValue)
    END
  END
  
json::ObjectToBlobs           PROCEDURE(*cJSON pObject, *FILE pFile, <STRING options>)
item                            &cJSON
fldName                         STRING(256), AUTO
fldRules                        QUEUE(typCJsonFieldRules)
                                END
cIndex                          BYTE, AUTO
jsonName                        &STRING
  CODE
  IF NOT pObject.IsObject()
    !not an object
  END
  
  item &= pObject.child
  IF item &= NULL
    !empty object
  END

  !- field convertion rules
  ParseFieldRules(options, fldRules)
  
  !by field names
  LOOP WHILE NOT item &= NULL
    IF NOT item.name &= NULL AND item.name <> ''
      LOOP cIndex = 1 TO pFile{PROP:Memos} + pFile{PROP:Blobs}
        fldName = pFile{PROP:Label, -cIndex}
        IF NOT fldName
          !skip fields with blank names
          CYCLE
        END
    
        RemoveFieldPrefix(fldName)
        
        !- find field rules
        FindFieldRule(fldName, fldRules)
        
        !- map Field name to Json name
        IF fldRules.JsonName
          jsonName &= fldRules.JsonName
        ELSE
          jsonName &= fldName
        END
    
        IF LOWER(jsonName) = LOWER(item.name)
            
          IF item.IsObject() !AND ISGROUP(grp, fidNdx)
            !- skip
          ELSIF item.IsArray() !AND fldRules.Instance
            !- skip
          ELSE
            !found group field, assign the value
            DO AssignGroup
          END
            
          !go to next element
          BREAK
        END
      END
    END
      
    item &= item.next
  END

AssignGroup                   ROUTINE
  DATA
fldValue    ANY
  CODE
  IF fldRules.Ignore <> TRUE
    IF item.IsString()
      IF NOT fldRules.IsBase64
        fldValue = item.valuestring
      ELSE
        !- decode base64 encoded string
        fldValue = printf('%w', item.valuestring)
      END
    ELSIF item.IsNumber()
      fldValue = item.valuedouble
    ELSIF item.IsBool()
      fldValue = item.valueint
    ELSIF item.IsFalse()
      fldValue = 0
    ELSIF item.IsTrue()
      fldValue = 1
    END

    !- apply field rule, if exists
    pFile{PROP:Value, -cIndex} = ApplyFieldRule(fldName, fldValue, fldRules)
  END
!!!endregion

!!!region cJSON
cJSON.Construct               PROCEDURE()
  CODE
  
cJSON.Destruct                PROCEDURE()
  CODE
  IF NOT SELF.name &= NULL
    DISPOSE(SELF.name)
    SELF.name &= NULL
  END
  IF NOT SELF.valuestring &= NULL
    DISPOSE(SELF.valuestring)
    SELF.valuestring &= NULL
  END

cJSON.GetPrevious             PROCEDURE()
  CODE
  RETURN SELF.prev

cJSON.GetNext                 PROCEDURE()
  CODE
  RETURN SELF.next
  
cJSON.GetChild                PROCEDURE()
  CODE
  RETURN SELF.child

cJSON.GetName                 PROCEDURE()
  CODE
  RETURN SELF.name
  
cJSON.SetName                 PROCEDURE(STRING pNewName)
  CODE
  IF (NOT BAND(SELF.type, cJSON_StringIsConst))
    IF NOT SELF.name &= NULL
      DISPOSE(SELF.name)
    END
    SELF.name &= NEW STRING(LEN(CLIP(pNewName)))
    SELF.name = CLIP(pNewName)
  END

cJSON.GetType                 PROCEDURE()
  CODE
  RETURN SELF.type
  
cJSON.SetType                 PROCEDURE(cJSON_Type pType)
  CODE
  SELF.type = pType
  
cJSON.GetNumberValue          PROCEDURE()
  CODE
  RETURN SELF.valuedouble
  
cJSON.SetNumberValue          PROCEDURE(REAL pNewValue)
  CODE
  SELF.valuedouble = pNewValue
 
  !use saturation in case of overflow
  IF SELF.valuedouble >= INT_MAX
    SELF.valueint = INT_MAX
  ELSIF SELF.valuedouble <= INT_MIN
    SELF.valueint = INT_MIN
  ELSE
    SELF.valueint = SELF.valuedouble
  END

cJSON.ToString                PROCEDURE(BOOL pFormat = FALSE)
  CODE
  RETURN SELF.ToUtf8(pFormat, -1) !- ascii output
  
cJSON.ToUtf8                  PROCEDURE(BOOL pFormat = FALSE, LONG pCodepage=CP_ACP)
buffer                          LIKE(typPrintBuffer)
printed                         TStringBuilder
minPrintedSize                  LONG, AUTO
  CODE
  !- allocate enough buffer size to avoid realloc calls in TStringBuilder.Cat().
  minPrintedSize = SELF.GetMinimalOutputSize()
  IF NOT pFormat
    printed.Init(minPrintedSize * 5 / 4)
  ELSE
    printed.Init(minPrintedSize * 3 / 2)
  END
  
  buffer.printed &= printed
  buffer.format = pFormat
  buffer.codepage = pCodepage
  print_value(SELF, buffer)
  RETURN buffer.printed.Str()

cJSON.Delete                  PROCEDURE()
item                            &cJSON
next                            &cJSON
  CODE
  item &= SELF
  LOOP WHILE (NOT item &= NULL)
    next &= item.next
    IF (NOT BAND(item.type, cJSON_IsReference)) AND (NOT item.child &= NULL)
      item.child.Delete()
    END

    IF (NOT BAND(item.type, cJSON_IsReference)) AND (NOT item.valuestring &= NULL)
      DISPOSE(item.valuestring)
    END
    item.valuestring &= NULL

    IF (NOT BAND(item.type, cJSON_StringIsConst)) AND (NOT item.name &= NULL)
      DISPOSE(item.name)
    END
    item.name &= NULL

    DISPOSE(item)
    item &= next
  END
    
cJSON.GetArraySize            PROCEDURE(BOOL recurse = FALSE)
child                           &cJSON
sz                              LONG(0)
  CODE
  child &= SELF.child
  LOOP WHILE (NOT child &= NULL)
    sz += 1
    IF recurse
      sz += child.GetArraySize(recurse)
    END
    
    child &= child.next
  END
  
  !FIXME: Can overflow here. Cannot be fixed without breaking the API
  
  RETURN sz
  
cJSON.GetArrayItem            PROCEDURE(LONG index)
  CODE
  IF index < 1
    RETURN NULL
  END
  
  RETURN get_array_item(SELF, index)

cJSON.GetObjectItem           PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)
  CODE
  RETURN get_object_item(SELF, itemName, caseSensitive)
  
cJSON.HasItem                 PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)
  CODE
  IF SELF.IsObject()
    RETURN CHOOSE(NOT SELF.GetObjectItem(itemName, caseSensitive) &= NULL)
  ELSIF SELF.IsArray() AND NUMERIC(itemName)
    RETURN CHOOSE(NOT SELF.GetArrayItem(itemName) &= NULL)
  ELSE
    RETURN FALSE
  END
  
cJSON.GetStringValue          PROCEDURE()
  CODE
  IF NOT SELF.IsString()
    RETURN ''
  END
  
  RETURN SELF.valuestring
  
cJSON.SetStringValue          PROCEDURE(STRING pNewValue)
  CODE
  IF NOT SELF.IsString()
    RETURN
  END

  IF NOT SELF.valuestring &= NULL
    DISPOSE(SELF.valuestring)
  END

  SELF.valuestring &= NEW STRING(LEN(CLIP(pNewValue)))
  SELF.valuestring = CLIP(pNewValue)

cJSON.IsInvalid               PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Invalid)
  
cJSON.IsFalse                 PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_False)
  
cJSON.IsTrue                  PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_True)
  
cJSON.IsBool                  PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, BOR(cJSON_True, cJSON_False)) <> 0)
  
cJSON.IsNull                  PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_NULL)
  
cJSON.IsNumber                PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Number)
  
cJSON.IsString                PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_String)
  
cJSON.IsArray                 PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Array)
  
cJSON.IsObject                PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Object)
  
cJSON.IsRaw                   PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Raw)
  
cJSON.AddItemToArray          PROCEDURE(*cJSON item)
  CODE
  add_item_to_array(SELF, item)
  
cJSON.AddItemToObject         PROCEDURE(STRING itemName, *cJSON item)
  CODE
  add_item_to_object(SELF, itemName, item, FALSE)

!Add an item to an object with constant string as key
cJSON.AddItemToObjectCS       PROCEDURE(*STRING itemName, *cJSON item)
  CODE
  add_item_to_object(SELF, itemName, item, TRUE)
  
cJSON.AddItemReferenceToArray PROCEDURE(*cJSON item)
  CODE
  add_item_to_array(SELF, create_reference(item))

cJSON.AddItemReferenceToObject    PROCEDURE(STRING itemName, *cJSON item)
  CODE
  add_item_to_object(SELF, itemName, create_reference(item), FALSE)
  
cJSON.DetachItemViaPointer    PROCEDURE(*cJSON item)
  CODE
  IF item &= NULL
    RETURN NULL
  END
  
  IF NOT item.prev &= NULL
    !not the first element
    item.prev.next &= item.next
  END
  IF NOT item.next &= NULL
    !not the last element
    item.next.prev &= item.prev
  END

  IF item &= SELF.child
    !first element
    SELF.child &= item.next
  END
  
  !make sure the detached item doesn't point anywhere anymore
  item.prev &= NULL
  item.next &= NULL

  RETURN item
  
cJSON.DetachItemFromArray     PROCEDURE(LONG which)
  CODE
  IF which < 1
    RETURN NULL
  END
  
  RETURN SELF.DetachItemViaPointer(get_array_item(SELF, which))
  
cJSON.DeleteItemFromArray     PROCEDURE(LONG which)
item                            &cJSON
  CODE
  item &= SELF.DetachItemFromArray(which)
  IF NOT item &= NULL
    item.Delete()
  END

cJSON.DetachItemFromObject    PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)
item                            &cJSON
  CODE
  item &= SELF.GetObjectItem(itemName, caseSensitive)
  RETURN SELF.DetachItemViaPointer(item)
  
cJSON.DeleteItemFromObject    PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)
item                            &cJSON
  CODE
  item &= SELF.DetachItemFromObject(itemName, caseSensitive)
  IF NOT item &= NULL
    item.Delete()
  END
  
!Replace array/object items with new ones.
cJSON.InsertItemInArray       PROCEDURE(LONG which, cJSON newitem)
after_inserted                  &cJSON
  CODE
  IF which < 1
    RETURN
  END
  
  after_inserted &= get_array_item(SELF, which)
  IF after_inserted &= NULL
    add_item_to_array(SELF, newitem)
    RETURN
  END

  newitem.next &= after_inserted
  newitem.prev &= after_inserted.prev
  after_inserted.prev &= newitem
  IF after_inserted &= SELF.child
    SELF.child &= newitem
  ELSE
    newitem.prev.next &= newitem
  END
  
cJSON.ReplaceItemViaPointer   PROCEDURE(*cJSON item, *cJSON replacement)
  CODE
  IF item &= NULL OR replacement &= NULL
    RETURN FALSE
  END
  
  IF replacement &= item
    RETURN TRUE
  END

  replacement.next &= item.next
  replacement.prev &= item.prev

  IF NOT replacement.next &= NULL
    replacement.next.prev &= replacement
  END

  IF NOT replacement.prev &= NULL
    replacement.prev.next &= replacement
  END

  IF SELF.child &= item
    SELF.child &= replacement
  END

  item.next &= NULL
  item.prev &= NULL
  item.Delete()

  RETURN TRUE
  
cJSON.ReplaceItemInArray      PROCEDURE(LONG which, *cJSON newitem)
  CODE
  IF which < 1
    RETURN
  END
  
  SELF.ReplaceItemViaPointer(get_array_item(SELF, which), newitem)
  
cJSON.ReplaceItemInObject     PROCEDURE(STRING str, *cJSON newitem, BOOL caseSensitive = FALSE)
  CODE
  replace_item_in_object(SELF, str, newitem, caseSensitive)
  
cJSON.Duplicate               PROCEDURE(BOOL recurse)
newitem                         &cJSON
child                           &cJSON
next                            &cJSON
newchild                        &cJSON
  CODE
  !Create new item
  newitem &= NEW cJSON
  !Copy over all vars
  newitem.type = SELF.type
  newitem.valueint = SELF.valueint
  newitem.valuedouble = SELF.valuedouble
  IF NOT SELF.valuestring &= NULL
    newitem.valuestring &= NEW STRING(LEN(SELF.valuestring))
    newitem.valuestring = SELF.valuestring
  END
  IF NOT SELF.name &= NULL
    IF BAND(SELF.type, cJSON_StringIsConst)
      newitem.name &= SELF.name
    ELSE
      newitem.name &= NEW STRING(LEN(SELF.name))
      newitem.name = SELF.name
    END
  END

  !If non-recursive, then we're done!
  IF NOT recurse
    RETURN newitem
  END

  !Walk the ->next chain for the child.
  child &= SELF.child
  LOOP WHILE NOT child &= NULL
    newchild &= child.Duplicate(TRUE) !Duplicate (with recurse) each item in the ->next chain
    IF newchild &= NULL
      DO Fail
    END
    
    IF NOT next &= NULL
      !If newitem->child already set, then crosswire ->prev and ->next and move on
      next.next &= newchild
      newchild.prev &= next
      next &= newchild
    ELSE
      !Set newitem->child and move to it 
      newitem.child &= child
      next &= newchild
    END
  
    child &= child.next
  END
  
  RETURN newitem

Fail                          ROUTINE
  IF NOT newitem &= NULL
    newitem.Delete()
  END
  
  RETURN NULL
  
cJSON.AddNullToObject         PROCEDURE(STRING name)
null_item                       &cJSON
  CODE
  null_item &= json::CreateNull()
  IF add_item_to_object(SELF, name, null_item, FALSE)
    RETURN null_item
  END
  
  null_item.Delete()
  RETURN NULL
  
cJSON.AddTrueToObject         PROCEDURE(STRING name)
true_item                       &cJSON
  CODE
  true_item &= json::CreateTrue()
  IF add_item_to_object(SELF, name, true_item, FALSE)
    RETURN true_item
  END
  
  true_item.Delete()
  RETURN NULL
  
cJSON.AddFalseToObject        PROCEDURE(STRING name)
false_item                      &cJSON
  CODE
  false_item &= json::CreateFalse()
  IF add_item_to_object(SELF, name, false_item, FALSE)
    RETURN false_item
  END
  
  false_item.Delete()
  RETURN NULL
  
cJSON.AddBoolToObject         PROCEDURE(STRING name, BOOL boolean)
bool_item                       &cJSON
  CODE
  bool_item &= json::CreateBool(boolean)
  IF add_item_to_object(SELF, name, bool_item, FALSE)
    RETURN bool_item
  END
  
  bool_item.Delete()
  RETURN NULL
  
cJSON.AddNumberToObject       PROCEDURE(STRING name, REAL number)
number_item                     &cJSON
  CODE
  number_item &= json::CreateNumber(number)
  IF add_item_to_object(SELF, name, number_item, FALSE)
    RETURN number_item
  END
  
  number_item.Delete()
  RETURN NULL
  
cJSON.AddStringToObject       PROCEDURE(STRING name, STRING value)
string_item                     &cJSON
  CODE
  string_item &= json::CreateString(value)
  IF add_item_to_object(SELF, name, string_item, FALSE)
    RETURN string_item
  END
  
  string_item.Delete()
  RETURN NULL
  
cJSON.AddRawToObject          PROCEDURE(STRING name, STRING raw)
raw_item                        &cJSON
  CODE
  raw_item &= json::CreateRaw(raw)
  IF add_item_to_object(SELF, name, raw_item, FALSE)
    RETURN raw_item
  END
  
  raw_item.Delete()
  RETURN NULL
  
cJSON.AddObjectToObject       PROCEDURE(STRING name)
object_item                     &cJSON
  CODE
  object_item &= json::CreateObject()
  IF add_item_to_object(SELF, name, object_item, FALSE)
    RETURN object_item
  END
  
  object_item.Delete()
  RETURN NULL
  
cJSON.AddArrayToObject        PROCEDURE(STRING name)
array                           &cJSON
  CODE
  array &= json::CreateArray()
  IF add_item_to_object(SELF, name, array, FALSE)
    RETURN array
  END
  
  array.Delete()
  RETURN NULL

cJSON.ToGroup                 PROCEDURE(*GROUP grp, BOOL matchByFieldNumber = FALSE, <STRING options>)
item                            &cJSON
fldRef                          ANY
fldName                         STRING(256), AUTO
fidNdx                          LONG, AUTO
fldRules                        QUEUE(typCJsonFieldRules)
                                END
jsonName                        &STRING
nestedGrpRef                    &GROUP
nestedQueRef                    &QUEUE
  CODE
  IF NOT SELF.IsObject()
    !not an object
    RETURN FALSE
  END
    
  CLEAR(grp)

  item &= SELF.child
  IF item &= NULL
    !empty object
    RETURN TRUE
  END

  !- field convertion rules
  ParseFieldRules(options, fldRules)
  
  IF NOT matchByFieldNumber
    !by field names

    LOOP WHILE NOT item &= NULL
      IF NOT item.name &= NULL AND item.name <> ''
        !search for group field with same name
        LOOP fidNdx = 1 TO 99999
          fldRef &= WHAT(grp, fidNdx)
          IF fldRef &= NULL
            !end of group
            BREAK
          END

          fldName = WHO(grp, fidNdx)
          RemoveFieldPrefix(fldName)

          !- find field rules
          FindFieldRule(fldName, fldRules)
          
          !- map Field name to Json name
          IF fldRules.JsonName
            jsonName &= fldRules.JsonName
          ELSE
            jsonName &= fldName
          END

          IF LOWER(jsonName) = LOWER(item.name)
            
            IF item.IsObject() AND ISGROUP(grp, fidNdx)
              !- child item is of object type, and it matches a nested group
              nestedGrpRef &= GETGROUP(grp, fidNdx)
              item.ToGroup(nestedGrpRef, matchByFieldNumber, options)
            ELSIF item.IsArray() AND fldRules.Instance
              !- child item is an array, so load it into a queue
              nestedQueRef &= (fldRules.Instance)
              IF fldRules.FieldNumber = 0
                item.ToQueue(nestedQueRef, matchByFieldNumber, options)
              ELSE
                item.ToQueueField(nestedQueRef, fldRules.FieldNumber, matchByFieldNumber, options)
              END
            ELSE
              !found group field, assign the value
              DO AssignGroup
            END
            
            !go to next element
            BREAK
          END
        END
      END
      
      item &= item.next
    END
  ELSE
    !by field ordinal position
    
    fidNdx = 0
    LOOP WHILE NOT item &= NULL
      fidNdx += 1
      fldRef &= WHAT(grp, fidNdx)
      IF fldRef &= NULL
        !index out of range (number of group fields less than number of object items)
        BREAK
      END

      fldName = WHO(grp, fidNdx)
      RemoveFieldPrefix(fldName)

      !- find field rules
      FindFieldRule(fldName, fldRules)

      DO AssignGroup

      item &= item.next
    END
  END

  RETURN TRUE

AssignGroup                   ROUTINE
  DATA
fldValue                      ANY
  CODE
  IF fldRules.Ignore <> TRUE
    IF NOT fldRules.Auto
      IF item.IsString()
        IF NOT fldRules.IsBase64
          fldValue = item.valuestring
        ELSE
          !- decode base64 encoded string
          fldValue = printf('%w', item.valuestring)
        END
      ELSIF item.IsNumber()
        fldValue = item.valuedouble
      ELSIF item.IsBool()
        fldValue = item.valueint
      ELSIF item.IsFalse()
        fldValue = FALSE
      ELSIF item.IsTrue()
        fldValue = TRUE
      END

      !- apply field rule if it exists
      fldRef = ApplyFieldRule(fldName, fldValue, fldRules)
    ELSE
      !- "auto" field must be explicitly assigned
      ProcessAutoField(fldName, item, fldRules)
    END
  END
  
cJSON.ToQueue                 PROCEDURE(*QUEUE que, BOOL matchByFieldNumber = FALSE, <STRING options>)
  CODE
  RETURN SELF.ToQueueField(que, 0, matchByFieldNumber, options)
  
cJSON.ToQueueField            PROCEDURE(*QUEUE que, LONG pFieldNumber, BOOL matchByFieldNumber = FALSE, <STRING options>)
grp                             &GROUP
item                            &cJSON
fldRef                          ANY
fldValue                        ANY
  CODE
  IF NOT SELF.IsArray()
    !not an array
    RETURN FALSE
  END

  item &= SELF.child
  IF item &= NULL
    !empty array
    RETURN TRUE
  END
  
  IF pFieldNumber = 0
    !- assume default field number is 1
    pFieldNumber = 1
  END

  !go thru array elements
  LOOP WHILE NOT item &= NULL
    grp &= que
    
    IF item.IsObject()
      !- array of objects
      IF item.ToGroup(grp, matchByFieldNumber, options)
        !add a record
        ADD(que)
      END
    ELSE
      !- array of constants
      !- save the constant into a field which ordinal position is pFieldNumber
      fldRef &= WHAT(grp, pFieldNumber)
      IF NOT fldRef&= NULL
        IF item.IsString()
          fldRef = item.valuestring
        ELSIF item.IsNumber()
          fldRef = item.valuedouble
        ELSIF item.IsBool()
          fldRef = item.valueint
        ELSIF item.IsFalse()
          fldRef = FALSE
        ELSIF item.IsTrue()
          fldRef = TRUE
        ELSE
          fldRef = ''
        END
        ADD(que)
      END
    END
    
    item &= item.next
  END

  RETURN TRUE

cJSON.ToFile                  PROCEDURE(*FILE pFile, BOOL matchByFieldNumber = FALSE, <STRING options>, BOOL pWithBlobs = FALSE)
grp                             &GROUP
item                            &cJSON
  CODE
  IF NOT SELF.IsArray()
    !not an array
    RETURN FALSE
  END

  item &= SELF.child
  IF item &= NULL
    !empty array
    RETURN TRUE
  END

  !go thru array elements
  LOOP WHILE NOT item &= NULL
    grp &= pFile{PROP:Record}
    IF item.ToGroup(grp, matchByFieldNumber, options)
      
      IF pWithBlobs
        json::ObjectToBlobs(item, pFile, options)
      END
      
      !add a record
      ADD(pFile)
      IF ERRORCODE()
        json::DebugInfo('ADD error: '& ERROR())
      END
    END
    
    item &= item.next
  END

  RETURN TRUE
             
cJSON.FindObjectItem          PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)
item                            &cJSON
current_element                 &cJSON
  CODE
  item &= SELF.GetObjectItem(itemName, caseSensitive)
  IF NOT item &= NULL
    RETURN item
  END
  
  current_element &= SELF.child
  LOOP WHILE (NOT current_element &= NULL)
    item &= current_element.FindObjectItem(itemName, caseSensitive)
    IF NOT item &= NULL
      RETURN item
    END

    current_element &= current_element.next
  END

  RETURN NULL

cJSON.FindArrayItem           PROCEDURE(STRING arrayName, LONG itemIndex, BOOL caseSensitive = FALSE)
array                           &cJSON
  CODE
  array &= SELF.FindObjectItem(arrayName, caseSensitive)
  IF NOT array &= NULL
    RETURN array.GetArrayItem(itemIndex)
  END
  
  RETURN NULL
  
cJSON.GetValue                PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)
item                            &cJSON
  CODE
  item &= SELF.FindObjectItem(itemName, caseSensitive)
  IF item &= NULL
    RETURN ''
  END
  
  IF item.IsArray() OR item.IsInvalid() OR item.IsNull() OR item.IsObject() OR item.IsRaw()
    RETURN ''
  END

  IF item.IsString()
    RETURN item.GetStringValue()
  ELSIF item.IsFalse()
    RETURN FALSE
  ELSIF item.IsTrue()
    RETURN TRUE
  ELSE
    RETURN item.GetNumberValue()
  END

cJSON.GetStringRef            PROCEDURE()
  CODE
  RETURN SELF.valuestring
  
cJSON.GetStringSize           PROCEDURE()
  CODE
  IF NOT SELF.valuestring &= NULL
    RETURN SIZE(SELF.valuestring)
  ELSE
    RETURN 0
  END
  
cJSON.GetMinimalOutputSize    PROCEDURE()
child                           &cJSON
dataSize                        LONG(0)
  CODE
  IF NOT SELF.name &= NULL
    dataSize += SIZE(SELF.name) + 3 !- "name":
  END
  
  CASE BAND(SELF.type, 0FFh)
  OF cJSON_False
    dataSize += 5
  OF cJSON_True
    dataSize += 4
  OF cJSON_NULL
    dataSize += 4
  OF cJSON_Number
    dataSize += LEN(SELF.valuedouble)
  OF cJSON_String
    dataSize += SIZE(SELF.valuestring) + 2  !- "value"
  OF cJSON_Array
    dataSize += 2 !- []
  OF cJSON_Object
    dataSize += 2 !- {}
  OF cJSON_Raw
    dataSize += SIZE(SELF.valuestring)  !- "value"
  END
  
  child &= SELF.child
  LOOP WHILE (NOT child &= NULL)
    dataSize += child.GetMinimalOutputSize()  !- minimal output size of a child.ToString()
    dataSize += 1  !- a comma
    child &= child.next
  END
  
  RETURN dataSize

cJSON.Compare                 PROCEDURE(*cJSON pItemToCompare, BOOL case_sensitive)
  CODE
  RETURN json::Compare(SELF, pItemToCompare, case_sensitive)
!!!endregion
  
!!!region cJSONFactory
cJSONFactory.Construct        PROCEDURE()
  CODE
  SELF.codePage = -1  !- disable utf8->ascii conversion
  
cJSONFactory.Parse            PROCEDURE(STRING json)
  CODE
  RETURN SELF.Parse(json)
    
cJSONFactory.Parse            PROCEDURE(*IDynStr json)
sRef                            &STRING, AUTO
  CODE
  sRef &= (json.CStrRef()) &':'& json.StrLen()
  RETURN SELF.Parse(sRef)

cJSONFactory.Parse            PROCEDURE(*STRING json)
item                            &cJSON
buffer                          LIKE(typParseBuffer)
minival                         &STRING
  CODE
  CLEAR(SELF.parseErrorString)
  CLEAR(SELF.parseErrorPos)
  
  IF NOT json
    RETURN NULL
  END
    
  item &= NEW cJSON

  buffer.content &= json
  buffer.len = LEN(CLIP(json))
  buffer.pos = 1
  buffer.depth = 0
  buffer.codePage = SELF.codePage
  skip_utf8_bom(buffer)
  
  IF NOT parse_value(item, buffer)
    !parse failure. ep is set.
    item.Delete()
    item &= NULL
  
    IF buffer.pos <= buffer.len
      SELF.parseErrorPos = buffer.pos
    ELSIF buffer.len > 0
      SELF.parseErrorPos = buffer.len
    END
    
    SELF.parseErrorString = SUB(json, SELF.parseErrorPos, LEN(SELF.parseErrorString))
  ELSE
    !- success
    
    !- post-processing
    !- check single json item
    IF item.IsNull() OR item.IsFalse() OR item.IsTrue() OR item.IsNumber()
      !- remove whitespaces and comments
      minival &= NEW STRING(LEN(CLIP(json)))
      minival = json
      json::Minify(minival)
      
      !- check for atomic value (null|false|true|number)
      !- for example, at this point the string '400 Bad Request' will be parsed into numeric json with value of 400.
      
      IF (item.IsNull() AND minival <> 'null') |
        OR (item.IsFalse() AND minival <> 'false') |
        OR (item.IsTrue() AND minival <> 'true') |
        OR (item.IsNumber() AND NOT NUMERIC(minival))

        !parse failure.
        item.Delete()
        item &= NULL
  
        SELF.parseErrorPos = 1
        SELF.parseErrorString = SUB(json, SELF.parseErrorPos, LEN(SELF.parseErrorString))

      END
      
      DISPOSE(minival)
    END
  END
  
  RETURN item
    
cJSONFactory.Parse            PROCEDURE(STRING json, LONG pCodePage)
  CODE
  RETURN SELF.Parse(json, pCodePage)
      
cJSONFactory.Parse            PROCEDURE(*IDynStr json, LONG pCodePage)
sRef                            &STRING, AUTO
  CODE
  sRef &= (json.CStrRef()) &':'& json.StrLen()
  RETURN SELF.Parse(sRef, pCodePage)

cJSONFactory.Parse            PROCEDURE(*STRING json, LONG pCodePage)
  CODE
  SELF.codePage = pCodePage
  RETURN SELF.Parse(json)

cJSONFactory.ParseFile        PROCEDURE(STRING pFileName)
jsData                          &STRING
item                            &cJSON
  CODE
  jsData &= json::LoadFile(pFileName)
  item &= SELF.Parse(jsData)
  DISPOSE(jsData)
  RETURN item
  
cJSONFactory.ParseFile        PROCEDURE(STRING pFileName, LONG pCodePage)
  CODE
  SELF.codePage = pCodePage
  RETURN SELF.ParseFile(pFileName)

cJSONFactory.ToGroup          PROCEDURE(STRING json, *GROUP grp, BOOL matchByFieldNumber = FALSE, <STRING options>)
  CODE
  RETURN SELF.ToGroup(json, grp, matchByFieldNumber, options)
  
cJSONFactory.ToGroup          PROCEDURE(*IDynStr json, *GROUP grp, BOOL matchByFieldNumber = FALSE, <STRING options>)
sRef                            &STRING, AUTO
  CODE
  sRef &= (json.CStrRef()) &':'& json.StrLen()
  RETURN SELF.ToGroup(sRef, grp, matchByFieldNumber, options)

cJSONFactory.ToGroup          PROCEDURE(*STRING json, *GROUP grp, BOOL matchByFieldNumber = FALSE, <STRING options>)
object                          &cJSON
ret                             BOOL(FALSE)
  CODE
  object &= SELF.Parse(json)
  IF NOT object &= NULL
    ret = object.ToGroup(grp, matchByFieldNumber, options)
    object.Delete()
  END
  
  RETURN ret
  
cJSONFactory.ToQueue          PROCEDURE(STRING json, *QUEUE que, BOOL matchByFieldNumber = FALSE, <STRING options>)
  CODE
  RETURN SELF.ToQueue(json, que, matchByFieldNumber, options)
      
cJSONFactory.ToQueue          PROCEDURE(*IDynStr json, *QUEUE que, BOOL matchByFieldNumber = FALSE, <STRING options>)
sRef                            &STRING, AUTO
  CODE
  sRef &= (json.CStrRef()) &':'& json.StrLen()
  RETURN SELF.ToQueue(sRef, que, matchByFieldNumber, options)

cJSONFactory.ToQueue          PROCEDURE(*STRING json, *QUEUE que, BOOL matchByFieldNumber = FALSE, <STRING options>)
object                          &cJSON
ret                             BOOL(FALSE)
  CODE
  object &= SELF.Parse(json)
  IF NOT object &= NULL
    ret = object.ToQueue(que, matchByFieldNumber, options)
    object.Delete()
  END
  
  RETURN ret
    
cJSONFactory.ToQueueField     PROCEDURE(STRING json, *QUEUE que, LONG pFieldNumber, BOOL matchByFieldNumber = FALSE, <STRING options>)
  CODE
  RETURN SELF.ToQueueField(json, que, pFieldNumber, matchByFieldNumber, options)
      
cJSONFactory.ToQueueField     PROCEDURE(*IDynStr json, *QUEUE que, LONG pFieldNumber, BOOL matchByFieldNumber = FALSE, <STRING options>)
sRef                            &STRING, AUTO
  CODE
  sRef &= (json.CStrRef()) &':'& json.StrLen()
  RETURN SELF.ToQueueField(sRef, que, pFieldNumber, matchByFieldNumber, options)

cJSONFactory.ToQueueField     PROCEDURE(*STRING json, *QUEUE que, LONG pFieldNumber, BOOL matchByFieldNumber = FALSE, <STRING options>)
object                          &cJSON
ret                             BOOL(FALSE)
  CODE
  object &= SELF.Parse(json)
  IF NOT object &= NULL
    ret = object.ToQueueField(que, pFieldNumber, matchByFieldNumber, options)
    object.Delete()
  END
  
  RETURN ret

cJSONFactory.ToFile           PROCEDURE(STRING json, *FILE pFile, BOOL matchByFieldNumber = FALSE, <STRING options>, BOOL pWithBlobs = FALSE)
  CODE
  RETURN SELF.ToFile(json, pFile, matchByFieldNumber, options, pWithBlobs)
  
cJSONFactory.ToFile           PROCEDURE(*IDynStr json, *FILE pFile, BOOL matchByFieldNumber = FALSE, <STRING options>, BOOL pWithBlobs = FALSE)
sRef                            &STRING, AUTO
  CODE
  sRef &= (json.CStrRef()) &':'& json.StrLen()
  RETURN SELF.ToFile(sRef, pFile, matchByFieldNumber, options, pWithBlobs)

cJSONFactory.ToFile           PROCEDURE(*STRING json, *FILE pFile, BOOL matchByFieldNumber = FALSE, <STRING options>, BOOL pWithBlobs = FALSE)
object                          &cJSON
ret                             BOOL(FALSE)
  CODE
  object &= SELF.Parse(json)
  IF NOT object &= NULL
    ret = object.ToFile(pFile, matchByFieldNumber, options, pWithBlobs)
    object.Delete()
  END
  
  RETURN ret

cJSONFactory.GetError         PROCEDURE()
  CODE
  RETURN CLIP(SELF.parseErrorString)
  
cJSONFactory.GetErrorPosition PROCEDURE()
  CODE
  RETURN SELF.parseErrorPos
!!!endregion
