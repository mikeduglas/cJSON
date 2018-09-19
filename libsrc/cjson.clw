  MEMBER
  
  PRAGMA('compile(CWUTIL.CLW)')

  INCLUDE('dynstrclass.inc'), ONCE
  INCLUDE('cjson.inc'), ONCE

TPrintBuffer                  GROUP, TYPE
printed                         &DynStr
depth                           LONG  !current nesting depth (for formatted printing)
format                          BOOL  !is this print a formatted print
                              END

TParseBuffer                  GROUP, TYPE
content                         &STRING
len                             LONG
pos                             LONG  !1..len(clip(input))
depth                           LONG  !How deeply nested (in arrays/objects) is the input at the current offset.
                              END

  MAP
    MODULE('win api')
      winapi::memcpy(LONG lpDest,LONG lpSource,LONG nCount),LONG,PROC,NAME('_memcpy')
      winapi::OutputDebugString(*CSTRING lpOutputString), PASCAL, RAW, NAME('OutputDebugStringA')
    END

    INCLUDE('CWUTIL.inc'), ONCE

    !static functions
    suffix_object(*cJSON prev, *cJSON item), PRIVATE
    add_item_to_object(*cJSON object, *STRING str, *cJSON item, BOOL constant_key), BOOL, PROC, PRIVATE
    add_item_to_array(*cJSON array, *cJSON item), BOOL, PROC, PRIVATE
    replace_item_in_object(*cJSON object, *STRING str, *cJSON replacement, BOOL case_sensitive), BOOL, PROC, PRIVATE
    get_object_item(*cJSON object, *STRING name, BOOL case_sensitive), *cJSON, PRIVATE
    get_array_item(*cJSON array, LONG index), *cJSON, PRIVATE
    create_reference(*cJSON item), *cJSON, PRIVATE

    print_value(*cJSON item, *TPrintBuffer buffer), BOOL, PROC, PRIVATE
    print_number(*cJSON item, *TPrintBuffer buffer), BOOL, PRIVATE
    print_string(*cJSON item, *TPrintBuffer buffer), BOOL, PRIVATE
    print_string_ptr(*STRING input, *TPrintBuffer buffer), BOOL, PRIVATE
    print_array(*cJSON item, *TPrintBuffer buffer), BOOL, PRIVATE
    print_object(*cJSON item, *TPrintBuffer buffer), BOOL, PRIVATE

    parse_value(*cJSON item, *TParseBuffer buffer), BOOL, PRIVATE
    parse_number(*cJSON item, *TParseBuffer buffer), BOOL, PRIVATE
    parse_string(*cJSON item, *TParseBuffer buffer), BOOL, PRIVATE
    parse_array(*cJSON item, *TParseBuffer buffer), BOOL, PRIVATE
    parse_object(*cJSON item, *TParseBuffer buffer), BOOL, PRIVATE

    !parse 4 digit hexadecimal number
    parse_hex4(TParseBuffer buffer, LONG pos), UNSIGNED, PRIVATE
    !converts a UTF-16 literal to UTF-8. A literal can be one or two sequences of the form \uXXXX
    utf16_literal_to_utf8(*TParseBuffer buffer, LONG input_end, *STRING output), BYTE, PRIVATE
    !skip the UTF-8 BOM (byte order mark) if it is at the beginning of a buffer
    skip_utf8_bom(*TParseBuffer buffer), PRIVATE
    !Utility to jump whitespace and cr/lf
    buffer_skip_whitespace(*TParseBuffer buffer), PRIVATE
  END

INT_MAX                       EQUATE(2147483647)
INT_MIN                       EQUATE(-2147483648)

!ASCII control codes
_Backspace_                   EQUATE('<08h>')
_Tab_                         EQUATE('<09h>')
_LF_                          EQUATE('<0Ah>')
_FF_                          EQUATE('<0Ch>')
_CR_                          EQUATE('<0Dh>')
_CRLF_                        EQUATE('<0Dh,0Ah>')

  
!!!region static functions
json::DebugInfo               PROCEDURE(STRING pMsg)
cs                              CSTRING(LEN('cJSON') + LEN(pMsg) + 3 + 1)
  CODE
  cs = '['& 'cJSON' &'] ' & CLIP(pMsg)
  winapi::OutputDebugString(cs)

suffix_object                 PROCEDURE(*cJSON prev, *cJSON item)
  CODE
  prev.next &= item
  item.prev &= prev
  
add_item_to_object            PROCEDURE(*cJSON object, *STRING str, *cJSON item, BOOL constant_key)
new_key                         &STRING
new_type                        cJSON_Type(cJSON_Invalid)
  CODE
  IF (object &= NULL) OR (NOT str) OR (item &= NULL)
    RETURN FALSE
  END
  
  IF constant_key
    new_key &= str
    new_type = BOR(item.type, cJSON_StringIsConst)
  ELSE
    new_key &= NEW STRING(LEN(str))
    new_key = str
    new_type = BAND(item.type, cJSON_StringIsNotConst)
  END
  
  IF (NOT BAND(item.type, cJSON_StringIsConst)) AND (NOT item.name &= NULL)
    DISPOSE(item.name)
    item.name &= NULL
  END

  item.name &= new_key
  item.type = new_type

  RETURN add_item_to_array(object, item)
    
