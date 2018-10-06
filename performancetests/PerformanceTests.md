## The goal of these tests
The goal is to see what time taken to load (in other words parse) big json file.

I downloaded 'citylots.json' (~190 MB) [from this site](https://github.com/zemirco/sf-city-lots-json),  
(you need to press Download button to get zip file, then extract citylots.json to project folder).

## Test results
### cJSON v1.03
the code in \performance tests\cJSON_PerfTest.clw.  
cJSONfactory.Parse(json) results (I ran it 3 times), the values are Clarion time (in hundredths of second):  
```
[13476] [cJSON] cJSON Parse time: 6577
[1360] [cJSON] cJSON Parse time: 6410
[15176] [cJSON] cJSON Parse time: 6449
```

### jFiles v1.67
the code in \performance tests\jFiles_App_PerfTest.app (the app was created in C10).  
JSONClass.LoadString(json) result:
```
Exception occurred at address 01008B41
Exception code C0000005: Access Violation

Call Stack:
01008B41  ClaRUN.dll:00008B41
0041121C  jFiles.CLW:1541 - JSONCLASS.ADDITEM
00412407  jFiles.CLW:742 - JSONCLASS.ENDARRAYLITERAL
00413E75  jFiles.CLW:457 - JSONCLASS.LOADSTRING(STRING,LONG)
004144AD  jFiles.CLW:350 - JSONCLASS.LOADSTRING(STRINGTHEORY,LONG)
0040903E  jFiles_App_PerfTest001.clw:34 - MAIN
00409277  jFiles_App_PerfTest.clw:55 - _main
010CF727  ClaRUN.dll:000CF727
010CF211  ClaRUN.dll:000CF211
77DC305A
```


This is not a surprise for me. Let's calculate the size of each JSONClass instance, created for each json object:
- JSONClass fields (variables) occupy 490 bytes;
- in every JSONClass.Construct() some dynamic queues and one StringTheory object are NEWed - 371 bytes;
- So 490 + 371 = 861 bytes. Every object! **23 times more than cJSON.**  
Consider json "[{1,2,3},{4,5,6},{7,8,9}]" produced from a queue with 3 records and 3 byte fields per record. We have here 13 json objects, or 13 * 861 = 11193 bytes.  
cJson for same string: 13 * 36 = 468 bytes.  
So, when I try to parse very big json file (hundredths of thousands objects), the program jFiles_App_PerfTest.app crashes.


### Clarion 10
JSONDataClass has no method to fully parse entire json, or I can't find it.