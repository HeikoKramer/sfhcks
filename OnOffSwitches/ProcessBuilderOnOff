/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to switch ON/OFF active Processes in Process Builder (Flow Definitions)
*
* Execute Step 1-3 anonymous to 
* * [Step 1:] find all active Processes in the org >> Store their Data in Cases
* * [Step 2:] turn all Processes OFF (Metadata -> activeVersionNumber -> null)
* * [Step 3:] turn all Processes back ON (active:true)
*
* All prior active Processes will be re-activated. 
* Data Storage Cases will be delted at the end of Step 3.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <sfhcks@myforce.net>
* @created        2020-10-24
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

// START STEP 1 -> "QUERY FLOW DEFINITIONS, STORE FD DATA"
// Retreive active FlowDefinition from Org, store their URL and Metadata in Cases
List<Id> listOfFlowDefinitionIds       = new List<Id>();
List<Case> flowDefinitionStorageCases  = new List<Case>();
Integer flowDefinitionsProcessed       = 0;
 
// Tooling API Call to receive IDs for all active FlowDefinitions
String toolingSOQL = '/services/data/v49.0/tooling/query?q=Select+Id+From+FlowDefinition';
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
System.debug('ResponseBody' + body);
 
// Parse JSON response for IDs >> store IDs in List.
JSONParser parser = JSON.createParser(hresp.getBody());
while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
        (parser.getText() == 'Id')) {
            parser.nextToken();
            listOfFlowDefinitionIds.add(parser.getIdValue());
        }
}
 
// Loop through FlowDefinition IDs and query all Metadata info via Tooling API
for (Id valId : listOfFlowDefinitionIds) {
    String valIdString = '\'' + valId + '\'';
    String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Metadata+From+FlowDefinition+Where+Id+=+';
    String baseURL     = URL.getSalesforceBaseUrl().toExternalForm();
    String endpoint    = baseURL + toolingSOQL + valIdString;
   
    Http NewReq        = new Http();
    HttpRequest hreq   = new HttpRequest();
   
    hreq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    hreq.setTimeout(60000);
    hreq.setEndpoint(endPoint);
    hreq.setMethod('GET');
    HttpResponse hresp = NewReq.send(hreq);
   
    String body = hresp.getBody();
    system.debug('ResponseBody' + body);
    system.debug('Length' + body.length());
   
    
    // Create cases to store data from active FlowDefinition
    // Case Subject is used to store the FlowDefinition endpoint URL
    // Case Description is used to store FlowDefinition Metadada
   
    If (!body.contains('"activeVersionNumber":null')){
        flowDefinitionsProcessed = flowDefinitionsProcessed + 1;
       
        case flowDefinitionStorageCase        = new case();
        flowDefinitionStorageCase.subject     = '/services/data/v48.0/tooling/sobjects/FlowDefinition/' + valId + '# FD' + flowDefinitionsProcessed;
        flowDefinitionStorageCase.description = '{"Metadata' + body.substringAfter('Metadata').removeEnd(']}');
        flowDefinitionStorageCase.origin      = 'Web';
        flowDefinitionStorageCase.status      = 'Closed';
        flowDefinitionStorageCases.add(flowDefinitionStorageCase);
    }
}
insert flowDefinitionStorageCases;
// END STEP 1


// START STEP 2 -> "SWITCH Processes OFF"
// SOQL all prior created cases >> update "activeVersionNumber" to "null" >> process PATCH Calls
List<Case> retrievedFlowDefinitionCases = new List<Case>([SELECT Id, Subject, Description
                                                            FROM Case
                                                           WHERE Subject
                                                            LIKE '%tooling/sobjects/FlowDefinition%']);
system.debug('Number of Cases: ' + retrievedFlowDefinitionCases.size());
 
for (Case flowDefinition : retrievedFlowDefinitionCases){
    String flowDefinitionUrl      = flowDefinition.Subject.substringBeforeLast('# FD');
    String flowDefinitionMetadata = flowDefinition.Description.replace(flowDefinition.Description.substringBetween('activeVersionNumber":', ',"description'), 'null');
    Http h                        = new Http();
    HttpRequest req               = new HttpRequest();
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + flowDefinitionUrl);
    req.setBody(flowDefinitionMetadata);
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('PATCH');
    HttpResponse res = h.send(req);
    system.debug('HttpRequest: ' + req);  
} // END STEP 2


// START STEP 3 -> "SWITCH FLOW DEFINITION ON"
// SOQL all prior created cases >> process PATCH Calls to restore initial state >> delete all prior created cases
List<Case> retrievedFlowDefinitionCases = new List<Case>([SELECT Id, Subject, Description
                                                            FROM Case
                                                           WHERE Subject
                                                            LIKE '%tooling/sobjects/FlowDefinition%']);
System.debug('Number of Cases: ' + retrievedFlowDefinitionCases.size());
 
for (Case flowDefinition : retrievedFlowDefinitionCases){
    String flowDefinitionUrl      = flowDefinition.Subject.substringBeforeLast('# FD');
    String flowDefinitionMetadata = flowDefinition.Description;
    Http h                        = new Http();
    HttpRequest req               = new HttpRequest();
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + flowDefinitionUrl);
    req.setBody(flowDefinitionMetadata);
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('PATCH');
    HttpResponse res = h.send(req);
}
delete retrievedFlowDefinitionCases;
// END STEP 3