# cJSON for Clarion
[cJSON](https://github.com/DaveGamble/cJSON) is ultralightweight JSON parser in ANSI C. This repository contains cJSON port to Clarion.

## Requirements  
- C6.3 and newer.

## Dependencies
- [printf](https://github.com/mikeduglas/printf)

## How to install
Hit the 'Clone or Download' button and select 'Download Zip'.  
Now unzip cJSON-master.zip into a temporary folder somewhere.

Copy the contents of "libsrc" folder into %ClarionRoot%\Accessory\libsrc\win  
where %ClarionRoot% is the folder into which you installed Clarion.

## How to use
The documentation can be found [here](https://github.com/mikeduglas/cJSON/blob/master/howto.md).  
[Field rules summary](https://github.com/mikeduglas/cJSON/blob/master/RuleOptions.md).  

## JSONPath
JSONPath is a way for picking parts out of a JSON structure.  
An example of selecting all books in a store cheapier than 10:
```
resCount = jRoot.FindPathContext('$["store"]["book"][?(@.price << 10)]', output)
```
You can find jpathtest example in examples folder.  
JSONPath syntax is described [here](https://github.com/mikeduglas/cjson/blob/master/jsonpath.md).


## Contacts
- <mikeduglas@yandex.ru>
- <mikeduglas66@gmail.com>

## Price
Free

## Version history
v1.35 (02.01.2023)
- NEW: cJSONFactory.depthLimit property: arrays/objects depth limit for json parsing.
- NEW: cJSONFactory.ParseCallback virtual method.

v1.34 (17.12.2022)
- NEW: "Auto" field rule allows to manually set group field value.
- NEW: TCJsonRuleHelper.AutoCB callback method to set the values of "auto" fields. 
- CHG: Updated base64Test example shows an "Auto" rule usage.
- CHG: Removed CWUTIL dependency.
- FIX: "JsonName" field rule was unaccessible from rule helper callbacks.
- FIX: Unassigned referenced fields (&STRING, &QUEUE) produced json strings like '\u0000\u0000\u0000\u0000'.

v1.33 (16.12.2022)
- NEW: "IsFile" field rule allows to load file content. In addition "IsBase64":true encodes file content.
- NEW: TCJsonRuleHelper.ApplyCB callback method to customize json values. 
- CHG: base64Test example shows new features.

v1.32 (15.12.2022)
- NEW: "IsBase64" field rule. Use it when you want to either encode binary data to json, or decode binary data from json.
- NEW: cJSON.ToQueueField, cJSONFactory.ToQueueField methods load simple array into specific queue field. 
- NEW: "FieldNumber" field rule is now supported in the scenarios where simple arrays should be loaded into a queue field other than first one.
- CHG: cJSON now depends on [printf](https://github.com/mikeduglas/printf).

v1.31 (14.12.2022)
- NEW: json::CreateSimpleArray static function creates json array from queue's field.
- NEW: "FieldNumber" field rule: tells the json builder to create an array from a queue's field rather than from a queue itself. This rule works together with "Instance" and "IsQueue" rules.

v1.30 (12.12.2022)
- NEW: Field rule inheritance: field rules inherit the default rule.
- NEW: RuleInheritanceTest example.
- NEW: TCJsonRuleHelper class allows to customize field rules.
- NEW: "RuleHelper" field rule: pass an address of TCJsonRuleHelper instance.
- NEW: RuleHelperTest example.
- NEW: "IgnoreEmptyObject" field rule: do not include empty objects ({}) into the resulting json.
- NEW: "IgnoreEmptyArray" field rule: do not include empty arrays ([]) into the resulting json.
- NEW: cJSON.HasItem method.
- NEW: cJSON.Compare method (a wrapper for a static json::Compare).

v1.29 (09.12.2022)
- NEW: "FormatLeft" field rule: same as "Format", except it produces left justified string.
- NEW: Overloaded cJSONFactory methods that accept *STRING and *IDynStr as input json.

v1.28 (07.12.2022)
- FIX: Nested GROUPs could be causing wrong json.
- CHG: cJSONPath class removed from cjson.inc.
- NEW: JSONPath support added as a separate stuff (cjsonpath.inc).

v1.27 (29.11.2022)
- NEW: field rules "IgnoreZero" and "IgnoreFalse".
- CHG: significantly increased the speed of ToString/ToUtf8.
- NEW: cJSONPath class (beta, experimental).

v1.26 (23.11.2022)
- CHG: "Instance" option is now supported for QUEUE referencies in json::CreateObject(*GROUP,BOOL,STRING) and similar functions.
```
jPerson &= json::CreateObject(PersonGrp,, '[{{"name":"Phones", "instance":'& Phones::Inst &'},{{"name":"Addresses", "instance":'& Addr::Inst &'}]')
```
- NEW: field rule "IsRaw" saves a field value in json "as is".


v1.25 (22.11.2022)
- FIX: Ignored field ("ignore":true) could cause next field appearing 2 times in json.

v1.24 (20.11.2022)
- CHG: Field rules behavior has been changed. Now, the general rule applies only to those fields for which there is no explicit rule.  
In the example below only "Expired" field will be saved in json, because the "ignore" attribute will be applied to all other fields.
```
[{"name":"*", "ignore":true}, {"name":"Expired", "IsBool":true}]
```

v1.23 (17.11.2022)
- NEW: field rule "IsBool" forces a bool item to be created.
```
Users                         GROUP
Login                           STRING('Igor')
FlagClose                       BYTE(FALSE)
                              END
jParam                        &cJSON
  CODE
  jParam &= json::CreateObject(Users,,'{"name":"FlagClose","isBool":true}')
  !- jParam.ToString():  {"login":"Igor","flagclose":false}
  jParam.Delete()
```

v1.22 (10.09.2022)
- CHG: cJSON.ToUtf8 now accepts optional codepage argument.
- CHG: cJSONFactory.Parse and cJSONFactory.ParseFile now accept optional codepage argument.

v1.21 (09.09.2022)
- NEW: cJSON.GetStringRef returns a reference to a string item value.
- NEW: cJSON.GetStringSize returns a size of a string item value.

v1.20 (28.08.2022)
- NEW: field rule "IsStringRef" applies to &STRING fields.
```
TestGroup                       GROUP
SomeFileData                      &STRING
                                END
jitem                           &cJSON
  CODE
  TestGroup.SomeFileData &= NEW(STRING(LEN('Some File Data')))
  TestGroup.SomeFileData = 'Some File Data'
  jitem &= json::CreateObject(TestGroup, , '{{"name":"SomeFileData", "IsStringRef":true}')
```

v1.19 (09.12.2021)
- NEW: field rule "EmptyString" applies to strings and string arrays:
  - "null": null objects will be created for empty strings or array elements.
  - "ignore": empty strings and array elements will be ignored.
- CHG: json::CreateStringArray now accepts optional parameter "pIfEmpty", 
which controls how empty array elements will be processed. Availale values are "null" and "ignore".

v1.18 (04.12.2021)
- NEW: field rule "ArraySize" allows to limit an array size:
```
!- this will create "labels" array with 1 element, even labels field is declared as DIM(3)
jitem &= json::CreateArray(Item, , '{{"name":"labels", "arraysize":1}')
```

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