// WORK IN PROGRESS
String objectName = 'ApexClass'; // <-- Place the API Name of the Object you would like to query here

// Tooling API Call to receive IDs for all active Objects
String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Id+From+' + objectName; // + '+Where+Active+=+true';

String apiResponseBody = apiResponse();
system.debug('apiResponseBody: ' + apiResponseBody);

public static String apiResponse() { 
    String baseURL     = URL.getSalesforceBaseUrl().toExternalForm();
    String endpoint    = baseURL + toolingSOQL;
    System.debug('endpoint: ' + endpoint);
    
    Http NewReq        = new Http();
    HttpRequest hreq   = new HttpRequest();
    
    hreq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    hreq.setTimeout(60000);
    hreq.setEndpoint(endPoint);
    hreq.setMethod('GET');
    HttpResponse hresp = NewReq.send(hreq);
    
    String body = hresp.getBody();
    system.debug('ResponseBody: ' + body);
    return body; 
}

Map<String, Object> toolingApiResponseMap = (Map<String, Object>)JSON.deserializeUntyped(apiResponseBody);
system.debug('toolingApiResponseMap: ' + toolingApiResponseMap);
// toolingApiResponseMap: {done=true, entityTypeName=ValidationRule, queryLocator=null, records=({Id=03d5I000000D8y6QAC, attributes={type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D8y6QAC}}, {Id=03d5I000000D91yQAC, attributes={type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D91yQAC}}, {Id=03d5I000000D923QAC, attributes={type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D923QAC}});

List<Object> recordsList = (List<Object>)toolingApiResponseMap.get('records');
system.debug('recordsList: ' + recordsList);
// recordsList: ({Id=03d5I000000D8y6QAC, attributes={type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D8y6QAC}}, {Id=03d5I000000D91yQAC, attributes={type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D91yQAC}}, {Id=03d5I000000D923QAC, attributes={type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D923QAC}})


Integer numberOfRecords  = recordsList.size();
Integer numberOfIndex    = numberOfRecords -1;
Integer i                = 0;
Map<Id, String> idUrlMap = new Map<Id, String>();
system.debug('numberOfRecords: ' + numberOfRecords);

while (i <= numberOfIndex) {
    
    Map<String, Object> recordMap = (Map<String, Object>)recordsList[i];
    system.debug('recordMap: ' + recordMap);
    // recordMap: {Id=03d5I000000D8y6QAC, attributes={type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D8y6QAC}}
    system.debug('Id: '   + recordMap.get('Id'));
    String recordId = String.valueOf(recordMap.get('Id'));
    
    Map<String, Object> recordValueMap = (Map<String, Object>)recordMap.get('attributes');
    system.debug('recordValueMap: ' + recordValueMap);
    // recordValueMap: {type=ValidationRule, url=/services/data/v48.0/tooling/sobjects/ValidationRule/03d5I000000D8y6QAC}
    system.debug('Type: ' + recordValueMap.get('type'));
    system.debug('URL: '  + recordValueMap.get('url'));
    String recordUrl = String.valueOf(recordValueMap.get('url'));
    
    idUrlMap.put(recordId, recordUrl);
    i = i + 1;
}
system.debug('idUrlMap: ' + idUrlMap);


Map<Id, Object> idMetadataMap = new Map<Id, Object>();

for (Id key : idUrlMap.keySet()) {
    toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Metadata+From+' + objectName + '+Where+Id+=\'' + key + '\'';
    String metadataResponseBody = apiResponse();
    system.debug('metadataResponseBody: ' + metadataResponseBody);
    
    /*1*/ 
    Map<String, Object> metadataApiResponseMap = (Map<String, Object>)JSON.deserializeUntyped(metadataResponseBody);
    system.debug('metadataApiResponseMap: ' + metadataApiResponseMap);
    
    /*2*/ 
    List<Object> metadataRecordsList = (List<Object>)metadataApiResponseMap.get('records');
    system.debug('metadataRecordsList: ' + metadataRecordsList);
    
    /*3*/ 
    Map<String, Object> metadataRecordMap = (Map<String, Object>)metadataRecordsList[0];
    system.debug('metadataRecordMap: ' + metadataRecordMap);
    
    idMetadataMap.put(key, metadataRecordMap.get('Metadata'));
    
}
system.debug('idMetadataMap: ' + idMetadataMap);