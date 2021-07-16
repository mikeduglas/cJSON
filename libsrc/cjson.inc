!** cJSON for Clarion v1.17
!** 15.07.2021
!** mikeduglas@yandex.com
!** mikeduglas66@gmail.com


  INCLUDE('svapi.inc'), ONCE
  INCLUDE('dynstrclass.inc'), ONCE

  MAP
    MODULE('cjson')

!!!<summary>a wrapper of OutputDebugString api.</summary>
json::DebugInfo   PROCEDURE(STRING pMsg)

!!!<summary>Removes all whitespeces from the string.</summary>
json::Minify  PROCEDURE(*STRING pJson)
      
!!!<summary>Recursively compare two items for equality. If either a or b is NULL or invalid, they will be considered unequal.</summary>
!!!<param name="case_sensitive">determines if object keys are treated case sensitive (true) or case insensitive (false).</param>
!!!<returns>true if items are equal.</returns>
json::Compare PROCEDURE(*cJSON a, *cJSON b, BOOL case_sensitive), BOOL

!!!<summary>Create a cJSON item of null type.</summary>
json::CreateNull  PROCEDURE(), *cJSON

!!!<summary>Create a cJSON item of boolean type with true value.</summary>
json::CreateTrue  PROCEDURE(), *cJSON

!!!<summary>Create a cJSON item of boolean type with false value.</summary>
json::CreateFalse PROCEDURE(), *cJSON

!!!<summary>Create a cJSON item of boolean type.</summary>
!!!<param name="b">item value</param>
json::CreateBool  PROCEDURE(BOOL b), *cJSON

!!!<summary>Create a cJSON item of numeric type.</summary>
!!!<param name="num">item value</param>
json::CreateNumber    PROCEDURE(REAL num), *cJSON

!!!<summary>Create a cJSON item of string type.</summary>
!!!<param name="str">item value</param>
json::CreateString    PROCEDURE(STRING str), *cJSON

!!!<summary>Create a cJSON item of raw type.</summary>
!!!<param name="rawJson">item value</param>
json::CreateRaw   PROCEDURE(STRING rawJson), *cJSON

!!!<summary>Create a cJSON array.</summary>
json::CreateArray PROCEDURE(), *cJSON

!!!<summary>Create a cJSON object.</summary>
json::CreateObject    PROCEDURE(), *cJSON

!!!<summary>Create a string where valuestring references a string so it will not be freed by Delete.</summary>
json::CreateStringReference   PROCEDURE(*STRING str), *cJSON

!!!<summary>Create an object that only references it's elements so they will not be freed by Delete.</summary>
json::CreateObjectReference   PROCEDURE(*cJSON child), *cJSON

!!!<summary>Create an arrray that only references it's elements so they will not be freed by Delete.</summary>
json::CreateArrayReference    PROCEDURE(*cJSON child), *cJSON

!!!<summary>Create an Array of LONGs.>/summary>
json::CreateIntArray  PROCEDURE(LONG[] numbers), *cJSON

!!!<summary>Create an Array of REALs.</summary>
json::CreateDoubleArray   PROCEDURE(REAL[] numbers), *cJSON

!!!<summary>Create an Array of STRINGs.</summary>
json::CreateStringArray   PROCEDURE(STRING[] strings), *cJSON

!!!<summary>Create an object from GROUP.</summary>
json::CreateObject    PROCEDURE(*GROUP grp, BOOL pNamesInLowerCase = TRUE, <STRING options>), *cJSON

!!!<summary>Create an array from QUEUE.</summary>
json::CreateArray PROCEDURE(*QUEUE que, BOOL pNamesInLowerCase = TRUE, <STRING options>), *cJSON

!!!<summary>Create an array from FILE's RECORD and optionally blobs and memos),
!!! string and numeric arrays are allowed; Blobs and Memos aren't.
!!! File must be OPENed and SET before calling this method.</summary>
json::CreateArray PROCEDURE(*FILE pFile, BOOL pNamesInLowerCase = TRUE, <STRING options>, BOOL pWithBlobs = FALSE), *cJSON

