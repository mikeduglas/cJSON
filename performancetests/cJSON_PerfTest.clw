!cJSON - performance test
!
  PROGRAM
  INCLUDE('cjson.inc')
  INCLUDE('svapi.inc'), ONCE
  MAP
    PerformanceTest()

    LoadFile(STRING pFilename), *STRING
    SaveFile(STRING pFilename, STRING pData), BOOL, PROC

    MODULE('WinAPI')
      winapi::CreateFile(*CSTRING,ULONG,ULONG,LONG,ULONG,ULONG,UNSIGNED=0),UNSIGNED,RAW,PASCAL,NAME('CreateFileA')
      winapi::CloseHandle(UNSIGNED),BOOL,PASCAL,PROC,NAME('CloseHandle')
      winapi::WriteFile(LONG, *STRING, LONG, *LONG, LONG),LONG,RAW,PASCAL,NAME('WriteFile')
      winapi::GetLastError(),lONG,PASCAL,NAME('GetLastError')
      winapi::GetFileSize(HANDLE hFile, *LONG FileSizeHigh),LONG,RAW,PASCAL,NAME('GetFileSize')
      winapi::ReadFile(HANDLE hFile, LONG lpBuffer, LONG dwBytes, *LONG dwBytesRead, LONG lpOverlapped),BOOL,RAW,PASCAL,NAME('ReadFile')
    END
  END

OS_INVALID_HANDLE_VALUE       EQUATE(-1)

  CODE
  PerformanceTest()

PerformanceTest               PROCEDURE()
fileName                        STRING('citylots.json') !downloaded from https://github.com/zemirco/sf-city-lots-json
jsonString                      &STRING
jsonFactory                     cJSONFactory
root                            &cJSON
Clock1                          LONG, AUTO
Clock2                          LONG, AUTO
  CODE
  !- load file
  jsonString &= LoadFile(fileName)
  IF jsonString &= NULL
    MESSAGE('Error loading '& fileName)
    RETURN
  END

  MESSAGE('Press OK to start.|Be sure DebugView is opened to see the result.')
  
  !start time
  Clock1 = CLOCK()
  
  !parse json string, get root object
  root &= jsonFactory.Parse(jsonString)
  
  !finish time
  Clock2 = CLOCK()

  !check for Parse errors
  IF root &= NULL
    !error parsing json
    MESSAGE('Syntax error near: '& jsonFactory.GetError() &'|at position '& jsonFactory.GetErrorPosition())
    RETURN
  END
  
  json::DebugInfo('cJSON Parse time: '& (Clock2 - Clock1))

  MESSAGE('Test completed')

  !test if we have valid json? Try to minify:
  json::Minify(jsonString)
    
  !- save minified file (do CLIP to not save trailing spaces)
  SaveFile('minified_'& fileName, CLIP(jsonString))
  MESSAGE('minified_'& fileName &' created.')

  !release dynamic buffer
  DISPOSE(jsonString)

  !dispose all cJSON objects at once
  root.Delete()
  
LoadFile                      PROCEDURE(STRING pFile)
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

SaveFile                      PROCEDURE(STRING pFilename, STRING pData)
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

