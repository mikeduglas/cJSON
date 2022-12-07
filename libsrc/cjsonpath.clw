!** cJSON for Clarion v1.28
!** 07.12.2022
!** mikeduglas@yandex.com
!** mikeduglas66@gmail.com


  MEMBER

  INCLUDE('cjsonpath.inc'), ONCE

TCJsonInterpreter             CLASS, TYPE   !, MODULE('cjsonpath.clw'),LINK('cjsonpath.clw')
output                          &TCJsonPathResultAccumulator, PRIVATE
Init                            PROCEDURE(*TCJsonPathResultAccumulator pOutput), PRIVATE
Trace                           PROCEDURE(STRING pExpr, *cJSON pItem, STRING pPath), PRIVATE
Store                           PROCEDURE(STRING pPath, *cJSON pItem), PRIVATE
WalkCallback                    PROCEDURE(STRING pMember, STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath), TYPE, PRIVATE
Walk                            PROCEDURE(STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath, WalkCallback pCallback), PRIVATE
WalkWild                        PROCEDURE(STRING pMember, STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath), PRIVATE
WalkTree                        PROCEDURE(STRING pMember, STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath), PRIVATE
WalkFiltered                    PROCEDURE(STRING pMember, STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath), PRIVATE
Slice                           PROCEDURE(STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath), PRIVATE
FromList                        PROCEDURE(STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath), PRIVATE
                              END

typJsonNames                  QUEUE, TYPE
name                            STRING(32)
                              END

  MAP
    IsPrimitive(cJSON pItem), BOOL, PRIVATE
    HasMember(cJSON pItem, STRING pMember), BOOL, PRIVATE
    GetMemberValue(cJSON pItem, STRING pMember), *cJSON, PRIVATE

    NormalizeExpr(*STRING pExpr), PRIVATE
    ParseArraySlice(STRING pExpr, *LONG pStart, *LONG pEnd), PRIVATE
    EvaluateExpr(STRING pExpr, *cJSON pItem, STRING pPath), STRING, PRIVATE
    EvaluateBoolExpr(STRING pExpr, *cJSON pItem, STRING pPath), STRING, PRIVATE
    ExtractNamesFromExpr(STRING pExpr, *typJsonNames pQNames), PRIVATE  !- extracts all names from '@.<name>'
    ExtractNamesFromList(STRING pExpr, *typJsonNames pQNames), PRIVATE  !- extract all names from 'name1, name2...'

    INCLUDE('printf.inc'), ONCE
  END

!!!region cJSON extensions
IsPrimitive                   PROCEDURE(cJSON pItem)
  CODE
  RETURN CHOOSE(NOT (pItem.IsArray() OR pItem.IsObject()))
  
HasMember                     PROCEDURE(cJSON pItem, STRING pMember)
jChild                          &cJSON, AUTO
  CODE
  IF pItem.IsObject()
    jChild &= pItem.GetObjectItem(pMember)
  ELSIF pItem.IsArray() AND NUMERIC(pMember)
    jChild &= pItem.GetArrayItem(pMember)
  ELSE
    jChild &= NULL
  END
  RETURN CHOOSE(NOT jChild &= NULL)
  
GetMemberValue                PROCEDURE(cJSON pItem, STRING pMember)
jChild                          &cJSON, AUTO
  CODE
  IF pItem.IsObject()
    jChild &= pItem.GetObjectItem(pMember)
  ELSIF pItem.IsArray() AND NUMERIC(pMember)
    jChild &= pItem.GetArrayItem(pMember)
  ELSE
    jChild &= NULL
  END
  RETURN jChild
  
FindPathContext               PROCEDURE(cJSON pItem, STRING pExpr, *TCJsonPathResultAccumulator pOutput)
pathInterpreter                 TCJsonInterpreter
  CODE
  pathInterpreter.Init(pOutput)
  
  !- convert bracket notation ["items"][..]["price"] to items;..;price notation.
  NormalizeExpr(pExpr)

  !- remove heading $ or $;
  IF LEN(CLIP(pExpr)) >= 1 AND pExpr[1] = '$'
    IF LEN(CLIP(pExpr)) >= 2 AND pExpr[2] = ';'
      pExpr = pExpr[3 : SIZE(pExpr)]
    ELSE
      pExpr = pExpr[2 : SIZE(pExpr)]
    END
  END

  pathInterpreter.Trace(pExpr, pItem, '$')
  
  RETURN pOutput.GetCount()