!!!<summary>Converts input string from one encoding to another.</summary>
!!!<param name="pInput">Input string.</param>
!!!<param name="pInputCodepage">Input code page, like CP_ACP, CP_UTF8.</param>
!!!<param name="pOutputCodepage">Output code page; pass -1 to convert to UTF16.</param>
json::ConvertEncoding PROCEDURE(STRING pInput, UNSIGNED pInputCodepage, UNSIGNED pOutputCodepage), STRING
!!!<summary>Converts input string from utf-8.</summary>
json::FromUtf8    PROCEDURE(STRING pInput, UNSIGNED pCodepage = CP_ACP), STRING
!!!<summary>Converts input string to utf-8.</summary>
json::ToUtf8  PROCEDURE(STRING pInput, UNSIGNED pCodepage = CP_ACP), STRING

!!!<summary>Returns a string where each character in form of \uXXXX.</summary>
json::StringToULiterals   PROCEDURE(STRING pInput, UNSIGNED pInputCodepage = CP_ACP), STRING
 
!!!<summary>Reads data from the specified file.</summary>
json::LoadFile    PROCEDURE(STRING pFilename), *STRING

!!!<summary>Writes data to the specified file.</summary>
json::SaveFile    PROCEDURE(STRING pFilename, STRING pData), BOOL, PROC
    END
  END

!cJSON Types
cJSON_Type                    EQUATE(LONG)
cJSON_Invalid                 EQUATE(0000000000b)   !0
cJSON_False                   EQUATE(0000000001b)   !1
cJSON_True                    EQUATE(0000000010b)   !2
cJSON_NULL                    EQUATE(0000000100b)   !4
cJSON_Number                  EQUATE(0000001000b)   !8
cJSON_String                  EQUATE(0000010000b)   !16
cJSON_Array                   EQUATE(0000100000b)   !32
cJSON_Object                  EQUATE(0001000000b)   !64
cJSON_Raw                     EQUATE(0010000000b)   !128  raw json

cJSON_IsReference             EQUATE(0100000000b)   !256
cJSON_StringIsConst           EQUATE(1000000000b)   !512
cJSON_StringIsNotConst        EQUATE(0111111111b)   !511

!Limits how deeply nested arrays/objects can be before cJSON rejects to parse them.
!This is to prevent stack overflows.
CJSON_NESTING_LIMIT           EQUATE(1000)  !not used for now

cJSON                         CLASS, TYPE, MODULE('cjson.clw'),LINK('cjson.clw')
!next/prev allow you to walk array/object chains. Alternatively, use GetArraySize/GetArrayItem/GetObjectItem
next                            &cJSON, PRIVATE
prev                            &cJSON, PRIVATE

!An array or object item will have a child pointer pointing to a chain of the items in the array/object
child                           &cJSON, PRIVATE

!The type of the item, as above
type                            cJSON_Type, PRIVATE

!The item's string, if type==cJSON_String  and type == cJSON_Raw
valuestring                     &STRING, PRIVATE
!writing to valueint is DEPRECATED, use cJSON_SetNumberValue instead
valueint                        LONG, PRIVATE
!The item's number, if type==cJSON_Number
valuedouble                     REAL, PRIVATE

!The item's name string, if this item is the child of, or is in the list of subitems of an object
name                            &STRING, PRIVATE

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL

!!!<returns>a reference to previous item.</returns>
GetPrevious                     PROCEDURE(), *cJSON

!!!<returns>a reference to next item.</returns>
GetNext                         PROCEDURE(), *cJSON

!!!<returns>a reference to child item.</returns>
GetChild                        PROCEDURE(), *cJSON

!!!<returns>item name.</returns>
GetName                         PROCEDURE(), STRING

!!!<summary>Change item name.</summary>
!!!<param name="pNewName">new item name.</param>
SetName                         PROCEDURE(STRING pNewName)

