/**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to extract Metadata Information from Objects supported by Tooling API:
* https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/reference_objects_list.htm
*
* Output is a Map<Id, Object> idMetadataMap --> RecordId followed by the Metadata.
* Example(ApexClass) idMetadataMap: {01p5I0000004mI7QAI={apiVersion=48.0, packageVersions=(), status=Active, 
* urls=null}, 01p5I0000004q14QAA={apiVersion=48.0, packageVersions=(), status=Active, urls=null}
*
* Usage: That map could be used to manipulate the metadata and update those values vie Tooling API.
*
* Known Issues: 
* - no exception handling yet, was just earlier running into "too many calls" error
* - - some sort of limit check shoul be implemented. 
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <sfhcks@myforce.net>
* @created        2020-08-16
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

String objectName = 'ApexClass'; // <-- Place the API Name of the Object you would like to query here

// Tooling API Call to receive IDs for all active Objects
String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Id+From+' + objectName; // + '+Where+Active+=+true';

String apiResponseBody = apiResponse();
system.debug('apiResponseBody: ' + apiResponseBody);

public static String apiResponse() { 
    String baseURL  = URL.getSalesforceBaseUrl().toExternalForm();
    String endpoint = baseURL + toolingSOQL;
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

List<Object> recordsList = (List<Object>)toolingApiResponseMap.get('records');
system.debug('recordsList: ' + recordsList);


Integer numberOfRecords  = recordsList.size();
Integer numberOfIndex    = numberOfRecords -1;
Integer i                = 0;
Map<Id, String> idUrlMap = new Map<Id, String>();
system.debug('numberOfRecords: ' + numberOfRecords);

while (i <= numberOfIndex) {
    
    Map<String, Object> recordMap = (Map<String, Object>)recordsList[i];
    system.debug('recordMap: ' + recordMap);
    system.debug('Id: ' + recordMap.get('Id'));
    String recordId = String.valueOf(recordMap.get('Id'));
    
    Map<String, Object> recordValueMap = (Map<String, Object>)recordMap.get('attributes');
    system.debug('recordValueMap: ' + recordValueMap);
    system.debug('Type: '           + recordValueMap.get('type'));
    system.debug('URL: '            + recordValueMap.get('url'));
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