add_item_to_array             PROCEDURE(*cJSON array, *cJSON item)
child                           &cJSON
  CODE
  IF item &= NULL OR array &= NULL
    RETURN FALSE
  END
  
  child &= array.child

  IF child &= NULL
    !list is empty, start new one
    array.child &= item
  ELSE
    !append to the end
    LOOP WHILE NOT child.next &= NULL
      child &= child.next
    END
    suffix_object(child, item)
  END
  
  RETURN TRUE

replace_item_in_object        PROCEDURE(*cJSON object, *STRING str, *cJSON replacement, BOOL case_sensitive)
  CODE
  IF replacement &= NULL !OR str &= NULL
    RETURN FALSE
  END
  
  !replace the name in the replacement
  IF (NOT BAND(replacement.type, cJSON_StringIsConst)) AND (NOT replacement.name &= NULL)
    DISPOSE(replacement.name)
    replacement.name &= NULL
  END

  replacement.name &= NEW STRING(LEN(str))
  replacement.name = str
  replacement.type = BAND(replacement.type, cJSON_StringIsNotConst)

  object.ReplaceItemViaPointer(get_object_item(object, str, case_sensitive), replacement)
  RETURN TRUE
  
get_object_item               PROCEDURE(*cJSON object, *STRING name, BOOL case_sensitive)
current_element                 &cJSON
  CODE
  IF object &= NULL !OR name &= NULL
    RETURN NULL
  END
  
  current_element &= object.child
  IF case_sensitive
    LOOP WHILE (NOT current_element &= NULL) AND name <> current_element.name
      current_element &= current_element.next
    END
  ELSE
    LOOP WHILE (NOT current_element &= NULL) AND LOWER(name) <> LOWER(current_element.name)
      current_element &= current_element.next
    END
  END

  RETURN current_element

get_array_item                PROCEDURE(*cJSON array, LONG index)
current_child                   &cJSON
  CODE
  IF array &= NULL
    RETURN NULL
  END
  
  current_child &= array.child
  LOOP WHILE (NOT current_child &= NULL) AND (index > 1)  !in c: index > 0
    index -= 1
    current_child &= current_child.next
  END

  RETURN current_child

create_reference              PROCEDURE(*cJSON item)
reference                       &cJSON
  CODE
  IF item &= NULL
    RETURN NULL
  END
  
  reference &= NEW cJSON
!  winapi::memcpy(ADDRESS(reference), ADDRESS(item), SIZE(item))
  reference :=: item
  reference.prev &= NULL
  reference.next &= NULL
  reference.name &= NULL
  reference.type = BOR(reference.type, cJSON_IsReference)
  
  RETURN reference

print_value                   PROCEDURE(*cJSON item, *TPrintBuffer buffer)
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END

  CASE BAND(item.type, 0FFh)
  OF cJSON_NULL
    buffer.printed.Cat('null')
    RETURN TRUE
  OF cJSON_False
    buffer.printed.Cat('false')
    RETURN TRUE
  OF cJSON_True
    buffer.printed.Cat('true')
    RETURN TRUE
  OF cJSON_Number
    RETURN print_number(item, buffer)
  OF cJSON_Raw
    IF item.valuestring &= NULL
      RETURN FALSE
    END
    buffer.printed.Cat(item.valuestring)
    RETURN TRUE
  OF cJSON_String
    RETURN print_string(item, buffer)
  OF cJSON_Array
    RETURN print_array(item, buffer)
  OF cJSON_Object
    RETURN print_object(item, buffer)
  END
  
  RETURN FALSE

!Render the number nicely from the given item into a string.
print_number                  PROCEDURE(*cJSON item, *TPrintBuffer buffer)
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END

  buffer.printed.Cat(item.valuedouble)
  RETURN TRUE

!Render the cstring provided to an escaped version that can be printed.
print_string_ptr              PROCEDURE(*STRING input, *TPrintBuffer buffer)
escape_characters               LONG, AUTO  !numbers of additional characters needed for escaping
cIndex                          LONG, AUTO
oIndex                          LONG, AUTO
output                          &STRING
  CODE
  IF buffer.printed &= NULL
    RETURN FALSE
  END

  IF NOT input
    buffer.printed.Cat('""')
    RETURN TRUE
  END
  
  escape_characters = 0
  LOOP cIndex = 1 TO LEN(input)
    CASE input[cIndex]
    OF   '"'
    OROF '\'
    OROF _Backspace_  !\b
    OROF _FF_         !\f
    OROF _LF_         !\n
    OROF _CR_         !\r
    OROF _Tab_        !\t
      !one character escape sequence
      escape_characters += 1
      
    ELSE
      IF VAL(input[cIndex]) < 32
        !UTF-16 escape sequence uXXXX
        escape_characters += 5
      END
    END
  END

  !no characters have to be escaped
  IF escape_characters = 0
    buffer.printed.Cat('"'& input &'"')
    RETURN TRUE
  END
  
  output &= NEW STRING(LEN(input) + escape_characters)
  
  oIndex = 0
  LOOP cIndex = 1 TO LEN(input)
    oIndex += 1
    IF VAL(input[cIndex]) > 31 AND input[cIndex] <> '"' AND input[cIndex] <> '\'
      !normal character, copy
      output[oIndex] = input[cIndex]
    ELSE
      !character needs to be escaped
      output[oIndex] = '\'
      oIndex += 1
      CASE input[cIndex]
      OF '\'
        output[oIndex] =  '\'
      OF '"'
        output[oIndex] = '"'
      OF _Backspace_          !\b
        output[oIndex] = 'b'
      OF _FF_                 !\f
        output[oIndex] = 'f'
      OF _LF_                 !\n
        output[oIndex] = 'n'
      OF _CR_                 !\r
        output[oIndex] = 'r'
      OF _Tab_                !\t
        output[oIndex] = 't'
      ELSE
        !escape and print as unicode codepoint
        output[oIndex : oIndex + 4] = 'u'& LongToHex(VAL(input[cIndex])) &'x'
        oIndex += 4
      END
    END
  END
  
  buffer.printed.Cat('"'& output &'"')
  DISPOSE(output)
  
  RETURN TRUE