!!!<returns>item type.</returns>
GetType                         PROCEDURE(), cJSON_Type

!!!<summary>Change item type.</summary>
!!!<param name="pType">new item type.</param>
SetType                         PROCEDURE(cJSON_Type pType)

!!!<summary>Render a cJSON entity to text for transfer or storage.</summary>
!!!param name="pFormat">true to format an output.>/param>
!!!<returns>a string representation of the object.</returns>
ToString                        PROCEDURE(BOOL pFormat = FALSE), STRING

!!!<summary>Render a cJSON entity to text for transfer or storage. All strings will be converted to utf-8.</summary>
!!!param name="pFormat">true to format an output.>/param>
!!!param name="pCodepage">Original code page.>/param>
!!!<returns>a string representation of the object.</returns>
ToUtf8                          PROCEDURE(BOOL pFormat = FALSE, LONG pCodepage), STRING

!!!<summary>Delete a cJSON entity and all subentities.</summary>
Delete                          PROCEDURE()

!!!<returns>the number of items in an array (or object).</returns>
GetArraySize                    PROCEDURE(BOOL recurse = FALSE), LONG

!!!<summary>Retrieve an array element.</summary>
!!!<param name="index">an index in the array.</param>
!!!<returns>an array element at specified index.</returns>
GetArrayItem                    PROCEDURE(LONG index), *cJSON

!!!<summary>Get a child item of the onject.</summary>
!!!<param name="itemName">an item name to get.</param>
!!!<param name="caseSensitive">comparison rule</param>
!!!<returns>a child item of the onject.</returns>
GetObjectItem                   PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE), *cJSON

!!!<summary>Read string item value.</summary>
!!!<returns>>item value.</returns>
GetStringValue                  PROCEDURE(), STRING

!!!<summary>Change item value.</summary>
!!!<param name="pNewValue">new value.</param>
SetStringValue                  PROCEDURE(STRING pNewValue)

!!!<summary>Read numeric item value.</summary>
!!!<returns>>item value.</returns>
GetNumberValue                  PROCEDURE(), REAL

!!!<summary>Change item value.</summary>
!!!<param name="pNewValue">new value.</param>
SetNumberValue                  PROCEDURE(REAL pNewValue)

!!!<returns>true if the item is invalid.</summary>
IsInvalid                       PROCEDURE(), BOOL
!!!<returns>true if the item is boolean false.</summary>
IsFalse                         PROCEDURE(), BOOL
!!!<returns>true if the item is boolean true.</summary>
IsTrue                          PROCEDURE(), BOOL
!!!<returns>true if the item is boolean.</summary>
IsBool                          PROCEDURE(), BOOL
!!!<returns>true if the item is null.</summary>
IsNull                          PROCEDURE(), BOOL
!!!<returns>true if the item is a number.</summary>
IsNumber                        PROCEDURE(), BOOL
!!!<returns>true if the item is a string.</summary>
IsString                        PROCEDURE(), BOOL
!!!<returns>true if the item is an array.</summary>
IsArray                         PROCEDURE(), BOOL
!!!<returns>true if the item is an object.</summary>
IsObject                        PROCEDURE(), BOOL
!!!<returns>true if the item is a raw json string.</summary>
IsRaw                           PROCEDURE(), BOOL

!!!<summary>Append an item to the array.</summary>
!!!<param name="item">item to append</param>
AddItemToArray                  PROCEDURE(*cJSON item)

!!!<summary>Append an item to the object.</summary>
!!!<param name="itemName">item name to append</param>
!!!<param name="item">item to append</param>
AddItemToObject                 PROCEDURE(STRING itemName, *cJSON item)

!!!<summary>Append an item to the object.
!!! Use this when string is definitely const (i.e. a literal, or as good as), and will definitely survive the cJSON object. 
!!! WARNING: When this function was used, make sure to always check that BAND(item.type, cJSON_StringIsConst) is zero before 
!!! writing to item.name.</summary>
!!!<param name="itemName">item name to append</param>
!!!<param name="item">item to append</param>
AddItemToObjectCS               PROCEDURE(*STRING itemName, *cJSON item)

