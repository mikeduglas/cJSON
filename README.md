# cJSON for Clarion
[cJSON](https://github.com/DaveGamble/cJSON) is ultralightweight JSON parser in ANSI C. This repository contains cJSON port to Clarion.

## Requirements  
C6.3 and newer.

## How to install
Hit the 'Clone or Download' button and select 'Download Zip'.  
Now unzip cJSON-master.zip into a temporary folder somewhere.

Copy the contents of "libsrc" folder into %ClarionRoot%\Accessory\libsrc\win  
where %ClarionRoot% is the folder into which you installed Clarion.

## How to use
The documentation can be found [here](https://github.com/mikeduglas/cJSON/blob/master/howto.md)


## Contacts
- <mikeduglas@yandex.ru>
- <mikeduglas66@gmail.com>

## Price
Free

## Version history
v1.05 (29.09.2018)
- FIX: the methods AddItemToObjectCS, AddItemReferenceToArray, AddItemReferenceToObject now work as expected.  
- CHG: ToDo document was removed as it is completed.  
- NEW: HowTo.htm

v1.04 (28.09.2018)
- NEW: FindObjectItem method recursively finds an item with passed name.
- NEW: FindArrayItem method recursively finds an array with passed name, and returns an element with passed index.
- NEW: The documentation [How-To](https://github.com/mikeduglas/cJSON/blob/master/howto.md)
  

v1.03 (27.09.2018)
- FIX: the bug in parse_number function.
- NEW: "jsonname" parameter for "options" (this allows to get rid of NAME attribute on entity fields):
```
'{{"name":"Description", "jsonname":"error_description"}' means that entity field 'Description' corresponds to json field 'error_description'.  
```
see OptionsTest.clw for details.  

- [Performance tests](https://github.com/mikeduglas/cJSON/blob/master/performancetests/PerformanceTests.md)


v1.02 (26.09.2018)
- NEW: static functions, which can be called instead of cJSONFactory methods:
```
      json::CreateNull(), *cJSON
      json::CreateTrue(), *cJSON
      json::CreateFalse(), *cJSON
      json::CreateBool(BOOL b), *cJSON
      json::CreateNumber(REAL num), *cJSON
      json::CreateString(STRING str), *cJSON
      json::CreateRaw(STRING rawJson), *cJSON
      json::CreateArray(), *cJSON
      json::CreateObject(), *cJSON
      json::CreateStringReference(*STRING str), *cJSON
      json::CreateObjectReference(*cJSON child), *cJSON
      json::CreateArrayReference(*cJSON child), *cJSON
      json::CreateIntArray(LONG[] numbers), *cJSON
      json::CreateDoubleArray(REAL[] numbers), *cJSON
      json::CreateStringArray(STRING[] strings), *cJSON
      json::CreateObject(*GROUP grp, BOOL pNamesInLowerCase = TRUE, <STRING options>), *cJSON
      json::CreateArray(*QUEUE que, BOOL pNamesInLowerCase = TRUE, <STRING options>), *cJSON
      json::CreateArray(*FILE pFile, BOOL pNamesInLowerCase = TRUE, <STRING options>), *cJSON
```
- NEW: "options" parameter in CreateObject(GROUP), CreateArray(QUEUE/FILE), ToGroup(), ToQueue, ToFILE(), 
it allows to override default parser/converter behaviour.  
"options" format:
{{"name":"fieldname", "param1":value1, "param2":value2...}, where 
 - "fieldname" - GROUP/QUEUE/FILE field name without prefix
 - "paramN" - parameter name. Available parameters are: "format", "deformat", "ignore".
 - "valueN" - parameter value. For "format" and "deformat" parameters the value is picture token (for example, "@d17"), for "ignore" parameter the value can be true or false (no quotes).
```
'{{"name":"Password", "ignore":true}' means Password field will not included in json.  
'{{"name":"LastVisitDate", "format":"@d10-"}' means LastVisitDate (LONG field with Clarion date) will be included in json as "2018-09-26".
```

v1.01 (25.09.2018)
- FIX: bugs in DetachItemViaPointer method

v1.00 (23.09.2018)
- FIX: Parse could fail
- NEW: ToGroup method converts json object into a GROUP
- NEW: ToQueue method converts json array into a QUEUE
- NEW: ToFile method converts json array into a FILE
- NEW: Duplicate method creates a new, identical cJSON item
- NEW: json::Minify function removes whitespaces and comments
- NEW: json::Compare function compares two cJSON items
- CHG: new and modified examples

v0.99 (21.09.2018)
- FIX: array handling
- FIX: Unicode handling
- NEW: new examples

v0.98 (20.09.2018)