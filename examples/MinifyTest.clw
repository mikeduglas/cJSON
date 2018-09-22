!Test json::Minify function
!
  PROGRAM
  INCLUDE('cjson.inc')
  INCLUDE('svapi.inc'), ONCE
  MAP
    MinifyTest()

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
  MinifyTest()

MinifyTest                    PROCEDURE()
fileContent                     &STRING
  CODE
  !- load file
  fileContent &= LoadFile('test.json')
  IF NOT fileContent &= NULL
    !- minify (remove all whilespaces, and comments)
    json::Minify(fileContent)
    
    !- save minified file (do CLIP to not save trailing spaces)
    SaveFile('test_minified.json', CLIP(fileContent))
    
    !- dispose dynamic buffer
    DISPOSE(fileContent)
    MESSAGE('test_minified.json created.')
  ELSE
    MESSAGE('Error loading test.json.')
  END
  
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