print_string                  PROCEDURE(*cJSON item, *TPrintBuffer buffer)
  CODE
  RETURN print_string_ptr(item.valuestring, buffer)
  
print_array                   PROCEDURE(*cJSON item, *TPrintBuffer buffer)
current_element                 &cJSON
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END
  
  !Compose the output array.
  !opening square bracket
  buffer.printed.Cat('[')
  buffer.depth += 1
  
  current_element &= item.child
  LOOP WHILE NOT current_element &= NULL
    IF NOT print_value(current_element, buffer)
      RETURN FALSE
    END
    
    IF NOT current_element.next &= NULL
      buffer.printed.Cat(', ')
      IF buffer.format
        buffer.printed.Cat(' ')
      END
    END
    
    current_element &= current_element.next
  END
  
  !closing square bracket
  buffer.printed.Cat(']')
  buffer.depth -= 1

  RETURN TRUE

print_object                  PROCEDURE(*cJSON item, *TPrintBuffer buffer)
current_item                    &cJSON
  CODE
  IF item &= NULL OR buffer.printed &= NULL
    RETURN FALSE
  END
  
  !Compose the output.
  !opening curly bracket
  buffer.printed.Cat('{{')
  buffer.depth += 1
  IF buffer.format
    buffer.printed.Cat(_CRLF_)
  END
  
  current_item &= item.child
  LOOP WHILE NOT current_item &= NULL
    IF buffer.format
      LOOP buffer.depth TIMES
        buffer.printed.Cat(_Tab_)
      END
    END
    
    !print key
    IF NOT print_string_ptr(current_item.name, buffer)
      RETURN FALSE
    END
    
    buffer.printed.Cat(':')
    IF buffer.format
      buffer.printed.Cat(_Tab_)
    END

    !print value
    IF NOT print_value(current_item, buffer)
      RETURN FALSE
    END

    !print comma if not last
    IF NOT current_item.next &= NULL
      buffer.printed.Cat(',')
    END
    
    IF buffer.format
      buffer.printed.Cat(_CRLF_)
    END
  
    current_item &= current_item.next
  END
  
  IF buffer.format
    LOOP buffer.depth - 1 TIMES
      buffer.printed.Cat(_Tab_)
    END
  END

  buffer.printed.Cat('}')
  buffer.depth -= 1
  RETURN TRUE

!Parser core - when encountering text, process appropriately.
parse_value                   PROCEDURE(*cJSON item, *TParseBuffer buffer)
start_char                      STRING(1), AUTO
  CODE
  IF buffer.content &= NULL OR buffer.content = ''
    RETURN FALSE    !no input
  END
  
  start_char = SUB(buffer.content, buffer.pos, 1)
  
  !parse the different types of values
  !null
  IF SUB(buffer.content, buffer.pos, 4) = 'null'
    item.type = cJSON_Null
    buffer.pos += 4
    RETURN TRUE
  END
  !false
  IF SUB(buffer.content, buffer.pos, 5) = 'false'
    item.type = cJSON_False
    item.valueint = 0
    buffer.pos += 5
    RETURN TRUE
  END
  !true
  IF SUB(buffer.content, buffer.pos, 4) = 'true'
    item.type = cJSON_True
    item.valueint = 1
    buffer.pos += 4
    RETURN TRUE
  END
  !string
  IF start_char = '"'
    RETURN parse_string(item, buffer)
  END
  !number
  IF start_char = '-' OR INRANGE(VAL(start_char), 0, 9)
    RETURN parse_number(item, buffer)
  END
  !array
  IF start_char = '['
    RETURN parse_array(item, buffer)
  END
  !object
  IF start_char = '{{'
    RETURN parse_object(item, buffer)
  END
  
  RETURN FALSE

!Parse the input text to generate a number, and populate the result into item.
parse_number                  PROCEDURE(*cJSON item, *TParseBuffer buffer)
number                          REAL(0)
number_c_string                 STRING(64)
decimal_point                   STRING(1), AUTO
i                               LONG, AUTO
  CODE
  IF item &= NULL
    RETURN FALSE
  END
  
!  decimal_point = get_decimal_point()
  decimal_point = '.'
  
  LOOP i = buffer.pos TO buffer.len
    IF i > LEN(number_c_string)
      BREAK
    END
    
    CASE buffer.content[i]
    OF '0' TO '9'
    OROF '+'
    OROF '-'
    OROF 'e'
    OROF 'E'
      number_c_string[i] = buffer.content[i]
    OF '.'
      number_c_string[i] = decimal_point
    ELSE
      i -= 1
      BREAK !end of loop
    END
  END
  
  item.valuedouble = number_c_string

  IF number_c_string + 0 >= INT_MAX
    item.valueint = INT_MAX
  ELSIF number_c_string + 0 <= INT_MIN
    item.valueint = INT_MIN
  ELSE
    item.valueint = number_c_string
  END

  item.type = cJSON_Number
  
  buffer.pos = i + 1

  RETURN TRUE

