  PROGRAM  

  PRAGMA('project(#pragma link(libcurl.lib))')

  INCLUDE('libcurl.inc')
  INCLUDE('cJSON.inc')

  MAP
    !- curl.SendRequest wrapper
    SendRequest(STRING pApi, DynStr pPostParams, *DynStr pResponse), BOOL
    !- build post params
    Settlements_PostParams(STRING pApiKey, STRING pCityName, LONG pLimit, *DynStr pParams)
    !- extract settlements
    Settlements()
    !- process failed response
    ProcessFail(*cJSON pErrors)
  END

  CODE
  Settlements()

Settlements_PostParams        PROCEDURE(STRING pApiKey, STRING pCityName, LONG pLimit, *DynStr pParams)
!- cJSON objects to build post params
!- post params something like this:
!- {"apiKey": "","modelName": "Address","calledMethod": "searchSettlements","methodProperties": {"CityName": "київ","Limit": 5}}
jParams                         &cJSON
jMethodProps                    &cJSON
  CODE
  !- reset string
  pParams.Trunc(0)
  
  !- methodProperties
  jMethodProps &= json::CreateObject()
  jMethodProps.AddStringToObject('CityName', pCityName)  !- will be converted to utf-8 in .ToString(FALSE, CP_ACP)
  jMethodProps.AddNumberToObject('Limit', pLimit)
  
  !- postparams
  jParams &= json::CreateObject()
  jParams.AddStringToObject('apiKey', pApiKey)
  jParams.AddStringToObject('modelName', 'Address')
  jParams.AddStringToObject('calledMethod', 'searchSettlements')
  jParams.AddItemToObject('methodProperties', jMethodProps)
  
  !- save post params in utf-8
  pParams.Cat(jParams.ToUtf8(FALSE, CP_ACP))
  
  !- cleanup
  jParams.Delete()

Settlements                   PROCEDURE()
api                             STRING('/Address/searchSettlements/')
postparams                      DynStr
response                        DynStr
!- json response
parser                          cJSONFactory
jRoot                           &cJSON  !root object
jSuccess                        &cJSON  !"success" boolean
jAddresses                      &cJSON  !"Addresses" array
!- addresses queue
qAddresses                      QUEUE
Present                           STRING(256)
!... other fields
                                END
qIndex                          LONG, AUTO
  CODE
  !- build post params
  Settlements_PostParams('', 'київ', 5, postparams) 
  
  !- call curl.SendRequest()
  IF SendRequest(api, postparams, response)
    parser.codePage = CP_ACP    !- convert utf8 to ascii
  
    jRoot &= parser.Parse(response.Str())
    IF NOT jRoot &= NULL
      !- check "success" for true/false
      jSuccess &= jRoot.GetObjectItem('success')
      IF NOT jSuccess &= NULL AND jSuccess.IsTrue()
        !- "success":true
        !- extract settlements from "Addresses" array
        jAddresses &= jRoot.FindObjectItem('Addresses')
        IF NOT jAddresses &= NULL
          IF jAddresses.ToQueue(qAddresses)
            MESSAGE('Addresses found: '& RECORDS(qAddresses))
            LOOP qIndex = 1 TO RECORDS(qAddresses)
              GET(qAddresses, qIndex)
              MESSAGE('Present#'& qIndex &': '& CLIP(qAddresses.Present))
            END
          ELSE
            MESSAGE('Error reading Addresses')
          END
        ELSE
          MESSAGE('Addresses not found')
        END
        
      ELSIF NOT jSuccess &= NULL AND jSuccess.IsFalse()
        !- "success":false
        ProcessFail(jRoot.GetObjectItem('errors'))
        
      ELSE
        !- no "success" object,
        !- response in form of { "statusCode": 429, "message": "Rate limit is exceeded. Try again in 14 seconds." }
        MESSAGE('Error: ' & jRoot.GetValue('message'))
      END
    
      !- cleanup
      jRoot.Delete()
    ELSE
      !- parse error
      MESSAGE('Parse failed at position '& parser.GetErrorPosition() &':|'& parser.GetError())
    END
  ELSE
    MESSAGE(response.Str(), 'Error', ICON:Exclamation)
  END
  
ProcessFail                   PROCEDURE(*cJSON pErrors)
jError                          &cJSON
  CODE
  IF NOT pErrors &= NULL AND pErrors.IsArray() AND pErrors.GetArraySize() > 0
    jError &= pErrors.GetArrayItem(1)
    MESSAGE('Error: '& jError.GetStringValue(), 'Error', ICON:Exclamation)
  ELSE
    MESSAGE('Unexpected error', 'Error', ICON:Exclamation)
  END
  
SendRequest                   PROCEDURE(STRING pApi, DynStr pPostParams, *DynStr pResponse)
curl                            TCurlClass
host                            STRING('http://testapi.novaposhta.ua/v2.0/json')
res                             CURLcode, AUTO
ds                              DynStr
  CODE
  !- reset response buffer
  pResponse.Trunc(0)
  
  curl.Init()

  curl.AddHttpHeader('Content-Type: application/json')
  curl.SetHttpHeaders()
  curl.SetCustomRequest('POST')

  curl.SetSSLVerifyHost(false)  
  curl.SetSSLVerifyPeer(FALSE) 
  
  ! set ssl version (see CURL_SSLVERSION_xxx constants)
  curl.SetSSLVersion(CURL_SSLVERSION_DEFAULT)
  
  res = curl.SendRequest(host & pApi, pPostParams.Str(), pResponse.GetInterface())
  IF res <> CURLE_OK
    pResponse.Cat('SendRequest failed: '& curl.StrError(res))
  END

  RETURN CHOOSE(res = CURLE_OK)
