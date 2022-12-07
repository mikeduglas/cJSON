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
| ()           | cript expression, using the underlying script engine.  |
|--------------|--------------------------------------------------------|