!!!<summary>Append reference to item to the array.
!!! Use this when you want to add an existing cJSON to a new cJSON,
!!! but don't want to corrupt your existing cJSON.</summary>
!!!<param name="item">item to append</param>
AddItemReferenceToArray         PROCEDURE(*cJSON item)

!!!<summary>Append reference to item to the object.
!!! Use this when you want to add an existing cJSON to a new cJSON,
!!! but don't want to corrupt your existing cJSON.</summary>
!!!<param name="itemName">item name to append</param>
!!!<param name="item">item to append</param>
AddItemReferenceToObject        PROCEDURE(STRING itemName, *cJSON item)

!!!<summary>Detatch an item from Arrays/Objects.<summary>
!!!<param name="item">an item to detach.</param>
!!!>returns>detached item</returns>
DetachItemViaPointer            PROCEDURE(*cJSON item), *cJSON

!!!<summary>Detatch an item from array.<summary>
!!!<param name="which">an item index to detach.</param>
!!!>returns>detached item</returns>
DetachItemFromArray             PROCEDURE(LONG which), *cJSON

!!!<summary>Remove an item from array.<summary>
!!!<param name="which">an item index to remove.</param>
DeleteItemFromArray             PROCEDURE(LONG which)

!!!<summary>Detach an item from object.<summary>
!!!<param name="itemName">an item name to detach.</param>
!!!<param name="caseSensitive">comparison rule</param>
!!!>returns>detached item</returns>
DetachItemFromObject            PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE), *cJSON

!!!<summary>Remove an item from object.<summary>
!!!<param name="itemName">an item name to remove.</param>
!!!<param name="caseSensitive">comparison rule</param>
DeleteItemFromObject            PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)


!!!<summary>Insert an item into the array, and shifts pre-existing items to the right.</summary>
!!!<param name="which">index of inserting element.</param>
!!!<param name="newitem">a reference to inserting element.</param>
InsertItemInArray               PROCEDURE(LONG which, cJSON newitem)

!!!<summary>Replace an item in the object</summary>
!!!<param name="item">the item to be replaced.</param>
!!!<param name="replacement">replacement.</param>
!!!returns>false if item is not a child of self.</returns>
ReplaceItemViaPointer           PROCEDURE(*cJSON item, *cJSON replacement), BOOL, PROC

!!!<summary>Replace an item in the array</summary>
!!!<param name="which">index of an array element to be replaced.</param>
!!!<param name="newitem">replacement.</param>
ReplaceItemInArray              PROCEDURE(LONG which, *cJSON newitem)

!!!<summary>Replace an item in the object</summary>
!!!<param name="itemName">name of an item to be replaced.</param>
!!!<param name="newitem">replacement.</param>
!!!<param name="caseSensitive">comparison rule</param>
ReplaceItemInObject             PROCEDURE(STRING itemName, *cJSON newitem, BOOL caseSensitive = FALSE)

!!!<summary>Duplicate a cJSON item.</summary>
!!!<param name="recurse">when true, it will duplicate any children.</param>
!!!<returns>a new, identical cJSON item in new memory that will need to be released.</returns>
Duplicate                       PROCEDURE(BOOL recurse), *cJSON

!!!<summary>Adds null item.</summary>
!!!<param name="name">item name</param>
!!!<returns>a reference to added item or NULL on failure.</returns>
AddNullToObject                 PROCEDURE(STRING name), *cJSON, PROC

!!!<summary>Adds true item.</summary>
!!!<param name="name">item name</param>
!!!<returns>a reference to added item or NULL on failure.</returns>
AddTrueToObject                 PROCEDURE(STRING name), *cJSON, PROC

