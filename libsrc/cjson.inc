  MAP
    MODULE('cjson')
      json::DebugInfo(STRING pMsg)
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
CJSON_NESTING_LIMIT           EQUATE(1000)


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

GetPrevious                     PROCEDURE(), *cJSON
GetNext                         PROCEDURE(), *cJSON
GetChild                        PROCEDURE(), *cJSON

GetName                         PROCEDURE(), STRING
SetName                         PROCEDURE(STRING pNewName)

GetType                         PROCEDURE(),cJSON_Type

!Render a cJSON entity to text for transfer/storage.
ToString                        PROCEDURE(BOOL pFormat = FALSE), STRING

!Delete a cJSON entity and all subentities.
Delete                          PROCEDURE()

!Returns the number of items in an array (or object).
GetArraySize                    PROCEDURE(), LONG

!Retrieve item number "index" from array "array". Returns NULL if unsuccessful.
GetArrayItem                    PROCEDURE(LONG index), *cJSON

!Get item "string" from object. Case insensitive.
GetObjectItem                   PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE), *cJSON

!Check if the item is a string and return its valuestring
GetStringValue                  PROCEDURE(), STRING

!Change string value
SetStringValue                  PROCEDURE(STRING pNewValue)

GetNumberValue                  PROCEDURE(), REAL
SetNumberValue                  PROCEDURE(REAL pNewValue)


!These functions check the type of an item
IsInvalid                       PROCEDURE(), BOOL
IsFalse                         PROCEDURE(), BOOL
IsTrue                          PROCEDURE(), BOOL
IsBool                          PROCEDURE(), BOOL
IsNull                          PROCEDURE(), BOOL
IsNumber                        PROCEDURE(), BOOL
IsString                        PROCEDURE(), BOOL
IsArray                         PROCEDURE(), BOOL
IsObject                        PROCEDURE(), BOOL
IsRaw                           PROCEDURE(), BOOL

!Append item to the specified array/object.
AddItemToArray                  PROCEDURE(cJSON item)
AddItemToObject                 PROCEDURE(STRING string, cJSON item)

!Use this when string is definitely const (i.e. a literal, or as good as), and will definitely survive the cJSON object. 
!WARNING: When this function was used, make sure to always check that (item->type & cJSON_StringIsConst) is zero before 
!writing to `item->string`
AddItemToObjectCS               PROCEDURE(STRING string, cJSON item)

!Append reference to item to the specified array/object. Use this when you want to add an existing cJSON to a new cJSON, but don't want to corrupt your existing cJSON.
AddItemReferenceToArray         PROCEDURE(*cJSON item)
AddItemReferenceToObject        PROCEDURE(STRING str, *cJSON item)

!Remove/Detatch items from Arrays/Objects.
DetachItemViaPointer            PROCEDURE(*cJSON item), *cJSON
DetachItemFromArray             PROCEDURE(LONG which), *cJSON
DeleteItemFromArray             PROCEDURE(LONG which)
DetachItemFromObject            PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE), *cJSON
DeleteItemFromObject            PROCEDURE(STRING itemName, BOOL caseSensitive = FALSE)

!Update array items.
InsertItemInArray               PROCEDURE(LONG which, cJSON newitem) !Shifts pre-existing items to the right.
ReplaceItemViaPointer           PROCEDURE(*cJSON item, *cJSON replacement), BOOL, PROC
ReplaceItemInArray              PROCEDURE(LONG which, *cJSON newitem)
ReplaceItemInObject             PROCEDURE(STRING str, *cJSON newitem, BOOL caseSensitive = FALSE)

!Duplicate a cJSON item
!Duplicate             PROCEDURE(BOOL recurse), *cJSON