!Parse the input text into an unescaped cinput, and populate item.
parse_string                  PROCEDURE(*cJSON item, *TParseBuffer buffer)
cur_char                        STRING(1)
next_char                       STRING(1)
i                               LONG, AUTO
skipped_bytes                   LONG(0)
output                          DynStr
tempout                         STRING(20), AUTO
input_end                       LONG, AUTO
sequence_length                 LONG, AUTO
  CODE
  !not a string
  IF SUB(buffer.content, buffer.pos, 1) <> '"'
    buffer.pos += 1
    RETURN FALSE
  END

  input_end = buffer.pos + 1
  LOOP i = input_end TO buffer.len
    cur_char = SUB(buffer.content, i, 1)
    IF cur_char = '"'
      BREAK
    END
    
    !is escape sequence
    IF cur_char = '\'
      skipped_bytes += 1
      input_end += 1
    END

    input_end += 1
  END
  
  IF cur_char <> '"'
    !string ended unexpectedly
    buffer.pos = i + 1
    RETURN FALSE
  END

  !loop through the string literal
  i = buffer.pos + 1
  LOOP WHILE i < input_end
    cur_char = SUB(buffer.content, i, 1)
    IF cur_char <> '\'
      output.Cat(cur_char)
      i += 1
    ELSE
      sequence_length = 2
      
      next_char = SUB(buffer.content, i + 1, 1)
      CASE next_char
      OF 'b'
        output.Cat(_Backspace_)
      OF 'f'
        output.Cat(_FF_)
      OF 'n'
        output.Cat(_LF_)
      OF 'r'
        output.Cat(_CR_)
      OF 't'
        output.Cat(_Tab_)
      OF '"' OROF '\' OROF '/'
        output.Cat(next_char)
      OF 'u'
        !UTF-16 literal
        CLEAR(tempout)
        sequence_length = utf16_literal_to_utf8(buffer, input_end, tempout)
        IF sequence_length = 0
          !failed to convert UTF16-literal to UTF-8
          buffer.pos = i + 1
          RETURN FALSE
        END
        
        output.Cat(CLIP(tempout))
      ELSE
        buffer.pos = i + 1
        RETURN FALSE
      END
      
      i += sequence_length
    END
  END
  
!  json::DebugInfo('parse_string: '& output.Str())
  item.type = cJSON_String
  item.valuestring &= NEW STRING(output.StrLen())
  item.valuestring = output.Str()

  buffer.pos = input_end + 1
  RETURN TRUE
  
!Build an array from input text.
parse_array                   PROCEDURE(*cJSON item, *TParseBuffer buffer)
head                            &cJSON  !head of the linked list
current_item                    &cJSON
new_item                        &cJSON
  CODE
  IF buffer.content[buffer.pos] <> '['
    !not an array
    DO Fail
  END
  
  buffer.pos += 1
  
  !skip whitespaces
  buffer_skip_whitespace(buffer)

  IF buffer.content[buffer.pos] = ']'
    !empty array
    DO Success
  END
  
  !check if we skipped to the end of the buffer
  !...
  
  !step back to character in front of the first element
  buffer.pos -= 1

  !loop through the comma separated array elements
  LOOP
    !allocate next item
    new_item &= NEW cJSON
    !attach next item to list
    IF head &= NULL
      !start the linked list
      current_item &= new_item
      head &= new_item
    ELSE
      !add to the end and advance
      current_item.next &= new_item
      new_item.prev &= current_item
      current_item &= new_item
    END
    
    !parse next value
    buffer.pos += 1
    buffer_skip_whitespace(buffer)
    IF NOT parse_value(current_item, buffer)
      DO Fail !failed to parse value
    END
    
    buffer_skip_whitespace(buffer)

  WHILE buffer.pos < buffer.len AND buffer.content[buffer.pos] = ','
  
  IF buffer.pos >= buffer.len OR buffer.content[buffer.pos] <> ']'
    DO Fail   !expected end of array
  END
  
  DO Success

Success                       ROUTINE
  item.type = cJSON_Array
  item.child &= head
  buffer.pos += 1
  RETURN TRUE

Fail                          ROUTINE
  IF NOT head &= NULL
    head.Delete()
  END
  RETURN FALSE
  
!Build an object from the text.
parse_object                  PROCEDURE(*cJSON item, *TParseBuffer buffer)
head                            &cJSON  !head of the linked list
current_item                    &cJSON
new_item                        &cJSON
  CODE
  IF buffer.content[buffer.pos] <> '{{'
    !not an object
    DO Fail
  END
  
  buffer.pos += 1
  
  !skip whitespaces
  buffer_skip_whitespace(buffer)

  IF buffer.content[buffer.pos] = '}'
    !empty object
    DO Success
  END
  
  !check if we skipped to the end of the buffer
  !...
  
  !step back to character in front of the first element
  buffer.pos -= 1

  !loop through the comma separated array elements
  LOOP
    !allocate next item
    new_item &= NEW cJSON
    !attach next item to list
    IF head &= NULL
      !start the linked list
      current_item &= new_item
      head &= new_item
    ELSE
      !add to the end and advance
      current_item.next &= new_item
      new_item.prev &= current_item
      current_item &= new_item
    END
    
    !parse the name of the child
    buffer.pos += 1
    buffer_skip_whitespace(buffer)
    IF NOT parse_string(current_item, buffer)
      DO Fail !failed to parse name
    END
    buffer_skip_whitespace(buffer)

    !swap valuestring and string, because we parsed the name
    current_item.name &= current_item.valuestring
    current_item.valuestring &= NULL
    
    IF buffer.pos > buffer.len OR buffer.content[buffer.pos] <> ':'
      DO Fail   !invalid object
    END

    !parse the value
    buffer.pos += 1
    buffer_skip_whitespace(buffer)
    IF NOT parse_value(current_item, buffer)
      DO Fail !failed to parse value
    END
    
    buffer_skip_whitespace(buffer)

  WHILE buffer.pos <= buffer.len AND buffer.content[buffer.pos] = ','
  
  IF buffer.pos > buffer.len OR buffer.content[buffer.pos] <> '}'
    DO Fail   !expected end of object
  END
  
  DO Success

