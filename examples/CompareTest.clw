!json::Compare() unit tests
!
  PROGRAM
  INCLUDE('cjson.inc')
  MAP
    compare_from_string(STRING a, STRING b, BOOL case_sensitive), BOOL

    cjson_compare_should_compare_null_pointer_as_not_equal()
    cjson_compare_should_compare_invalid_as_not_equal()
    cjson_compare_should_compare_numbers()
    cjson_compare_should_compare_booleans()
    cjson_compare_should_compare_null()
    cjson_compare_should_not_accept_invalid_types()
    cjson_compare_should_compare_strings()
    cjson_compare_should_compare_raw()
    cjson_compare_should_compare_arrays()
    cjson_compare_should_compare_objects()
  END

  CODE
  cjson_compare_should_compare_null_pointer_as_not_equal()
  cjson_compare_should_compare_invalid_as_not_equal()
  cjson_compare_should_compare_numbers()
  cjson_compare_should_compare_booleans()
  cjson_compare_should_compare_null()
  cjson_compare_should_not_accept_invalid_types()
  cjson_compare_should_compare_strings()
  cjson_compare_should_compare_raw()
  cjson_compare_should_compare_arrays()
  cjson_compare_should_compare_objects() 
  
  MESSAGE('End of unit tests')


compare_from_string           PROCEDURE(STRING a, STRING b, BOOL case_sensitive)
factory                         cJSONFactory
a_json                          &cJSON
b_json                          &cJSON
result                          BOOL(FALSE)
  CODE
  a_json &= factory.Parse(a)
  ASSERT(NOT a_json &= NULL, 'Failed to parse a.')
  b_json &= factory.Parse(b)
  ASSERT(NOT b_json &= NULL, 'Failed to parse b.')

  result = json::Compare(a_json, b_json, case_sensitive)
  
  a_json.Delete()
  b_json.Delete()
  
  RETURN result
  
cjson_compare_should_compare_null_pointer_as_not_equal    PROCEDURE()
null_json                                                   &cJSON
  CODE
  ASSERT(json::Compare(null_json, null_json, TRUE) = FALSE)
  ASSERT(json::Compare(null_json, null_json, FALSE) = FALSE)
  
cjson_compare_should_compare_invalid_as_not_equal PROCEDURE()
invalid                                             &cJSON
  CODE
  invalid &= NEW cJSON
  
  ASSERT(json::Compare(invalid, invalid, TRUE) = FALSE)
  ASSERT(json::Compare(invalid, invalid, FALSE) = FALSE)
  
  invalid.Delete()
  
cjson_compare_should_compare_numbers  PROCEDURE()
  CODE
  ASSERT(compare_from_string('1', '1', TRUE) = TRUE)
  ASSERT(compare_from_string('1', '1', FALSE) = TRUE)
  ASSERT(compare_from_string('0.0001', '0.0001', TRUE) = TRUE)
  ASSERT(compare_from_string('0.0001', '0.0001', FALSE) = TRUE)
  
  ASSERT(compare_from_string('1', '2', TRUE) = FALSE)
  ASSERT(compare_from_string('1', '2', FALSE) = FALSE)

cjson_compare_should_compare_booleans PROCEDURE()
  CODE
  !true
  ASSERT(compare_from_string('true', 'true', TRUE) = TRUE)
  ASSERT(compare_from_string('true', 'true', FALSE) = TRUE)

  !false
  ASSERT(compare_from_string('false', 'false', TRUE) = TRUE)
  ASSERT(compare_from_string('false', 'false', FALSE) = TRUE)

  !mixed
  ASSERT(compare_from_string('true', 'false', TRUE) = FALSE)
  ASSERT(compare_from_string('true', 'false', FALSE) = FALSE)
  ASSERT(compare_from_string('false', 'true', TRUE) = FALSE)
  ASSERT(compare_from_string('false', 'true', FALSE) = FALSE)

cjson_compare_should_compare_null PROCEDURE()
  CODE
  ASSERT(compare_from_string('null', 'null', TRUE) = TRUE)
  ASSERT(compare_from_string('null', 'null', FALSE) = TRUE)

  ASSERT(compare_from_string('null', 'true', TRUE) = FALSE)
  ASSERT(compare_from_string('null', 'true', FALSE) = FALSE)

