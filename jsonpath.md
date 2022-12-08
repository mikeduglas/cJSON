Here is an overview of the JSONPath syntax elements:

| **JSONPath** | **Description**                                        |
|--------------|--------------------------------------------------------|
| $            | the root object/element.                               |
| @            | the current object/element.                            |
| []           | child operator.                                        |
| ..           | recursive descent.                                     |
| *            | wildcard. All objects/elements regardless their names. |
| []           | subscript operator.                                    |
| [,]          | Union operator.                                        |
| [start:end]  | array slice operator.                                  |
| ?()          | applies a filter (script) expression.                  |
| ()           | script expression, using the underlying script engine. |


### Filter expressions
- double quotes can be used in string constants instead of apostrophes.
- any Clarion function can be used in filter expression.  
- "@.<name>" refers to the "<name>" element of current node.

Following example finds the books with the title containing "Sword" word:
```
$[store][book][?(INSTRING("Sword",@.title,1,1) > 0)]
```


### Script expressions
- "@.length" means an array length.
Following example finds the second book from the end:
```
$[ store ][ book ][ (@.length-1) ]
```

## Examples

| **JSONPath**                               | **Result**                                             |
|--------------------------------------------|--------------------------------------------------------|
| $[store][book]                             | book array                                             |
| $["store"]["book"]                         | book array                                             |
| $[store][book][3]                          | 3rd book                                               |
| $[store][book][1,3,4]                      | 3 books                                                |
| $[store][book][2:4]                        | 3 books                                                |
| $[store][book][(@.length)]                 | last book                                              |
| $[store][book][*]                          | all books                                              |
| $[store][..][price]                        | all price elements (both books and bicycles)           |
| $[store][bicycle, book]                    | both bicycles and books                                |
| $[store][book][?(@.price > 10)][title]     | the titles of books with price > 10                    |
| $[..][*]                                   | all objects and elements                               |
