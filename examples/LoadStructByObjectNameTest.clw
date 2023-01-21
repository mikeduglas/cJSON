  PROGRAM

  INCLUDE('cjson.inc'), ONCE

  MAP
    INCLUDE('printf.inc'), ONCE
  END

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

Books                         QUEUE, PRE(Books)
Category                        STRING(32)
Author                          STRING(32)
Title                           STRING(64)
isbn                            STRING(20)
Price                           REAL
                              END

Bicycle                       GROUP, PRE(Bicycle)
Color                           STRING(20)
Price                           REAL
                              END

jParser                       cJSONFactory
i                             LONG, AUTO

  CODE
  !- load book array into Books queue
  FREE(Books)
  IF jParser.ToQueue(sResponse, 'book', Books)
    !- Success, test each book.
    LOOP i=1 TO RECORDS(Books)
      GET(Books, i)
      printd('category: %s; author: %s; title: %s; isbn: %s; price: %f', Books.Category, Books.Author, Books.Title, Books.isbn, Books.Price)
    END
  ELSE
    printd('ToQueue(book) error.')
  END
  
  !- Load bicycle object into Bicycle group
  IF jParser.ToGroup(sResponse, 'bicycle', Bicycle)
    !- Success, test Bicycle data.
    printd('Bicycle: color %s, price %f', Bicycle.Color, Bicycle.Price)
  ELSE
    printd('ToGroup(bicycle) error.')
  END