Success                       ROUTINE
  item.type = cJSON_Object
  item.child &= head
  buffer.pos += 1
  RETURN TRUE

Fail                          ROUTINE
  IF NOT head &= NULL
    head.Delete()
  END
  RETURN FALSE

parse_hex4                    PROCEDURE(*TParseBuffer buffer, LONG pos)
h                               UNSIGNED(0)
i                               LONG, AUTO
char                            STRING(1), AUTO
  CODE
  LOOP i = 1 TO 4
    !parse digit
    char = SUB(buffer.content, pos + i - 1, 1)
    IF INRANGE(VAL(char), VAL('0'), VAL('9'))
      h += VAL(char) - VAL('0')
    ELSIF INRANGE(VAL(char), VAL('A'), VAL('F'))
      h += 10 + VAL(char) - VAL('A')
    ELSIF INRANGE(VAL(char), VAL('a'), VAL('f'))
      h += 10 + VAL(char) - VAL('a')
    ELSE
      !invalid
      RETURN 0
    END
    
    IF i < 4
      !shift left to make place for the next nibble
      h = BSHIFT(h, 4)
    END
  END
  
  RETURN h
  
utf16_literal_to_utf8         PROCEDURE(*TParseBuffer buffer, LONG input_end, *STRING output)
codepoint                       DECIMAL(10, 0)  !uint64
first_sequence                  LONG, AUTO
second_sequence                 LONG, AUTO
sequence_length                 BYTE(0)
first_code                      LONG, AUTO
second_code                     LONG, AUTO
utf8_length                     BYTE(0)
first_byte_mark                 BYTE(0)
utf8_position                   LONG, AUTO
  CODE
  first_sequence = buffer.pos
  
  IF input_end - first_sequence + 1 < 6
    !input ends unexpectedly
    RETURN 0
  END
  
  !get the first utf16 sequence
  first_code = parse_hex4(buffer, first_sequence + 1)
  
  !check that the code is valid
  IF first_code >= 0DC00h AND first_code <= 0DFFFh
    RETURN 0
  END

  !UTF16 surrogate pair
  IF first_code >= 0D800h AND first_code <= 0DBFFh
    second_sequence = first_sequence + 6
    second_code = 0
    sequence_length = 12  ! \uXXXX\uXXXX
      
    IF input_end - second_sequence < 6
      !input ends unexpectedly
      RETURN 0
    END

    IF buffer.content[second_sequence] <> '\' OR buffer.content[second_sequence + 1] <> 'u'
      !missing second half of the surrogate pair
      RETURN 0
    END
    
    !get the second utf16 sequence
    second_code = parse_hex4(buffer, second_sequence + 1)
    !check that the code is valid
    IF second_code < 0DC00h OR second_code > 0DFFFh
      !invalid second half of the surrogate pair
      RETURN 0
    END
    
    !calculate the unicode codepoint from the surrogate pair
    codepoint = 010000h + BOR(BSHIFT(BAND(first_code, 03FFh), 10), BAND(second_code, 03FFh))
  ELSE
    sequence_length = 6 ! \uXXXX
    codepoint = first_code
  END
  
  !encode as UTF-8
  !takes at maximum 4 bytes to encode:
  !11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
  IF codepoint < 080h
    !normal ascii, encoding 0xxxxxxx
    utf8_length = 1
  ELSIF codepoint < 0800h
    !two bytes, encoding 110xxxxx 10xxxxxx
    utf8_length = 2
    first_byte_mark = 0C0h  ! 11000000
  ELSIF codepoint < 010000h
    !three bytes, encoding 1110xxxx 10xxxxxx 10xxxxxx
    utf8_length = 3
    first_byte_mark = 0E0h  ! 11100000
  ELSIF codepoint < 010FFFFh
    !four bytes, encoding 1110xxxx 10xxxxxx 10xxxxxx 10xxxxxx
    utf8_length = 4
    first_byte_mark = 0F0h  ! 11110000
  ELSE
    !invalid unicode codepoint
    RETURN 0
  END
  
  !encode as utf8
  LOOP utf8_position = utf8_length - 1 TO 1 BY -1
    !10xxxxxx
    output[utf8_position + 1] = CHR(BAND(BOR(codepoint, 080h), 0BFh))
    codepoint = BSHIFT(codepoint, -6)
  END
  
  !encode first byte
  IF utf8_length > 1
    output[1] = CHR(BAND(BOR(codepoint, first_byte_mark), 0FFh))
  ELSE
    output[1] = CHR(BAND(codepoint, 07Fh))
  END

  RETURN sequence_length