!Duplicate will create a new, identical cJSON item to the one you pass, in new memory that will 
!need to be released. With recurse!=0, it will duplicate any children connected to the item.
!The item->next and ->prev pointers are always zero on return from Duplicate.
!Recursively compare two cJSON items for equality. If either a or b is NULL or invalid, they will be considered unequal. 
!case_sensitive determines if object keys are treated case sensitive (1) or case insensitive (0)
!Compare               PROCEDURE(cJSON that, BOOL caseSensitive), BOOL

!Minify                PROCEDURE(STRING json)

!Helper functions for creating and adding items to an object at the same time. 
!They return the added item or NULL on failure.
AddNullToObject                 PROCEDURE(STRING name), *cJSON, PROC
AddTrueToObject                 PROCEDURE(STRING name), *cJSON, PROC
AddFalseToObject                PROCEDURE(STRING name), *cJSON, PROC
AddBoolToObject                 PROCEDURE(STRING name, BOOL boolean), *cJSON, PROC
AddNumberToObject               PROCEDURE(STRING name, REAL number), *cJSON, PROC
AddStringToObject               PROCEDURE(STRING name, STRING value), *cJSON, PROC
AddRawToObject                  PROCEDURE(STRING name, STRING raw), *cJSON, PROC
AddObjectToObject               PROCEDURE(STRING name), *cJSON  !, PROC
AddArrayToObject                PROCEDURE(STRING name), *cJSON  !, PROC
                              END


cJSONFactory                  CLASS, TYPE, MODULE('cjson.clw'),LINK('cjson.clw')
parseErrorString                STRING(20), PRIVATE
parseErrorPos                   LONG, PRIVATE

!These calls create a cJSON item of the appropriate type.
CreateNull                      PROCEDURE(), *cJSON
CreateTrue                      PROCEDURE(), *cJSON
CreateFalse                     PROCEDURE(), *cJSON
CreateBool                      PROCEDURE(BOOL value), *cJSON
CreateNumber                    PROCEDURE(REAL num), *cJSON
CreateString                    PROCEDURE(STRING str), *cJSON
!raw json
CreateRaw                       PROCEDURE(STRING raw), *cJSON
CreateArray                     PROCEDURE(), *cJSON
CreateObject                    PROCEDURE(), *cJSON

!Create a string where valuestring references a string so 
!it will not be freed by Delete
CreateStringReference           PROCEDURE(*STRING str), *cJSON

!Create an object/arrray that only references it's elements so 
!they will not be freed by Delete
CreateObjectReference           PROCEDURE(*cJSON child), *cJSON
CreateArrayReference            PROCEDURE(*cJSON child), *cJSON

!These utilities create an Array of count items.
CreateIntArray                  PROCEDURE(LONG[] numbers), *cJSON
CreateDoubleArray               PROCEDURE(REAL[] numbers), *cJSON
CreateStringArray               PROCEDURE(STRING[] strings), *cJSON

!Clarion specific types: GROUP/QUEUE/FILE

!Create an object from simple GROUP (no nested GROUPS etc...),
!string and numeric arrays are allowed.
CreateObject                    PROCEDURE(*GROUP grp, BOOL pNamesInLowerCase = TRUE), *cJSON
!Create an array from simple QUEUE (no nested GROUPS etc...),
!string and numeric arrays are allowed.
CreateArray                     PROCEDURE(*QUEUE que, BOOL pNamesInLowerCase = TRUE), *cJSON
!Create an array from simple FILE's RECORD (no nested GROUPS etc...),
!string and numeric arrays are allowed; Blobs and Memos aren't.
!File must be OPENed and SET before calling this method.
CreateArray                     PROCEDURE(*FILE pFile, BOOL pNamesInLowerCase = TRUE), *cJSON

!Parse an object - create a new root, and populate.
Parse                           PROCEDURE(STRING value), *cJSON

!For analysing failed parses. This returns a parse error. You'll probably need to look a few chars back to make sense of it. 
!Defined when Parse() returns NULL. '' when Parse() succeeds.
GetError                        PROCEDURE(), STRING
GetErrorPosition                PROCEDURE(), LONG
                              END
