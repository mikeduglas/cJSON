!** Dynamic string support.
!** 25.10.2024
!** mikeduglas@yandex.com
!** mikeduglas66@gmail.com


DynStr                        CLASS, TYPE, MODULE('dynstrclass.CLW'), LINK('dynstrclass.CLW')
ds                              &IDynStr, PROTECTED

Construct                       PROCEDURE()
Destruct                        PROCEDURE()

GetInterface                    PROCEDURE(), *IDynStr

!IDynStr implementation

Str                             PROCEDURE(),STRING
CStr                            PROCEDURE(),*CSTRING
Kill                            PROCEDURE()                       ! Disposes an underlying buffer
Cat                             PROCEDURE(STRING)                 ! Concatenates a string
Cat                             PROCEDURE(*STRING)                ! Concatenates a string
Cat                             PROCEDURE(*DECIMAL)               ! Concatenates a decimal
Cat                             PROCEDURE(*CSTRING)               ! Concatenates a cstring
CatNum                          PROCEDURE(LONG,USHORT Base=10)    ! Concatenates an integer
CatChr                          PROCEDURE(BYTE chr)               ! Concatenates a character
Clip                            PROCEDURE()                       ! CLIP()
Trunc                           PROCEDURE(LONG newlen)            ! Truncates a string
StrLen                          PROCEDURE(),LONG
BinaryToText                    PROCEDURE(STRING)                 ! Expand ' to '' etc.
TextToBinary                    PROCEDURE(STRING,LONG pos=1),LONG ! Lex a string (return 0 if failed)
PadTo                           PROCEDURE(LONG)
CopyTo                          PROCEDURE(*STRING,LONG limit=-1)
CopyTo                          PROCEDURE(*CSTRING,LONG limit=-1)
GetChr                          PROCEDURE(LONG index),BYTE
CStrRef                         PROCEDURE(),LONG
CDynStrRef                      PROCEDURE(),LONG
Release                         PROCEDURE()

! new stuff
Replace                         PROCEDURE(STRING pPattern, STRING pReplacement), STRING, PROC
                              END



TStringBuilder                CLASS, TYPE, MODULE('dynstrclass.CLW'), LINK('dynstrclass.CLW')
memBlock                        LONG, PRIVATE !- an address of memory block
blockSize                       LONG, PRIVATE !- capacity
dataSize                        LONG, PRIVATE !- string length
extraSize                       LONG, PRIVATE !- a number of bytes added when a reallocation is needed

Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL
Init                            PROCEDURE(LONG pStrLen)
Kill                            PROCEDURE()
Str                             PROCEDURE(), STRING
Cat                             PROCEDURE(STRING pStr)                 ! Concatenates a string
Cat                             PROCEDURE(*STRING pStr)                ! Concatenates a string
Reset                           PROCEDURE()
StrLen                          PROCEDURE(), LONG
                              END