skip_utf8_bom                 PROCEDURE(*TParseBuffer buffer)
  CODE
  IF buffer.pos <> 1 OR buffer.len < 3
    RETURN
  END
  
  IF buffer.content[1 : 3] = '<0EFh,0BBh,0BFh>'
    buffer.pos += 3
  END

buffer_skip_whitespace        PROCEDURE(*TParseBuffer buffer)
i                               LONG, AUTO
  CODE
  LOOP i = buffer.pos TO buffer.len
    IF VAL(buffer.content[i]) > 32
      BREAK
    END
    
    buffer.pos += 1
  END
  IF buffer.pos = buffer.len
    buffer.pos -= 1
  END

!!!endregion

!!!region cJSON
cJSON.Construct               PROCEDURE()
  CODE
  
cJSON.Destruct                PROCEDURE()
  CODE
!  json::DebugInfo('Destruct, type = '& SELF.type)
  IF SELF.name &= NULL
!    json::DebugInfo('Destruct, name = '& 'NULL')
  ELSE
!    json::DebugInfo('Destruct, name = '& SELF.name)
    DISPOSE(SELF.name)
  END
  IF SELF.valuestring &= NULL
!    json::DebugInfo('Destruct, valuestring = '& 'NULL')
  ELSE
!    json::DebugInfo('Destruct, valuestring = '& SELF.valuestring)
    DISPOSE(SELF.valuestring)
  END

cJSON.ToString                PROCEDURE(BOOL pFormat = FALSE)
buffer                          LIKE(TPrintBuffer)
printed                         DynStr
  CODE
  buffer.printed &= printed
  buffer.format = pFormat
  print_value(SELF, buffer)
  RETURN buffer.printed.Str()

cJSON.Delete                  PROCEDURE()
item                            &cJSON
next                            &cJSON
  CODE
  item &= SELF
  LOOP WHILE (NOT item &= NULL)
    next &= item.next
    IF (NOT BAND(item.type, cJSON_IsReference)) AND (NOT item.child &= NULL)
      item.child.Delete()
    END
    IF (NOT BAND(item.type, cJSON_IsReference)) AND (NOT item.valuestring &= NULL)
      DISPOSE(item.valuestring)
      item.valuestring &= NULL
    END
    IF (NOT BAND(item.type, cJSON_StringIsConst)) AND (NOT item.name &= NULL)
      DISPOSE(item.name)
      item.name &= NULL
    END
    DISPOSE(item)
    item &= next
  END
    
cJSON.GetArraySize            PROCEDURE()
child                           &cJSON
sz                              LONG(0)
  CODE
  child &= SELF.child
  LOOP WHILE (NOT child &= NULL)
    sz += 1
    child &= child.next
  END
  
  !FIXME: Can overflow here. Cannot be fixed without breaking the API
  
  RETURN sz
  
cJSON.GetArrayItem            PROCEDURE(LONG index)
  CODE
  IF index < 0
    RETURN NULL
  END
  
  RETURN get_array_item(SELF, index)

cJSON.GetObjectItem           PROCEDURE(STRING str, BOOL caseSensitive = FALSE)
  CODE
  RETURN get_object_item(SELF, str, caseSensitive)
  
cJSON.GetError                PROCEDURE()
  CODE
  RETURN ''
  
cJSON.GetStringValue          PROCEDURE()
  CODE
  IF NOT SELF.IsString()
    RETURN ''
  END
  
  RETURN SELF.valuestring
  
cJSON.IsInvalid               PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Invalid)
  
cJSON.IsFalse                 PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_False)
  
cJSON.IsTrue                  PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_True)
  
cJSON.IsBool                  PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, BOR(cJSON_True, cJSON_False)) <> 0)
  
cJSON.IsNull                  PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_NULL)
  
cJSON.IsNumber                PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Number)
  
cJSON.IsString                PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_String)
  
cJSON.IsArray                 PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Array)
  
cJSON.IsObject                PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Object)
  
cJSON.IsRaw                   PROCEDURE()
  CODE
  RETURN CHOOSE(BAND(SELF.type, 0FFh) = cJSON_Raw)
  
cJSON.AddItemToArray          PROCEDURE(cJSON item)
  CODE
  add_item_to_array(SELF, item)
  
cJSON.AddItemToObject         PROCEDURE(STRING str, cJSON item)
  CODE
  add_item_to_object(SELF, str, item, FALSE)

!Add an item to an object with constant string as key
cJSON.AddItemToObjectCS       PROCEDURE(STRING str, cJSON item)
  CODE
  add_item_to_object(SELF, str, item, TRUE)
  
cJSON.AddItemReferenceToArray PROCEDURE(*cJSON item)
  CODE
  add_item_to_array(SELF, create_reference(item))

cJSON.AddItemReferenceToObject    PROCEDURE(STRING str, *cJSON item)
  CODE
  add_item_to_object(SELF, str, create_reference(item), FALSE)
  
cJSON.DetachItemViaPointer    PROCEDURE(*cJSON item)
  CODE
  IF item &= NULL
    RETURN NULL
  END
  
  IF item.prev &= NULL
    !not the first element
    item.prev.next &= item.next
  END
  IF item.next &= NULL
    !not the last element
    item.next.prev &= item.prev
  END

  IF item &= SELF.child
    !first element
    SELF.child &= item.next
  END
  
  !make sure the detached item doesn't point anywhere anymore
  item.prev &= NULL
  item.next &= NULL

  RETURN item
  
