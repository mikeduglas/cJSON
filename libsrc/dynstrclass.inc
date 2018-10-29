DynStr              CLASS, TYPE, MODULE('dynstrclass.CLW'), LINK('dynstrclass.CLW')
ds                    &IDynStr, PROTECTED

Construct             PROCEDURE()
Destruct              PROCEDURE()

GetInterface          PROCEDURE(), *IDynStr

!IDynStr implementation

Str                   PROCEDURE(),STRING
CStr                  PROCEDURE(),*CSTRING
Kill                  PROCEDURE()                       ! Disposes an underlying buffer
Cat                   PROCEDURE(STRING)                 ! Concatenates a string
Cat                   PROCEDURE(*STRING)                ! Concatenates a string
Cat                   PROCEDURE(*DECIMAL)               ! Concatenates a decimal
Cat                   PROCEDURE(*CSTRING)               ! Concatenates a cstring
CatNum                PROCEDURE(LONG,USHORT Base=10)    ! Concatenates an integer
CatChr                PROCEDURE(BYTE chr)               ! Concatenates a character
Clip                  PROCEDURE()                       ! CLIP()
Trunc                 PROCEDURE(LONG newlen)            ! Truncates a string
StrLen                PROCEDURE(),LONG
BinaryToText          PROCEDURE(STRING)                 ! Expand ' to '' etc.
TextToBinary          PROCEDURE(STRING,LONG pos=1),LONG ! Lex a string (return 0 if failed)
PadTo                 PROCEDURE(LONG)
CopyTo                PROCEDURE(*STRING,LONG limit=-1)
CopyTo                PROCEDURE(*CSTRING,LONG limit=-1)
GetChr                PROCEDURE(LONG index),BYTE
CStrRef               PROCEDURE(),LONG
CDynStrRef            PROCEDURE(),LONG
Release               PROCEDURE()

! new stuff
Replace               PROCEDURE(STRING pPattern, STRING pReplacement), STRING, PROC
                    END
