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
v1.17 (15.07.2021)
- NEW: cJSONFactory.ParseFile method.

v1.16 (15.04.2020)
- FIX: convertion from UTF-16 didn't work.

v1.15 (10.04.2020)
- NEW: support for DIMed groups inside a group (thanks to Carlos Gutiérrez);
- NEW: parser option 'isqueue' for dynamic queues inside a queue (thanks to Carlos Gutiérrez);
- NEW: ComplexQueueTest example demonstrates new features.
- NEW: "Create array of arrays" topic in [How-To](https://github.com/mikeduglas/cJSON/blob/master/howto.md)

v1.14 (02.12.2019)
- FIX: cJSON.GetValue() always returned 0 for booleans

v1.13 (30.04.2019)
- CHG: json::ConvertEncoding converts to UTF-16, if you pass pOutputCodepage=1.

v1.12.1 (19.04.2019)
- CHG: cJSONFactory.ToFile() now has "pWithBlobs" parameter as well.

v1.12 (18.04.2019)
- NEW: json::LoadFile and json::SaveFile static functions;
- CHG: json::CreateArray(FILE) and cJSON.ToFile() now have "pWithBlobs" parameter to process BLOBs and MEMOs;
- CHG: MinifyTest and FileTest have been changed to demonstrate new features.

v1.11 (29.11.2018)
- NEW: parser option 'instance' which allows to load arrays into nested queues:
```
option = '{{"name":"Phones", "instance":'& INSTANCE(PhoneQ) &'}'  !- group field 'Phones' is a reference to PhoneQ queue
```

v1.10 (16.11.2018)
- FIX: json::ConvertEncoding could return string of wrong size.

v1.09 (29.10.2018)  
- NEW: encoding functions:
```
!- Converts input string from one encoding to another.
json::ConvertEncoding PROCEDURE(STRING pInput, UNSIGNED pInputCodepage, UNSIGNED pOutputCodepage), STRING

!- Converts input string from utf-8.
json::FromUtf8    PROCEDURE(STRING pInput, UNSIGNED pCodepage = CP_ACP), STRING

!- Converts input string to utf-8.
json::ToUtf8  PROCEDURE(STRING pInput, UNSIGNED pCodepage = CP_ACP), STRING
```
- NEW: static function to convert string value to a sequence of unicode literals (i.e. \uXXXX\uYYYY):
```
json::StringToULiterals   PROCEDURE(STRING pInput, UNSIGNED pInputCodepage = CP_ACP), STRING
```
- NEW: cJSON.ToUtf8(format, codepage) method, similar to ToString(), but all strings are converted to utf-8.
- NEW: "novapochta" example demonstrates how to use encoding features.


v1.08 (24.10.2018)
- FIX: Parse method could miss invalid input. For example, input string '400 Bad request' transformed into numeric json with value 400.

v1.07 (08.10.2018)
- CHG: GetArraySize method now can return total number of children.
- CHG: Support for nested GROUPs:
```
person                          GROUP
Name                              STRING(20)
Address                           GROUP
Line1                               STRING(20)
Line2                               STRING(20)
                                  END
Contact                           GROUP
email                               STRING(64)
web                                 STRING(64)
Phone                               GROUP
Home                                  STRING(20)
Mobile                                STRING(20)
                                    END
                                  END
Gender                            STRING(1)
                                END
```
- NEW: NestedGroupTest example added.


v1.06 (02.10.2018)
- NEW: the method GetValue recursively finds an item and returns its value.
- CHG: Removed deprecated methods from cJSONFactory.
- CHG: xml comments.


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