cJSON.DetachItemFromArray     PROCEDURE(LONG which)
  CODE
  IF which < 1
    RETURN NULL
  END
  
  RETURN SELF.DetachItemViaPointer(get_array_item(SELF, which))
  
cJSON.DeleteItemFromArray     PROCEDURE(LONG which)
item                            &cJSON
  CODE
  item &= SELF.DetachItemFromArray(which)
  IF NOT item &= NULL
    item.Delete()
  END

cJSON.DetachItemFromObject    PROCEDURE(STRING str, BOOL caseSensitive = FALSE)
item                            &cJSON
  CODE
  item &= SELF.GetObjectItem(str, caseSensitive)
  RETURN SELF.DetachItemViaPointer(item)
  
cJSON.DeleteItemFromObject    PROCEDURE(STRING str, BOOL caseSensitive = FALSE)
item                            &cJSON
  CODE
  item &= SELF.DetachItemFromObject(str, caseSensitive)
  IF NOT item &= NULL
    item.Delete()
  END
  
!Replace array/object items with new ones.
cJSON.InsertItemInArray       PROCEDURE(LONG which, cJSON newitem)
after_inserted                  &cJSON
  CODE
  IF which < 1
    RETURN
  END
  
  after_inserted &= get_array_item(SELF, which)
  IF after_inserted &= NULL
    add_item_to_array(SELF, newitem)
    RETURN
  END

  newitem.next &= after_inserted
  newitem.prev &= after_inserted.prev
  after_inserted.prev &= newitem
  IF after_inserted &= SELF.child
    SELF.child &= newitem
  ELSE
    newitem.prev.next &= newitem
  END
  
cJSON.ReplaceItemViaPointer   PROCEDURE(*cJSON item, *cJSON replacement)
  CODE
  IF item &= NULL OR replacement &= NULL
    RETURN FALSE
  END
  
  IF replacement &= item
    RETURN TRUE
  END

  replacement.next &= item.next
  replacement.prev &= item.prev

  IF NOT replacement.next &= NULL
    replacement.next.prev &= replacement
  END

  IF NOT replacement.prev &= NULL
    replacement.prev.next &= replacement
  END

  IF SELF.child &= item
    SELF.child &= replacement
  END

  item.next &= NULL
  item.prev &= NULL
  item.Delete()

  RETURN TRUE
  
cJSON.ReplaceItemInArray      PROCEDURE(LONG which, *cJSON newitem)
  CODE
  IF which < 1
    RETURN
  END
  
  SELF.ReplaceItemViaPointer(get_array_item(SELF, which), newitem)
  
cJSON.ReplaceItemInObject     PROCEDURE(STRING str, *cJSON newitem, BOOL caseSensitive = FALSE)
  CODE
  replace_item_in_object(SELF, str, newitem, caseSensitive)
  
!cJSON.Duplicate     PROCEDURE(BOOL recurse)
!  CODE
!  RETURN NULL
  
!cJSON.Compare       PROCEDURE(cJSON that, BOOL caseSensitive)
!  CODE
!  RETURN FALSE
  
!cJSON.Minify        PROCEDURE(STRING json)
!  CODE
  
cJSON.AddNullToObject         PROCEDURE(STRING name)
factory                         cJSONFactory
null_item                       &cJSON
  CODE
  null_item &= factory.CreateNull()
  IF add_item_to_object(SELF, name, null_item, FALSE)
    RETURN null_item
  END
  
  null_item.Delete()
  RETURN NULL
  
cJSON.AddTrueToObject         PROCEDURE(STRING name)
factory                         cJSONFactory
true_item                       &cJSON
  CODE
  true_item &= factory.CreateTrue()
  IF add_item_to_object(SELF, name, true_item, FALSE)
    RETURN true_item
  END
  
  true_item.Delete()
  RETURN NULL
  
cJSON.AddFalseToObject        PROCEDURE(STRING name)
factory                         cJSONFactory
false_item                      &cJSON
  CODE
  false_item &= factory.CreateFalse()
  IF add_item_to_object(SELF, name, false_item, FALSE)
    RETURN false_item
  END
  
  false_item.Delete()
  RETURN NULL
  
cJSON.AddBoolToObject         PROCEDURE(STRING name, BOOL boolean)
factory                         cJSONFactory
bool_item                       &cJSON
  CODE
  bool_item &= factory.CreateBool(boolean)
  IF add_item_to_object(SELF, name, bool_item, FALSE)
    RETURN bool_item
  END
  
  bool_item.Delete()
  RETURN NULL
  
cJSON.AddNumberToObject       PROCEDURE(STRING name, REAL number)
factory                         cJSONFactory
number_item                     &cJSON
  CODE
  number_item &= factory.CreateNumber(number)
  IF add_item_to_object(SELF, name, number_item, FALSE)
    RETURN number_item
  END
  
  number_item.Delete()
  RETURN NULL
  
cJSON.AddStringToObject       PROCEDURE(STRING name, STRING string)
factory                         cJSONFactory
string_item                     &cJSON
  CODE
  string_item &= factory.CreateString(string)
  IF add_item_to_object(SELF, name, string_item, FALSE)
    RETURN string_item
  END
  
  string_item.Delete()
  RETURN NULL
  
cJSON.AddRawToObject          PROCEDURE(STRING name, STRING raw)
factory                         cJSONFactory
raw_item                        &cJSON
  CODE
  raw_item &= factory.CreateRaw(raw)
  IF add_item_to_object(SELF, name, raw_item, FALSE)
    RETURN raw_item
  END
  
  raw_item.Delete()
  RETURN NULL
  
