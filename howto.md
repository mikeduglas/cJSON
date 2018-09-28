## Create json arrays
To create json array of strings like this
> ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
```
ArrayTest                     PROCEDURE()
dows                            &cJSON
strings                         STRING(9), DIM(7)
  CODE
  strings[1] = 'Monday'
  strings[2] = 'Tuesday'
  strings[3] = 'Wednesday'
  strings[4] = 'Thursday'
  strings[5] = 'Friday'
  strings[6] = 'Saturday'
  strings[7] = 'Sunday'
  
  dows &= json::CreateStringArray(strings)
  
  !dispose all cJSON objects at once
  dows.Delete()
```
For numeric arrays use json::CreateIntArray() or json::CreateDoubleArray().

## Create json objects
To create json object like this
> {"username":"LuckyGamer5371","balance":"$1,250.22","date":"28.09.2018","time":"19:44:38"}

declare a group and pass it to json::CreateObject(). To tweak resulting json use "options" parameter:
```
OptionsTest                   PROCEDURE
Account                         GROUP, PRE(ACC)
UserName                          STRING(20)
Password                          STRING(20)  !do not include in json
Balance                           REAL        !format as @N$9.2
LastVisitDate                     LONG        !format as @d17, item name in json must be "date"
LastVisitTime                     LONG        !format as @t8, item name in json must be "time"
                                END

object                          &cJSON
  CODE
  Account.UserName = 'LuckyGamer5371'
  Account.Password = '08AX08$tgeN'
  Account.Balance  = 1250.22
  Account.LastVisitDate = TODAY()
  Account.LastVisitTime = CLOCK()
  
  !we want following json:
  !UserName: as is
  !Password: do not include in json,                          option1 = {{"name":"Password", "ignore":true}
  !Balance: with currency symbol,                             option2 = {{"name":"Balance", "format":"@N$9.2"}
  !LastVisitDate: localized date string, name = "date",       option3 = {{"name":"LastVisitDate", "format":"@d17"}
  !LastVisitTime: localized time string, name = "time",       option4 = {{"name":"LastVisitTime", "format":"@t8"}
  !
  !Pass an array [option1, option2, option3, option4], each optionN describes one group field.
  !Do not forget to put 2 left curly braces.
  
  object &= json::CreateObject(Account, TRUE, '[{{"name":"Password", "ignore":true}, {{"name":"Balance", "format":"@N$9.2"}, {{"name":"LastVisitDate", "jsonname":"date", "format":"@d17"}, {{"name":"LastVisitTime", "jsonname":"time", "format":"@t8"}]')
  json::DebugInfo(object.ToString(FALSE))
  MESSAGE(object.ToString(TRUE))
  
  !dispose all cJSON objects at once
  object.Delete()
```

## Create complex json objects (not using GROUP/QUEUE/FILE)
To create json objects like this
```
{ 
 "name": "Jack (\"Bee\") Nimble", 
 "format": { 
  "type": "rect", 
  "width": 1920, 
  "height": 1080, 
  "interlace": false, 
  "frame rate": 24 
 }, 
 "days of week": ["Monday",  "Tuesday",  "Wednesday",  "Thursday",  "Friday",  "Saturday",  "Sunday"] 
}
```

first create empty root object:
```
  root &= json::CreateObject()
```
then child objects:
```
  !"format" object
  fmt &= json::CreateObject()
  fmt.AddStringToObject('type', 'rect')
  fmt.AddNumberToObject('width', 1920)  
  fmt.AddNumberToObject('height', 1080)  
  fmt.AddFalseToObject('interlace')
  fmt.AddNumberToObject('frame rate', 24)

  !"days of week" array
  dow &= json::CreateStringArray(strings)
```
and finally add children to the root:
```
  !add "name": "Jack (\"Bee\") Nimble" to root
  root.AddItemToObject('name', json::CreateString('Jack ("Bee") Nimble'))
  
  !add format object to root
  root.AddItemToObject('format', fmt)

  !add days array to root
  root.AddItemToObject('days of week', dow)
```

## Create array of objects
To create json array of object like this
> [{"username":"LuckyGamer5371","balance":"$1,250.22","date":"28.09.2018","time":"19:44:38"},
> {"username":"LuckyGamer7244","balance":"$2,000.00","date":"27.09.2018","time":"11:20:16"}]

declare a queue and pass it to json::CreateArray(). To tweak resulting json use "options" parameter:
```
  options = '[{{"name":"Password", "ignore":true}, {{"name":"Balance", "format":"@N$9.2"}, {{"name":"LastVisitDate", "jsonname":"date", "format":"@d17"}, {{"name":"LastVisitTime", "jsonname":"time", "format":"@t8"}]'
  root &= json::CreateArray(accounts, true, options)
```
You can pass a FILE to json::CreateArray as well.

## Parse json string
Declare an instance of cJSONFactory class and call its Parse method:
```
jsonFactory                     cJSONFactory
root                            &cJSON

  root &= jsonFactory.Parse(pJsonString)
```

## Get and Find objects
1. To get child object by name call GetObjectItem(childName):
> {"username":"LuckyGamer5371","balance":1250.22,"date":"28.09.2018","time":"19:44:38"}
```
item &= object.GetObjectItem('balance')
!display 1250.22
MESSAGE('Balance = '& item.GetNumberValue())
```

2. To get array element by index call GetArrayItem(index):
> ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
```
item &= array.GetArrayItem(2)
!display 'Tuesday'
MESSAGE('Day 2 = '& item.GetStringValue())
```

3. To find a child deep inside the object
```
{ 
 "menu": { 
  "id": "file", 
  "value": "File", 
  "popup": { 
   "menuitem": [{ 
     "value": "New", 
     "onclick": "CreateNewDoc()" 
    },  { 
     "value": "Open", 
     "onclick": "OpenDoc()" 
    },  { 
     "value": "Close", 
     "onclick": "CloseDoc()" 
    }]}}}
```

call FindObjectItem(childName), below we find "popup" child:
```
  popup &= object.FindObjectItem('popup')
```

4. To find an array element deep inside the object call FindArrayItem(arrayName, index):
```
   item &= object.FindArrayItem('menuitem', 2)
   !item contains 2nd element of "menuitem" array {"value": "Open", "onclick": "OpenDoc()"}
```
