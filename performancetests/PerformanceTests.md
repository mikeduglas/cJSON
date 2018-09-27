##The goal of these tests
The goal is to see what time taken to load (in other words parse) big json file.

I downloaded 'citylots.json' (~190 MB) [from this site](https://github.com/zemirco/sf-city-lots-json),  
(you need to press Download button to get zip file, then extract citylots.json to project folder).

##Test results
###cJSON v1.03
the code in \performance tests\cJSON_PerfTest.clw.  
cJSONfactory.Parse(json) results (I ran it 3 times), the values are Clarion time (in hundredths of second):  
```
[13476] [cJSON] cJSON Parse time: 6577
[1360] [cJSON] cJSON Parse time: 6410
[15176] [cJSON] cJSON Parse time: 6449
```

###jFiles v1.67
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

###Clarion 10
JSONDataClass has no method to fully parse entire json, or I can't find it.