!!!endregion
  
!!!region helper functions
NormalizeExpr                 PROCEDURE(*STRING pExpr)
nExprSize                       LONG, AUTO
sResult                         STRING(SIZE(pExpr)), AUTO
ch                              STRING(1), AUTO
bFirstSquareBracketFound        BOOL(FALSE)
bOpenSquareBracketFound         BOOL(FALSE) ! [
bOpenBracketCount               LONG(0)
bTwoDotsFound                   BOOL(FALSE)
bAsteriskFound                  BOOL(FALSE)
bQuoteFound                     BOOL(FALSE)

i                               LONG, AUTO
j                               LONG, AUTO
  CODE
  !- 1st step: remove unnecessary space chars
  nExprSize = LEN(CLIP(pExpr))
  CLEAR(sResult)
  j = 0 
  LOOP i=1 TO nExprSize
    ch = pExpr[i]
    CASE ch
    OF '['
      IF NOT bFirstSquareBracketFound
        !- add ';' instead of 1st [
        j+=1
        sResult[j] = ';'
        bFirstSquareBracketFound = TRUE
      END
      bOpenSquareBracketFound = TRUE
    OF ']'
      IF bOpenSquareBracketFound
        j+=1
        sResult[j] = ';'
        bOpenSquareBracketFound = FALSE
      END
    OF '('
      IF bOpenSquareBracketFound
        j+=1
        sResult[j] = '('
        bOpenBracketCount += 1
      END
    OF ')'
      IF bOpenSquareBracketFound AND bOpenBracketCount > 0
        j+=1
        sResult[j] = ')'
        bOpenBracketCount -= 1
      END
    OF ' '
      IF bOpenSquareBracketFound AND bOpenBracketCount=0
        !- skip space char if inside [] but not inside ()
      ELSIF bOpenBracketCount > 0
        j+=1
        sResult[j] = ch
      END
    ELSE
      j+=1
      sResult[j] = ch
    END
  END
  
  !- 2nd step: remove quotes around node names
  pExpr = sResult
  nExprSize = LEN(CLIP(pExpr))
  CLEAR(sResult)
  j = 0 
  LOOP i=1 TO nExprSize
    ch = pExpr[i]
    IF ch='"' AND ((i>1 AND pExpr[i-1]=';') OR (i<nExprSize AND pExpr[i+1]=';'))
      !- skip ';"' or '";'
    ELSE
      j+=1
      sResult[j] = ch
    END
  END
  
  !- 3rd step: replace double ';;' with single ';'
  pExpr = sResult
  nExprSize = LEN(CLIP(pExpr))
  CLEAR(sResult)
  j = 0 
  LOOP i=1 TO nExprSize
    ch = pExpr[i]
    IF ch=';' AND (i<nExprSize AND pExpr[i+1]=';')
      !- skip ';;'
    ELSE
      j+=1
      sResult[j] = ch
    END
  END
  pExpr = sResult
  
  !- 4th step: remove terminated ';'
  IF pExpr[LEN(CLIP(pExpr))] = ';'
    pExpr[LEN(CLIP(pExpr))] = ''
  END

ParseArraySlice               PROCEDURE(STRING pExpr, *LONG pStart, *LONG pEnd)
colonPos                        LONG, AUTO
  CODE
  pStart = 0
  pEnd = 0
  colonPos = INSTRING(':', pExpr, 1, 1)
  IF colonPos
    pStart = LEFT(pExpr[1 : colonPos-1])
    pEnd = LEFT(pExpr[colonPos+1 : LEN(CLIP(pExpr))])
  END
  
EvaluateExpr                  PROCEDURE(STRING pExpr, *cJSON pItem, STRING pPath)
ds                              DynStr
  CODE
  !- supported tokens in pExpr:
  !- '@.length': current item, array size.
  
  ds.Cat(pExpr)
  ds.Replace('"', '''') !- replace " with '
  ds.Replace('@.length', pItem.GetArraySize())  !- replace '@.length' with actual array length
  
  RETURN EVALUATE(ds.Str())
  
EvaluateBoolExpr              PROCEDURE(STRING pExpr, *cJSON pItem, STRING pPath)
ds                              DynStr
qChildNames                     QUEUE(typJsonNames).
jChild                          &cJSON
i                               LONG, AUTO
  CODE
  !- supported tokens in pExpr:
  !- '@.<name1>','@.<name2>'...: child names.

  !- get all child names used in the expr.
  ExtractNamesFromExpr(pExpr, qChildNames)
  
  ds.Cat(pExpr)
  
  ds.Replace('"', '''') !- replace " with '

  LOOP i=1 TO RECORDS(qChildNames)
    GET(qChildNames, i)
    jChild &= pItem.GetObjectItem(qChildNames.name)
    IF NOT jChild &= NULL
      IF jChild.IsString()
        ds.Replace(printf('@.%s', qChildNames.name), printf('%S', jChild.GetStringValue()))
      ELSIF jChild.IsNumber()
        ds.Replace(printf('@.%s', qChildNames.name), jChild.GetNumberValue())
      ELSIF jChild.IsTrue()
        ds.Replace(printf('@.%s', qChildNames.name), 1)
      ELSIF jChild.IsFalse()
        ds.Replace(printf('@.%s', qChildNames.name), 0)
      END
    ELSE
      printd('EvaluateBoolExpr: child "%s" not found.', qChildNames.name)
    END
  END
  
  RETURN EVALUATE(printf('CHOOSE(%s, ''true'', ''false'')', ds.Str()))
  
ExtractNamesFromExpr          PROCEDURE(STRING pExpr, *typJsonNames pQNames)
nExprSize                       LONG, AUTO
nStartPos                       LONG, AUTO
nEndPos                         LONG, AUTO
ch                              STRING(1), AUTO
bNameFound                      BOOL(FALSE)
i                               LONG, AUTO
  CODE
  FREE(pQNames)
  nExprSize = LEN(CLIP(pExpr))
  
  nStartPos = 1
  LOOP
    nStartPos = INSTRING('@.', pExpr, 1, nStartPos)
    IF nStartPos
      nStartPos += 2
!      nEndPos = STRPOS(pExpr[nStartPos : SIZE(pExpr)], '[^a-zA-Z0-9_]') !- find a pos of 1st not alphanum char.    I CAN'T MAKE STRPOS TO WORK!
      nEndPos = nExprSize
      LOOP i=nStartPos TO nExprSize
        ch = pExpr[i]
        CASE ch
        OF   'a' TO 'z'
        OROF 'A' TO 'Z'
        OROF '0' TO '0'
        OROF '_'
          !- continue
        ELSE
          !- non-alpha char found
          nEndPos = i-1
          BREAK
        END
      END
      
      pQNames.name = pExpr[nStartPos : nEndPos]
      ADD(pQNames)
    ELSE
      BREAK
    END
  END
  
ExtractNamesFromList          PROCEDURE(STRING pExpr, *typJsonNames pQNames)
ds                              DynStr
nExprSize                       LONG, AUTO
nStartPos                       LONG, AUTO
nEndPos                         LONG, AUTO
ch                              STRING(1), AUTO
bNameFound                      BOOL(FALSE)
i                               LONG, AUTO
  CODE
  FREE(pQNames)
  
  !- remove "
  ds.Cat(pExpr)
  ds.Replace('"', '')
  pExpr = ds.Str()
  
  nExprSize = LEN(CLIP(pExpr))
  nStartPos = 1
  LOOP
    nEndPos = INSTRING(',', pExpr, 1, nStartPos)
    IF nEndPos
      pQNames.name = LEFT(pExpr[nStartPos : nEndPos-1])
      ADD(pQNames)
      nStartPos = nEndPos+1
    ELSE
      !- no more commas
      pQNames.name = LEFT(pExpr[nStartPos : nExprSize])
      ADD(pQNames)
      BREAK
    END
  END
!!!endregion

!!!region TCJsonPathResultAccumulator
TCJsonPathResultAccumulator.Construct PROCEDURE()
  CODE
  SELF.q &= NEW typCJsonPathResult
  
TCJsonPathResultAccumulator.Destruct  PROCEDURE()
i                                       LONG, AUTO
  CODE
  LOOP i=RECORDS(SELF.q) TO 1 BY -1
    GET(SELF.q, i)
    IF NOT SELF.q.path &= NULL
      DISPOSE(SELF.q.path)
      SELF.q.path &= NULL
    END
    SELF.q.object &= NULL
    PUT(SELF.q)
  END
  FREE(SELF.q)
  DISPOSE(SELF.q)
  SELF.q &= NULL
  
TCJsonPathResultAccumulator.AddResult PROCEDURE(*cJSON pItem, STRING pPath)
  CODE
  CLEAR(SELF.q)
  SELF.q.object &= pItem
  SELF.q.path &= NEW TStringBuilder
  SELF.q.path.Init(SIZE(pPath))
  SELF.q.path.Cat(pPath)
  ADD(SELF.q)
  
TCJsonPathResultAccumulator.GetCount  PROCEDURE()
  CODE
  RETURN RECORDS(SELF.q)
  
TCJsonPathResultAccumulator.GetObject PROCEDURE(LONG pIndex)
  CODE
  GET(SELF.q, pIndex)
  IF NOT ERRORCODE()
    RETURN SELF.q.object
  ELSE
    printd('TCJsonPathResultAccumulator.GetObject(%i) out of range.', pIndex)
    RETURN NULL
  END
  
TCJsonPathResultAccumulator.GetPath   PROCEDURE(LONG pIndex)
  CODE
  GET(SELF.q, pIndex)
  IF NOT ERRORCODE()
    RETURN SELF.q.path.Str()
  ELSE
    printd('TCJsonPathResultAccumulator.GetPath(%i) out of range.', pIndex)
    RETURN ''
  END

!!!endregion

!!!region TCJsonInterpreter
TCJsonInterpreter.Init        PROCEDURE(*TCJsonPathResultAccumulator pOutput)
  CODE
  SELF.output &= pOutput
  
TCJsonInterpreter.Trace       PROCEDURE(STRING pExpr, *cJSON pItem, STRING pPath)
semicolonPos                    LONG, AUTO
atom                            STRING(SIZE(pExpr)), AUTO
tail                            STRING(SIZE(pExpr)), AUTO
  CODE
  IF NOT pExpr
    SELF.Store(pPath, pItem)
    RETURN
  END
  
  !- split expression into an atom (from start to the first ';') and a tail (everything after the first ';').
  semicolonPos = INSTRING(';', pExpr, 1, 1)
  IF semicolonPos
    atom = SUB(pExpr, 1, semicolonPos-1)
    tail = SUB(pExpr, semicolonPos+1, SIZE(pExpr))
  ELSE
    atom = pExpr
    tail = ''
  END

  IF NOT pItem &= NULL AND pItem.HasMember(atom)
    !- exact name of a child item.
    SELF.Trace(CLIP(tail), pItem.GetMemberValue(atom), printf('%s;%s', pPath, atom))
  ELSIF atom = '*'
    !- wildcard. All objects/elements regardless their names.
    SELF.Walk(CLIP(atom), CLIP(tail), pItem, pPath, WalkWild)
  ELSIF atom = '..'
    !- recursive descent.
    SELF.Trace(CLIP(tail), pItem, pPath)
    SELF.Walk(CLIP(atom), CLIP(tail), pItem, pPath, WalkTree)
  ELSIF LEN(CLIP(atom)) > 2 AND atom[1] = '(' AND atom[LEN(CLIP(atom))] = ')' !- [(exp)]
    !- (): script expression.
    semicolonPos = INSTRING(';', pPath, -1, LEN(CLIP(pPath)))
    SELF.Trace(EvaluateExpr(atom, pItem, pPath[semicolonPos+1 : LEN(CLIP(pPath))]) & ';' & tail, pItem, pPath)
  ELSIF LEN(CLIP(atom)) > 3 AND atom[1] = '?' AND atom[2] = '(' AND atom[LEN(CLIP(atom))] = ')' !- [?(exp)]
    !- ?(): applies a filter (script) expression.
    SELF.Walk(CLIP(atom), CLIP(tail), pItem, pPath, WalkFiltered)
  ELSIF MATCH(CLIP(atom), '^[0-9]+:?[0-9]*$', Match:Regular)  !- [start:end]
    !- array slice operator.
    SELF.Slice(CLIP(atom), CLIP(tail), pItem, pPath)
  ELSIF INSTRING(',', atom, 1, 1) !- [name1,name2,...]
    SELF.FromList(CLIP(atom), CLIP(tail), pItem, pPath)
  END
  
TCJsonInterpreter.Store       PROCEDURE(STRING pPath, *cJSON pItem)
  CODE
  IF pPath
    SELF.output.AddResult(pItem, pPath)
  END
  
TCJsonInterpreter.Walk        PROCEDURE(STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath, WalkCallback pCallback)
i                               LONG, AUTO
jChild                          &cJSON, AUTO
  CODE
  IF pItem.IsPrimitive()
    RETURN
  ELSIF pItem.IsArray()
    LOOP i=1 TO pItem.GetArraySize()
      SELF.pCallback(i, pLoc, pExpr, pItem, pPath)
    END
  ELSIF pItem.IsObject()
    LOOP i=1 TO pItem.GetArraySize()
      jChild &= pItem.GetArrayItem(i)
      IF NOT jChild &= NULL
        SELF.pCallback(jChild.GetName(), pLoc, pExpr, pItem, pPath)
      END
    END
  END
  
TCJsonInterpreter.WalkWild    PROCEDURE(STRING pMember, STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath)
  CODE
  SELF.Trace(printf('%s;%s', pMember, pExpr), pItem, pPath)

TCJsonInterpreter.WalkTree    PROCEDURE(STRING pMember, STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath)
jChild                          &cJSON, AUTO
  CODE
  jChild &= pItem.GetMemberValue(pMember)
  IF NOT jChild &= NULL AND NOT jChild.IsPrimitive()
    SELF.Trace(printf('..;%s', pExpr), jChild, printf('%s;%s', pPath, pMember))
  END
  
TCJsonInterpreter.WalkFiltered    PROCEDURE(STRING pMember, STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath)
nStartPos                           LONG, AUTO
bResult                             STRING(7), AUTO !- "true"/"false"
  CODE
  nStartPos = INSTRING('(', pLoc, 1, 1)
  ASSERT(nStartPos > 0)
  bResult = EvaluateBoolExpr(SUB(pLoc, nStartPos, SIZE(pLoc)), pItem.GetMemberValue(pMember), pPath)
  IF bResult = 'true'
    !- ok
    SELF.Trace(printf('%s;%s', pMember, pExpr), pItem, pPath)
  ELSIF bResult = 'false'
    !- filtered
  ELSE
    !- EVALUATE() error
    printd('TCJsonInterpreter.WalkFiltered(%s) failed: %s', pLoc, ERROR())
  END
  
TCJsonInterpreter.Slice       PROCEDURE(STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath)
nStartIndex                     LONG, AUTO
nEndIndex                       LONG, AUTO
i                               LONG, AUTO
  CODE
  IF NOT pItem.IsArray()
    RETURN
  END
  
  ParseArraySlice(pLoc, nStartIndex, nEndIndex)
  LOOP i=nStartIndex TO nEndIndex
    SELF.Trace(printf('%i;%s', i, pExpr), pItem, pPath)
  END
  
TCJsonInterpreter.FromList    PROCEDURE(STRING pLoc, STRING pExpr, *cJSON pItem, STRING pPath)
qNames                          QUEUE(typJsonNames).
i                               LONG, AUTO
  CODE
  ExtractNamesFromList(pLoc, qNames)
  LOOP i=1 TO RECORDS(qNames)
    GET(qNames, i)
    SELF.Trace(printf('%s;%s', qNames.name, pExpr), pItem, pPath)
  END
!!!endregion
