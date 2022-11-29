!** Dynamic string support.
!** 29.11.2022
!** mikeduglas@yandex.com
!** mikeduglas66@gmail.com


  MEMBER

  INCLUDE('dynstr.inc'), ONCE
  INCLUDE('dynstrclass.inc'), ONCE

  MAP
    MODULE('CW runtime')
      _malloc(LONG pSize), LONG, NAME('_malloc')
      _realloc(LONG pMemBlock, LONG pSize), LONG, NAME('_realloc')
      _memcpy(LONG pDest, LONG pSrc, LONG pCount), LONG, NAME('_memcpy'), PROC
      _free(LONG pMemBlock),NAME('_free')
    END
    MODULE('cjson')
      json::DebugInfo(STRING pMsg)
    END
  END

!!!region IDynStr
DynStr.Construct    PROCEDURE()
  CODE
  SELF.ds &= NewDynStr()
  
DynStr.Destruct     PROCEDURE()
  CODE
  SELF.Kill()
  DisposeDynStr(SELF.ds)
  
DynStr.GetInterface           PROCEDURE()
  CODE
  RETURN SELF.ds
  
DynStr.Str          PROCEDURE()
  CODE
  RETURN SELF.ds.Str()
  
DynStr.CStr         PROCEDURE()
  CODE
  RETURN SELF.ds.CStr()
  
DynStr.Kill         PROCEDURE()
  CODE
  SELF.ds.Kill()
  
DynStr.Cat          PROCEDURE(STRING s)
  CODE
  SELF.ds.Cat(s)
  
DynStr.Cat          PROCEDURE(*STRING s)
  CODE
  SELF.ds.Cat(s)
  
DynStr.Cat          PROCEDURE(*DECIMAL s)
  CODE
  SELF.ds.Cat(s)
  
DynStr.Cat          PROCEDURE(*CSTRING s)
  CODE
  SELF.ds.Cat(s)
  
DynStr.CatNum       PROCEDURE(LONG l,USHORT Base=10)
  CODE
  SELF.ds.CatNum(l, Base)
  
DynStr.CatChr       PROCEDURE(BYTE chr)
  CODE
  SELF.ds.CatChr(chr)
  
DynStr.Clip         PROCEDURE()
  CODE
  SELF.ds.Clip()
  
DynStr.Trunc        PROCEDURE(LONG newlen)
  CODE
  SELF.ds.Trunc(newlen)
  
DynStr.StrLen       PROCEDURE()
  CODE
  RETURN SELF.ds.StrLen()
  
DynStr.BinaryToText PROCEDURE(STRING s)
  CODE
  SELF.ds.BinaryToText(s)
  
DynStr.TextToBinary PROCEDURE(STRING s,LONG pos=1)
  CODE
  RETURN SELF.ds.TextToBinary(s, pos)
  
DynStr.PadTo        PROCEDURE(LONG l)
  CODE
  SELF.ds.PadTo(l)
  
DynStr.CopyTo       PROCEDURE(*STRING s,LONG limit=-1)
  CODE
  SELF.ds.CopyTo(s, limit)
  
DynStr.CopyTo              PROCEDURE(*CSTRING s,LONG limit=-1)
  CODE
  SELF.ds.CopyTo(s, limit)
  
DynStr.GetChr       PROCEDURE(LONG index)
  CODE
  RETURN SELF.ds.GetChr(index)
  
DynStr.CStrRef             PROCEDURE()
  CODE
  RETURN SELF.ds.CStrRef()
  
DynStr.CDynStrRef   PROCEDURE()
  CODE
  RETURN SELF.ds.CDynStrRef()
  
DynStr.Release      PROCEDURE()
  CODE
  SELF.ds.Release()
  
DynStr.Replace      PROCEDURE(STRING pPattern, STRING pReplacement)
tmp                   DynStr

frompos               LONG, AUTO
topos                 LONG, AUTO

srcLen                LONG, AUTO
patternLen            LONG, AUTO


  CODE
  srcLen = SELF.StrLen()
  patternLen = LEN(pPattern)
  
  frompos = 1
  LOOP
    topos = INSTRING(pPattern, SELF.Str(), 1, frompos)
    IF topos = 0
      IF frompos <= srcLen
        tmp.Cat(SUB(SELF.Str(), frompos, srcLen - frompos + 1))
      END
      
      BREAK
    END
    
    IF frompos < topos
      tmp.Cat(SUB(SELF.Str(), frompos, topos - frompos))
    END
    
    tmp.Cat(pReplacement)
    frompos = topos + patternLen
  END
  
  SELF.Trunc(0)
  SELF.Cat(tmp.Str())
  
  RETURN SELF.Str()
!!!endregion IDynStr

!!!region TStringBuilder
TStringBuilder.Construct      PROCEDURE()
  CODE
  SELF.memBlock = 0
  SELF.blockSize = 0
  SELF.dataSize = 0
  SELF.extraSize = 256
  
TStringBuilder.Destruct       PROCEDURE()
  CODE
  SELF.Kill()
  
TStringBuilder.Init           PROCEDURE(LONG pStrLen)
  CODE
  IF SELF.memBlock = 0
    SELF.memBlock = _malloc(pStrLen)
    IF SELF.memBlock
      SELF.blockSize = pStrLen
    ELSE
      !- _malloc failed
      json::DebugInfo('[TStringBuilder.Init] _malloc failed.')
    END
  ELSE
    !- already allocated
    json::DebugInfo('[TStringBuilder.Init] already allocated.')
  END
  
TStringBuilder.Kill           PROCEDURE()
  CODE
  IF SELF.memBlock
    _free(SELF.memBlock)
    SELF.memBlock = 0
  END
  SELF.blockSize = 0
  SELF.dataSize = 0
  
TStringBuilder.Str            PROCEDURE()
strRef                          &STRING, AUTO
  CODE
  IF SELF.memBlock AND SELF.dataSize
    strRef &= (SELF.memBlock) &':'& SELF.dataSize
    RETURN strRef
  ELSE
    RETURN ''
  END
  
TStringBuilder.Cat            PROCEDURE(STRING pStr)
  CODE
  SELF.Cat(pStr)

TStringBuilder.Cat            PROCEDURE(*STRING pStr)
newMemBlock                     LONG, AUTO
newBlockSize                    LONG, AUTO
newDataSize                     LONG, AUTO
  CODE
  IF SIZE(pStr) = 0
    RETURN
  END
  
  IF SELF.memBlock
    newDataSize = SELF.dataSize + SIZE(pStr)
    IF newDataSize > SELF.blockSize
      newMemBlock = _realloc(SELF.memBlock, newDataSize+SELF.extraSize)
      IF newMemBlock
        SELF.memBlock = newMemBlock
        SELF.blockSize = newDataSize+SELF.extraSize
      ELSE
        !- _realloc failed
        json::DebugInfo('[TStringBuilder.Cat] _realloc failed.')
        RETURN
      END
    END
    _memcpy(SELF.memBlock + SELF.dataSize, ADDRESS(pStr), SIZE(pStr))
    SELF.dataSize = newDataSize
  ELSE
    !- not allocated yet
    json::DebugInfo('[TStringBuilder.Cat] buffer not allocated yet.')
  END
  
TStringBuilder.StrLen         PROCEDURE()
  CODE
  RETURN SELF.dataSize
!!!endregion