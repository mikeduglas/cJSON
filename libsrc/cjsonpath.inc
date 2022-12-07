!** cJSON for Clarion v1.28
!** 07.12.2022
!** mikeduglas@yandex.com
!** mikeduglas66@gmail.com


  INCLUDE('cjson.inc'), ONCE

  MAP
    MODULE('cjsonpath.clw')
      !- cJSON extension. Usage:
      !- resCount = FindPathContext(jRoot, '$[store][*][price]', output)
      !- resCount = jRoot.FindPathContext('$[store][*][price]', output)
      FindPathContext(cJSON pItem, STRING pExpr, *TCJsonPathResultAccumulator pOutput), LONG, PROC
    END
  END

typCJsonPathResult            QUEUE, TYPE
object                          &cJSON
path                            &TStringBuilder
                              END

TCJsonPathResultAccumulator   CLASS, TYPE, MODULE('cjsonpath.clw'),LINK('cjsonpath.clw')
q                               &typCJsonPathResult, PRIVATE
Construct                       PROCEDURE()
Destruct                        PROCEDURE(), VIRTUAL
AddResult                       PROCEDURE(*cJSON pItem, STRING pPath)
GetCount                        PROCEDURE(), LONG
GetObject                       PROCEDURE(LONG pIndex), *cJSON
GetPath                         PROCEDURE(LONG pIndex), STRING
                              END
