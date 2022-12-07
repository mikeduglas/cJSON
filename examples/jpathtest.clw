  PROGRAM

  INCLUDE('cjson.inc'), ONCE
  INCLUDE('cjsonpath.inc'), ONCE

  MAP
    INCLUDE('printf.inc'), ONCE

    PrintAllAuthors()
    PrintAllPrices()
    PrintCheapBooks(REAL pMaxPrice)
    PrintBooksByTitle(STRING pTitlePart)
    PrintAuthorsByCategory(STRING pCategory)
    PrintBicycleColors()
  END

jParser                       cJSONFactory
jRoot                         &cJSON
output                        TCJsonPathResultAccumulator
resCount                      LONG, AUTO

sResponse                     STRING( ''                                              |
                                      & '{{ "store": {{'                              |
                                      & '    "book": [ '                              |
                                      & '      {{ "category": "reference",'           |
                                      & '        "author": "Nigel Rees",'             |
                                      & '        "title": "Sayings of the Century",'  |
                                      & '        "price": 8.95'                       |
                                      & '      },'                                    |
                                      & '      {{ "category": "fiction",'             |
                                      & '        "author": "Evelyn Waugh",'           |
                                      & '        "title": "Sword of Honour",'         |
                                      & '        "price": 12.99'                      |
                                      & '      },'                                    |
                                      & '      {{ "category": "fiction",'             |
                                      & '        "author": "Herman Melville",'        |
                                      & '        "title": "Moby Dick",'               |
                                      & '        "isbn": "0-553-21311-3",'            |
                                      & '        "price": 8.99'                       |
                                      & '      },'                                    |
                                      & '      {{ "category": "fiction",'             |
                                      & '        "author": "J. R. R. Tolkien",'       |
                                      & '        "title": "The Lord of the Rings",'   |
                                      & '        "isbn": "0-395-19395-8",'            |
                                      & '        "price": 22.99'                      |
                                      & '      }'                                     |
                                      & '    ],'                                      |
                                      & '    "bicycle": {{'                           |
                                      & '      "color": "red",'                       |
                                      & '      "price": 19.95'                        |
                                      & '    }'                                       |
                                      & '  }'                                         |
                                      & '}'                                           |
                                      )

  CODE
  !- Parse json string
  jRoot &= jParser.Parse(sResponse)
  IF NOT jRoot &= NULL
    !- All book authors
    PrintAllAuthors()
    !- expected output:
    ! All authors:
    ! - Nigel Rees
    ! - Evelyn Waugh
    ! - Herman Melville
    ! - J. R. R. Tolkien
    
    !- Book prices in a store
    PrintAllPrices()
    !- expected output:
    ! All prices:
    ! - 8.95
    ! - 12.99
    ! - 8.99
    ! - 22.99
    ! - 19.95
    
    !- Books cheaper than 10 rubles
    PrintCheapBooks(10)
    !- expected output:
    ! Books cheaper 10 rubles:
    ! - {"category":"reference","author":"Nigel Rees","title":"Sayings of the Century","price":8.95}
    ! - {"category":"fiction","author":"Herman Melville","title":"Moby Dick","isbn":"0-553-21311-3","price":8.99}

    !- Books with the word "of" in their titles
    PrintBooksByTitle('of')
    !- expected output:
    ! Books with the word 'of' in their titles:
    ! - {"category":"reference","author":"Nigel Rees","title":"Sayings of the Century","price":8.95}
    ! - {"category":"fiction","author":"Evelyn Waugh","title":"Sword of Honour","price":12.99}
    ! - {"category":"fiction","author":"J. R. R. Tolkien","title":"The Lord of the Rings","isbn":"0-395-19395-8","price":22.99}

    !- Authors of "reference" category
    PrintAuthorsByCategory('reference')
    !- expected output:
    ! reference authors:
    ! - Nigel Rees
    
    !- Bicycle colors
    PrintBicycleColors()
    !- expected output:
    ! Bicycle colors
    ! - red
    

    !- clean up
    jRoot.Delete()
  END
  MESSAGE('Done!', 'JSONPath test', ICON:Asterisk)

  
PrintAllAuthors               PROCEDURE()
i                               LONG, AUTO
jAuthor                         &cJSON
  CODE
  printd('All authors:')
  !- reset previous result
  output.Reset()
  !- Find
  resCount = jRoot.FindPathContext('$[store][book][*][author]', output)
  !- print result
  LOOP i=1 TO resCount
    jAuthor &= output.GetObject(i)
    printd('- %s', jAuthor.GetStringValue())
  END
  printd('%|')

PrintAllPrices                PROCEDURE()
i                               LONG, AUTO
jPrice                          &cJSON
  CODE
  printd('All prices:')
  !- reset previous result
  output.Reset()
  !- Find
  resCount = jRoot.FindPathContext('$[store][..][price]', output)
  !- print result
  LOOP i=1 TO resCount
    jPrice &= output.GetObject(i)
    printd('- %f', jPrice.GetNumberValue())
  END
  printd('%|')

PrintCheapBooks               PROCEDURE(REAL pMaxPrice)
i                               LONG, AUTO
jBook                           &cJSON
  CODE
  printd('Books cheaper %f rubles:', pMaxPrice)
  !- reset previous result
  output.Reset()
  !- Find
  resCount = jRoot.FindPathContext(printf('$[store][book][?(@.price << %f)]', pMaxPrice), output)
  !- print result
  LOOP i=1 TO resCount
    jBook &= output.GetObject(i)
    printd('- %s', jBook.ToString())
  END
  printd('%|')

PrintBooksByTitle             PROCEDURE(STRING pTitlePart)
i                               LONG, AUTO
jBook                           &cJSON
  CODE
  printd('Books with the word %S in their titles:', pTitlePart)
  !- reset previous result
  output.Reset()
  !- Find
  resCount = jRoot.FindPathContext(printf('$[store][book][?(instring("%s",@.title,1,1)>0)]', pTitlePart), output)
  !- print result
  LOOP i=1 TO resCount
    jBook &= output.GetObject(i)
    printd('- %s', jBook.ToString())
  END
  printd('%|')

PrintAuthorsByCategory        PROCEDURE(STRING pCategory)
i                               LONG, AUTO
jAuthor                         &cJSON
  CODE
  printd('%s authors:', pCategory)
  !- reset previous result
  output.Reset()
  !- Find
  resCount = jRoot.FindPathContext(printf('$[store][book][?(@.category="%s")][author]', pCategory), output)
  !- print result
  LOOP i=1 TO resCount
    jAuthor &= output.GetObject(i)
    printd('- %s', jAuthor.GetStringValue())
  END
  printd('%|')

PrintBicycleColors            PROCEDURE()
i                               LONG, AUTO
jColor                          &cJSON
  CODE
  printd('Bicycle colors')
  !- reset previous result
  output.Reset()
  !- Find
  resCount = jRoot.FindPathContext('$[store][bicycle][color]', output)
  !- print result
  LOOP i=1 TO resCount
    jColor &= output.GetObject(i)
    printd('- %s', jColor.GetStringValue())
  END
  printd('%|')