cJSON.AddObjectToObject       PROCEDURE(STRING name)
factory                         cJSONFactory
object_item                     &cJSON
  CODE
  object_item &= factory.CreateObject()
  IF add_item_to_object(SELF, name, object_item, FALSE)
    RETURN object_item
  END
  
  object_item.Delete()
  RETURN NULL
  
cJSON.AddArrayToObject        PROCEDURE(STRING name)
factory                         cJSONFactory
array                           &cJSON
  CODE
  array &= factory.CreateArray()
  IF add_item_to_object(SELF, name, array, FALSE)
    RETURN array
  END
  
  array.Delete()
  RETURN NULL

!!!endregion
  
!!!region cJSONFactory
cJSONFactory.CreateNull       PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Null
  RETURN item
  
cJSONFactory.CreateTrue       PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_True
  RETURN item
  
cJSONFactory.CreateFalse      PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_False
  RETURN item
  
cJSONFactory.CreateBool       PROCEDURE(BOOL b)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = CHOOSE(b = TRUE, cJSON_True, cJSON_False)
  RETURN item
  
cJSONFactory.CreateNumber     PROCEDURE(REAL num)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Number
  item.valuedouble = num
  
  !use saturation in case of overflow
  IF num >= INT_MAX
    item.valueint = INT_MAX
  ELSIF num <= INT_MIN
    item.valueint = INT_MIN
  ELSE
    item.valueint = num
  END

  RETURN item
  
cJSONFactory.CreateString     PROCEDURE(STRING str)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_String
  item.valuestring &= NEW STRING(LEN(CLIP(str)))
  item.valuestring = CLIP(str)
  
  RETURN item
  
cJSONFactory.CreateRaw        PROCEDURE(STRING raw)
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Raw
  item.valuestring &= NEW STRING(LEN(CLIP(raw)))
  item.valuestring = CLIP(raw)
  
  RETURN item
  
cJSONFactory.CreateArray      PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Array
  
  RETURN item
  
cJSONFactory.CreateObject     PROCEDURE()
item                            &cJSON
  CODE
  item &= NEW cJSON
  item.type = cJSON_Object
  
  RETURN item
  
cJSONFactory.CreateStringReference    PROCEDURE(*STRING str)
item                                    &cJSON
  CODE
  item &= NEW cJSON
  item.type = BOR(cJSON_String, cJSON_IsReference)
  item.valuestring &= str
  
  RETURN item

cJSONFactory.CreateObjectReference    PROCEDURE(*cJSON child)
item                                    &cJSON
  CODE
  item &= NEW cJSON
  item.type = BOR(cJSON_Object, cJSON_IsReference)
  item.child &= child
  
  RETURN item
  
cJSONFactory.CreateArrayReference PROCEDURE(*cJSON child)
item                                &cJSON
  CODE
  item &= NEW cJSON
  item.type = BOR(cJSON_Array, cJSON_IsReference)
  item.child &= child
  
  RETURN item
  
cJSONFactory.CreateIntArray   PROCEDURE(LONG[] numbers)
i                               LONG, AUTO
n                               &cJSON
p                               &cJSON
a                               &cJSON
  CODE
  a &= SELF.CreateArray()
  
  LOOP i = 1 TO MAXIMUM(numbers, 1)
    IF NOT a &= NULL
      n &= SELF.CreateNumber(numbers[i])
      IF n &= NULL
        a.Delete()
        RETURN NULL
      END
      
      IF i = 1
        a.child &= n
      ELSE
        suffix_object(p, n)
      END
      
      p &= n
    END
  END
  
  RETURN a

cJSONFactory.CreateDoubleArray    PROCEDURE(REAL[] numbers)
i                                   LONG, AUTO
n                                   &cJSON
p                                   &cJSON
a                                   &cJSON
  CODE
  a &= SELF.CreateArray()
  
  LOOP i = 1 TO MAXIMUM(numbers, 1)
    IF NOT a &= NULL
      n &= SELF.CreateNumber(numbers[i])
      IF n &= NULL
        a.Delete()
        RETURN NULL
      END
      
      IF i = 1
        a.child &= n
      ELSE
        suffix_object(p, n)
      END
      
      p &= n
    END
  END
  
  RETURN a
  
cJSONFactory.CreateStringArray    PROCEDURE(STRING[] strings)
i                                   LONG, AUTO
n                                   &cJSON
p                                   &cJSON
a                                   &cJSON
  CODE
  a &= SELF.CreateArray()
  
  LOOP i = 1 TO MAXIMUM(strings, 1)
    IF NOT a &= NULL
      n &= SELF.CreateString(strings[i])
      IF n &= NULL
        a.Delete()
        RETURN NULL
      END
      
      IF i = 1
        a.child &= n
      ELSE
        suffix_object(p, n)
      END
      
      p &= n
    END
  END
  
  RETURN a

cJSONFactory.Parse            PROCEDURE(STRING value)
item                            &cJSON
buffer                          LIKE(TParseBuffer)
  CODE
  IF NOT value
    RETURN NULL
  END
    
  item &= NEW cJSON

  buffer.content &= value
  buffer.len = LEN(CLIP(value))
  buffer.pos = 1
  buffer.depth = 0
  skip_utf8_bom(buffer)
  
  IF NOT parse_value(item, buffer)
    !parse failure. ep is set.
    item.Delete()
    item &= NULL
  END
  
  RETURN item

!!!endregion