cjson_compare_should_not_accept_invalid_types PROCEDURE()
invalid                                         &cJSON
  CODE
  invalid &= NEW cJSON
  invalid.SetType(BOR(cJSON_Number, cJSON_String))
  
  ASSERT(json::Compare(invalid, invalid, TRUE) = FALSE)
  ASSERT(json::Compare(invalid, invalid, FALSE) = FALSE)
  
  invalid.Delete()
  
cjson_compare_should_compare_strings  PROCEDURE()
  CODE
  ASSERT(compare_from_string('"abcdefg"', '"abcdefg"', TRUE) = TRUE)
  ASSERT(compare_from_string('"abcdefg"', '"abcdefg"', FALSE) = TRUE)

  ASSERT(compare_from_string('"ABCDEFG"', '"abcdefg"', TRUE) = FALSE)
  ASSERT(compare_from_string('"ABCDEFG"', '"abcdefg"', FALSE) = FALSE)

cjson_compare_should_compare_raw  PROCEDURE()
factory                             cJSONFactory
raw1                                &cJSON
raw2                                &cJSON
  CODE
  raw1 &= factory.Parse('"[true, false]"')
  ASSERT(NOT raw1 &= NULL)
  raw2 &= factory.Parse('"[true, false]"')
  ASSERT(NOT raw2 &= NULL)
  
  raw1.SetType(cJSON_Raw)
  raw2.SetType(cJSON_Raw)
  
  ASSERT(json::Compare(raw1, raw2, TRUE) = TRUE)
  ASSERT(json::Compare(raw1, raw2, FALSE) = TRUE)

  raw1.Delete()
  raw2.Delete()
  
cjson_compare_should_compare_arrays   PROCEDURE()
  CODE
  ASSERT(compare_from_string('[]', '[]', TRUE) = TRUE)
  ASSERT(compare_from_string('[]', '[]', FALSE) = TRUE)

  ASSERT(compare_from_string('[false,true,null,42,"string",[],{{}]', '[false, true, null, 42, "string", [], {{}]', TRUE) = TRUE)
  ASSERT(compare_from_string('[false,true,null,42,"string",[],{{}]', '[false, true, null, 42, "string", [], {{}]', FALSE) = TRUE)

  ASSERT(compare_from_string('[[[1], 2]]', '[[[1], 2]]', TRUE) = TRUE)
  ASSERT(compare_from_string('[[[1], 2]]', '[[[1], 2]]', FALSE) = TRUE)

  ASSERT(compare_from_string('[true,null,42,"string",[],{{}]', '[false, true, null, 42, "string", [], {{}]', TRUE) = FALSE)
  ASSERT(compare_from_string('[true,null,42,"string",[],{{}]', '[false, true, null, 42, "string", [], {{}]', FALSE) = FALSE)

  !Arrays that are a prefix of another array
  ASSERT(compare_from_string('[1,2,3]', '[1,2]', TRUE) = FALSE)
  ASSERT(compare_from_string('[1,2,3]', '[1,2]', FALSE) = FALSE)

cjson_compare_should_compare_objects  PROCEDURE()
  CODE
  ASSERT(compare_from_string('{{}', '{{}', TRUE) = TRUE)
  ASSERT(compare_from_string('{{}', '{{}', FALSE) = TRUE)

  ASSERT(compare_from_string( |
    '{{"false": false, "true": true, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', | 
    '{{"true": true, "false": false, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', TRUE) = TRUE)
  ASSERT(compare_from_string( |
    '{{"False": false, "true": true, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', | 
    '{{"true": true, "false": false, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', TRUE) = FALSE)

  ASSERT(compare_from_string( |
    '{{"false": false, "true": true, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', | 
    '{{"true": true, "false": false, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', FALSE) = TRUE)
  ASSERT(compare_from_string( |
    '{{"Flse": false, "true": true, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', | 
    '{{"true": true, "false": false, "null": null, "number": 42, "string": "string", "array": [], "object": {{}}', FALSE) = FALSE)

  !test objects that are a subset of each other
  ASSERT(compare_from_string( |
    '{{"one": 1, "two": 2}', | 
    '{{"one": 1, "two": 2, "three": 3}', TRUE) = FALSE)
  ASSERT(compare_from_string( |
    '{{"one": 1, "two": 2}', | 
    '{{"one": 1, "two": 2, "three": 3}', FALSE) = FALSE)
