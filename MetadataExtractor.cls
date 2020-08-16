// WORK IN PROGRESS
// Tooling API Call to receive IDs for all active ValidationRules
String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Id+From+ValidationRule+Where+Active+=+true';
String baseURL     = URL.getSalesforceBaseUrl().toExternalForm();
String endpoint    = baseURL + toolingSOQL;

Http NewReq        = new Http();
HttpRequest hreq   = new HttpRequest();

hreq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
hreq.setTimeout(60000);
hreq.setEndpoint(endPoint);
hreq.setMethod('GET');
HttpResponse hresp = NewReq.send(hreq);

String body = hresp.getBody();
system.debug('ResponseBody' + body);


Map<String, Object> toolingApiResponseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
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



/* EXAMPLE
String jsonInput = '{\n' +
    ' "description" :"An appliance",\n' +
    ' "accessories" : [ "powerCord", ' + 
      '{ "right":"door handle1", ' + 
        '"left":"door handle2" } ],\n' +
    ' "dimensions" : ' + 
      '{ "height" : 5.5 , ' + 
        '"width" : 3.0 , ' + 
        '"depth" : 2.2 },\n' +
    ' "type" : null,\n' +
    ' "inventory" : 2000,\n' +
    ' "price" : 1023.45,\n' +
    ' "isShipped" : true,\n' +
    ' "modelNumber" : "123"\n' +
    '}';
    
Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
// System.assertEquals('An appliance', m.get('description'));

List<Object> a = (List<Object>)m.get('accessories');
// System.assertEquals('powerCord', a[0]); 

Map<String, Object> a2 = (Map<String, Object>)a[1];
// System.assertEquals('door handle1', a2.get('right'));
// System.assertEquals('door handle2', a2.get('left'));

Map<String, Object> dim = (Map<String, Object>)m.get('dimensions');
system.debug('dim: ' + dim);
// System.assertEquals(5.5, dim.get('height'));
// System.assertEquals(3.0, dim.get('width'));
// System.assertEquals(2.2, dim.get('depth'));
// System.assertEquals(null, m.get('type'));
// System.assertEquals(2000, m.get('inventory'));
// System.assertEquals(1023.45, m.get('price'));
// System.assertEquals(true, m.get('isShipped'));
// System.assertEquals('123', m.get('modelNumber'));
*/ 