!!!<summary>Adds false item.</summary>
!!!<param name="name">item name</param>
!!!<returns>a reference to added item or NULL on failure.</returns>
AddFalseToObject                PROCEDURE(STRING name), *cJSON, PROC

!!!<summary>Adds boolean item.</summary>
!!!<param name="name">item name</param>
!!!<param name="boolean">item value</param>
!!!<returns>a reference to added item or NULL on failure.</returns>
AddBoolToObject                 PROCEDURE(STRING name, BOOL boolean), *cJSON, PROC

!!!<summary>Adds numeric item.</summary>
!!!<param name="name">item name</param>
!!!<param name="number">item value</param>
!!!<returns>a reference to added item or NULL on failure.</returns>
AddNumberToObject               PROCEDURE(STRING name, REAL number), *cJSON, PROC

!!!<summary>Adds string item.</summary>
!!!<param name="name">item name</param>
!!!<param name="value">item value</param>
!!!<returns>a reference to added item or NULL on failure.</returns>
AddStringToObject               PROCEDURE(STRING name, STRING value), *cJSON, PROC

!!!<summary>Adds raw json item.</summary>
!!!<param name="name">item name</param>
!!!<param name="raw">item value</param>
!!!<returns>a reference to added item or NULL on failure.</returns>
AddRawToObject                  PROCEDURE(STRING name, STRING raw), *cJSON, PROC

!!!<summary>Adds an object.</summary>
!!!<param name="name">object name</param>
!!!<returns>a reference to added object or NULL on failure.</returns>
AddObjectToObject               PROCEDURE(STRING name), *cJSON  !, PROC

!!!<summary>Adds an array.</summary>
!!!<param name="name">array name</param>
!!!<returns>a reference to added array or NULL on failure.</returns>
AddArrayToObject                PROCEDURE(STRING name), *cJSON  !, PROC

!!!<summary>save json object to a GROUP.</summary>
!!!<param name="grp">receiver</param>
!!!<param name="matchByFieldNumber">if true then group fields are assigned by their position</param>
!!!<param name="options">json string which defines field converting options.
!!! options - json string, examples:
!!! '{{"name":"DOB", "format":"@d17"}': convert numeric json "dob" field to string(@d17) (iow call FORMAT(value, @d17)
!!! '{{"name":"DOB", "deformat":"@d17"}': convert string(@d17) json "dob" field to Clarion DATE (iow call DEFORMAT(value, @d17)
!!! use field name w/o prefix.
!!! alowed multiply fields, in this case use array of objects:
!!! '[{{"name":"DOB", "format":"@d17"}, {{"name":"LastVisit", "format":"@d17"}]': converts DOB and LastVisit as string(@d17)
!!!</param>
!!!<returns>true on success, false otherwise</returns>
ToGroup                         PROCEDURE(*GROUP grp, BOOL matchByFieldNumber = FALSE, <STRING options>), BOOL, PROC

!!!<summary>save json array to a QUEUE.</summary>
!!!<param name="que">receiver</param>
!!!<param name="matchByFieldNumber">if true then queue fields are assigned by their position</param>
!!!<param name="options">json string which defines field converting options</param>
!!!<returns>true on success, false otherwise</returns>
ToQueue                         PROCEDURE(*QUEUE que, BOOL matchByFieldNumber = FALSE, <STRING options>), BOOL, PROC

!!!<summary>save json array to a FILE's RECORD and optionally in blobs/memos.
!!! pFile must allow ADD(). Any ADD() errors are logged in debugview.
!!!</summary>
!!!<param name="pFile">receiver</param>
!!!<param name="matchByFieldNumber">if true then FILE fields are assigned by their position</param>
!!!<param name="options">json string which defines field converting options</param>
!!!<returns>true on success, false otherwise</returns>
ToFile                          PROCEDURE(*FILE pFile, BOOL matchByFieldNumber = FALSE, <STRING options>, BOOL pWithBlobs = FALSE), BOOL, PROC

!!!<summary>recursively finds an item with passed name.</summary>
!!!<param name="itemName">the name of json object</param>
!!!<param name="caseSensitive">comparison rule</param>
!!!<returns>a reference to the object, or NULL.</returns>
FindObjectItem                  PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE), *cJSON

!!!<summary>recursively finds an array with passed name, and returns an element with passed index.</summary>
!!!<param name="arrayName">the name of json array</param>
!!!<param name="itemIndex">element index in the array</param>
!!!<param name="caseSensitive">comparison rule</param>
!!!<returns>a reference to the element, or NULL.</returns>
FindArrayItem                   PROCEDURE(STRING arrayName, LONG itemIndex, BOOL caseSensitive = FALSE), *cJSON

!!!<summary>recursively finds an item and returns its value (numeric, boolean or string).</summary>
!!!<param name="itemName">the name of json item</param>
!!!<param name="caseSensitive">comparison rule</param>
!!!<returns>item value, or blank string !if the item not found, or its type is not numeric, boolean or string.</returns>
GetValue                        PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE), ?
                              END


