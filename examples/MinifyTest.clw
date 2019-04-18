!Test json::Minify function
!
  PROGRAM

  INCLUDE('cjson.inc')

  MAP
    MinifyTest()
  END

  CODE
  MinifyTest()

MinifyTest                    PROCEDURE()
fileContent                     &STRING
  CODE
  !- load file
  fileContent &= json::LoadFile('test.json')
  IF NOT fileContent &= NULL
    !- minify (remove all whilespaces, and comments)
    json::Minify(fileContent)
    
    !- save minified file (do CLIP to not save trailing spaces)
    json::SaveFile('test_minified.json', CLIP(fileContent))
    
    !- dispose dynamic buffer
    DISPOSE(fileContent)
    MESSAGE('test_minified.json created.')
  ELSE
    MESSAGE('Error loading test.json.')
  END
