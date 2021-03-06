/**
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex Class Name : MetadataExtructor
* @author         : Heiko Krämer  <sfhcks@myforce.net>
* @modifiedBy     : Christian Schwabe
* @version        : 1.1 
* @created        : 2020-08-16
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1 : Christian Schwabe
* @modified  :  2020-08-17    
* Avoid unnecessary casting, parse json to typesafe object with wrapper classes, 
* outsource logic in smaller logical groups.
*
* @description
* Apex Class to extract Metadata Information from Objects supported by Tooling API:
* https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/reference_objects_list.htm
* Execute by calling the start methode, hand over object name as a string. 
* Example: MetadataExtractor.start('ApexClass'); 
*
* ───────────────────────────────────────────────────────────────────────────────────────────────────────────
* Things that need to be covered: proper exception handling, make http callout more generic, avoid too many 
* callouts with batchjobs and persist response in custom object for further reporting/analysis.
* ──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public class MetadataExtractor
{
    /**
     * @param metadataType -- <@description>
     */
    public static void start(String metadataType)
    {
        String toolingSoqlForMetadataType = '/services/data/v48.0/tooling/query/?q=Select+Id+From+' + metadataType; // + '+Where+Active+=+true';
        String httpResponseBody = apiResponse(toolingSoqlForMetadataType);
        System.debug('>>>httpResponseBody: ' + httpResponseBody);
        // Needed, because reserved words in json response cannot parsed correctly
        // See also: http://blog.deadlypenguin.com/blog/2016/06/21/parse-json-reserved-words/
        String replacedJson = httpResponseBody.replaceAll('\\bId\\b', 'Id_x');// Exact match.

        MetadataExtractor.QueryResponse queryResponse = convertHttpResponse(replacedJson);
        System.debug('>>>queryResponse: ' + queryResponse);

        List<MetadataExtractor.Record> listOfRecord = queryResponse.records;
        System.debug('>>>listOfRecord: ' + listOfRecord);
        System.debug('>>>Number of records: ' + listOfRecord.size());

        Set<String> setOfMetadataRecordId = new Set<String>();
        Integer limitCallouts = 100;
        Integer index = 1;
        for(MetadataExtractor.Record record : listOfRecord)
        {
            String metadataRecordId = record.Id_x;
            String toolingSoqlForMetadataTypeById = '/services/data/v48.0/tooling/query/?q=Select+Metadata+From+' + metadataType + '+Where+Id+=\'' + metadataRecordId + '\'';

            setOfMetadataRecordId.add(metadataRecordId);
            System.debug('>>>metadataRecordId: ' + metadataRecordId);
            System.debug('>>>record.attributes.url: ' + record.attributes.url);
            System.debug('>>>record.attributes.type: ' + record.attributes.type);

            Map<Id, Object> idMetadataMap = new Map<Id, Object>();

            if(index < 100)// Workaround to avoid System.LimitException: Too many callouts: 101
            {
                String metadataResponseBody = apiResponse(toolingSoqlForMetadataTypeById);
                System.debug('>>>metadataResponseBody: ' + metadataResponseBody);
            }

            index++;
        }
    }

    private static String apiResponse(String toolingSoql) {
        String baseURL  = URL.getSalesforceBaseUrl().toExternalForm();
        String endpoint = baseURL + toolingSOQL;
        System.debug('endpoint: ' + endpoint);
        
        Http http                   = new Http();
        HttpRequest httpRequest     = new HttpRequest();
        
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        httpRequest.setTimeout(60000);
        httpRequest.setEndpoint(endPoint);
        httpRequest.setMethod('GET');
        HttpResponse httpResponse = http.send(httpRequest);
        
        return httpResponse.getBody();
    }

    private static MetadataExtractor.QueryResponse convertHttpResponse(String httpResponseBody)
    {
        JSONParser parser = JSON.createParser(httpResponseBody);
        MetadataExtractor.QueryResponse queryResponse;

        // Parse JSON response. 
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                queryResponse = (MetadataExtractor.QueryResponse)parser.readValueAs(MetadataExtractor.QueryResponse.class);                                           
            }
            
            // For debugging purposes, serialize again to verify what was parsed.
            String s = JSON.serialize(queryResponse);
            System.debug('>>>Serialized MetadataExtractor.QueryResponse: ' + s);
            System.debug('>>>queryResponse: ' + queryResponse);
        }

        return queryResponse;
    }

    public class QueryResponse
    {
        public Integer size           {get;set;}
        public Integer totalSize      {get;set;}
        public String  nextRecordsUrl {get;set;}
        public String  queryLocator   {get;set;}
        public String  entityTypeName {get;set;}
        public List<MetadataExtractor.Record> records {get;set;}

        public QueryResponse(
            Integer size,
            Integer totalSize,
            String  nextRecordsUrl,
            String  queryLocator,
            String  entityTypeName,
            List<MetadataExtractor.Record> records
        ){
            this.size           = size;
            this.totalSize      = totalSize;
            this.nextRecordsUrl = nextRecordsUrl;
            this.queryLocator   = queryLocator;
            this.entityTypeName = entityTypeName;
            this.records        = records;
        }
    }

    public class Record
    {
        public MetadataExtractor.Attributes attributes {get;set;}
        public String Id_x {get;set;}

        public Record(MetadataExtractor.Attributes attributes, String Id_x)
        {
            this.attributes = attributes;
            this.Id_x       = Id_x;
        }
    }

    public class Attributes
    {
        public String type {get;set;}
        public String url  {get;set;}

        public Attributes(String type, String url)
        {
            this.type = type;
            this.url  = url;
        }
    }
}



/* ############ ORIGINAL VERSION ############# KEPT FOR COMPARISON #############
String metadataType = 'ApexClass'; // <-- Place the API Name of the Object you would like to query here


String apiResponseBody = apiResponse();
system.debug('apiResponseBody: ' + apiResponseBody);

private static String apiResponse(String toolingSoql) {
    String baseURL  = URL.getSalesforceBaseUrl().toExternalForm();
    String endpoint = baseURL + toolingSOQL;
    System.debug('endpoint: ' + endpoint);
    
    Http http                   = new Http();
    HttpRequest httpRequest     = new HttpRequest();
    
    httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    httpRequest.setTimeout(60000);
    httpRequest.setEndpoint(endPoint);
    httpRequest.setMethod('GET');
    HttpResponse httpResponse = http.send(httpRequest);
    
    String body = httpResponse.getBody();
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
    toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Metadata+From+' + metadataType + '+Where+Id+=\'' + key + '\'';
    String metadataResponseBody = apiResponse();
    system.debug('metadataResponseBody: ' + metadataResponseBody);
    
    // 1
    Map<String, Object> metadataApiResponseMap = (Map<String, Object>)JSON.deserializeUntyped(metadataResponseBody);
    system.debug('metadataApiResponseMap: ' + metadataApiResponseMap);
    
    // 2
    List<Object> metadataRecordsList = (List<Object>)metadataApiResponseMap.get('records');
    system.debug('metadataRecordsList: ' + metadataRecordsList);
    
    // 3 
    Map<String, Object> metadataRecordMap = (Map<String, Object>)metadataRecordsList[0];
    system.debug('metadataRecordMap: ' + metadataRecordMap);

    idMetadataMap.put(key, metadataRecordMap.get('Metadata'));
    
}
system.debug('idMetadataMap: ' + idMetadataMap);*/