cJSONFactory                  CLASS, TYPE, MODULE('cjson.clw'),LINK('cjson.clw')
parseErrorString                STRING(20), PRIVATE
parseErrorPos                   LONG, PRIVATE

codePage                        LONG  ! -1 by default. Set it to CP_ACP prior Parse call to convert all strings from utf8 to ascii

Construct                       PROCEDURE()

!!!<summary>Parse an object - create a new root, and populate.</summary>
!!!<param name="json">json string</param>
!!!<returns>a reference to cJSON instance, or NULL on fail.</returns>
Parse                           PROCEDURE(STRING json), *cJSON

!!!<summary>Parse an object - create a new root, and populate.</summary>
!!!<param name="pFileName">json file</param>
!!!<returns>a reference to cJSON instance, or NULL on fail.</returns>
ParseFile                       PROCEDURE(STRING pFileName), *cJSON

!!!<summary>Writes json into a group.</summary>
!!!<param name="json">json string</param>
!!!<param name="grp">receiver</param>
!!!<param name="matchByFieldNumber">if true then group fields are assigned by their position</param>
!!!<param name="options">json string which defines field converting options</param>
!!!<returns>true on success, false otherwise</returns>
ToGroup                         PROCEDURE(STRING json, *GROUP grp, BOOL matchByFieldNumber = FALSE, <STRING options>), BOOL, PROC

!!!<summary>Writes json into a queue.</summary>
!!!<param name="json">json string</param>
!!!<param name="que">receiver</param>
!!!<param name="matchByFieldNumber">if true then queue fields are assigned by their position</param>
!!!<param name="options">json string which defines field converting options</param>
!!!<returns>true on success, false otherwise</returns>
ToQueue                         PROCEDURE(STRING json, *QUEUE que, BOOL matchByFieldNumber = FALSE, <STRING options>), BOOL, PROC

!!!<summary>Writes json into a FILE.</summary>
!!!<param name="json">json string</param>
!!!<param name="pFile">receiver</param>
!!!<param name="matchByFieldNumber">if true then FILE fields are assigned by their position</param>
!!!<param name="options">json string which defines field converting options</param>
!!!<param name="pWithBlobs">writes into BOLObs and MEMOs</param>
!!!<returns>true on success, false otherwise</returns>
ToFile                          PROCEDURE(STRING json, *FILE pFile, BOOL matchByFieldNumber = FALSE, <STRING options>, BOOL pWithBlobs = FALSE), BOOL, PROC

!!!<summary>For analysing failed parses. You'll probably need to look a few chars back to make sense of it. </summary>
!!!<returns>a part of json string where parse error happened.</returns>
GetError                        PROCEDURE(), STRING

!!!<summary>For analysing failed parses. You'll probably need to look a few chars back to make sense of it. </summary>
!!!<returns>a character position in json string where parse error happened.</returns>
GetErrorPosition                PROCEDURE(), LONG
                              END
