/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to switch ON/OFF active Workflow Rules
*
* Execute Step 1-3 anonymous to 
* * [Step 1:] find all active Workflow Rules in the org >> Store their Data in Cases
* * [Step 2:] turn all Workflow Rules OFF (active:false)
* * [Step 3:] turn all Workflow Rules back ON (active:true)
*
* All prior active Workflow Rules will be re-activated. 
* Data Storage Cases will be delted at the end of Step 3.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <sfhcks@myforce.net>
* @created        2020-12-17
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

// START STEP 1 -> "QUERY FLOW DEFINITIONS, STORE FD DATA"
// Retreive active WorkflowRule from Org, store their URL and Metadata in Cases
List<Id> listOfWorkflowRuleIds       = new List<Id>();
List<Case> workflowRuleStorageCases  = new List<Case>();
Integer workflowRulesProcessed       = 0;
 
// Tooling API Call to receive IDs for all active WorkflowRules
String toolingSOQL = '/services/data/v49.0/tooling/query?q=Select+Id+From+WorkflowRule';
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
            listOfWorkflowRuleIds.add(parser.getIdValue());
        }
}
 
// Loop through WorkflowRule IDs and query all Metadata info via Tooling API
for (Id valId : listOfWorkflowRuleIds) {
    String valIdString = '\'' + valId + '\'';
    String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Metadata+From+WorkflowRule+Where+Id+=+';
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
   
    
    // Create cases to store data from active WorkflowRule
    // Case Subject is used to store the WorkflowRule endpoint URL
    // Case Description is used to store WorkflowRule Metadada
   
    If (!body.contains('"activeVersionNumber":null')){
        workflowRulesProcessed = workflowRulesProcessed + 1;
       
        case workflowRuleStorageCase        = new case();
        workflowRuleStorageCase.subject     = '/services/data/v48.0/tooling/sobjects/WorkflowRule/' + valId + '# WFR' + workflowRulesProcessed;
        workflowRuleStorageCase.description = '{"Metadata' + body.substringAfter('Metadata').removeEnd(']}');
        workflowRuleStorageCase.origin      = 'Web';
        workflowRuleStorageCase.status      = 'Closed';
        workflowRuleStorageCases.add(workflowRuleStorageCase);
    }
}
insert workflowRuleStorageCases;
// END STEP 1


// START STEP 2 -> "SWITCH Processes OFF"
// SOQL all prior created cases >> update "activeVersionNumber" to "null" >> process PATCH Calls
List<Case> retrievedWorkflowRuleCases = new List<Case>([SELECT Id, Subject, Description
                                                            FROM Case
                                                           WHERE Subject
                                                            LIKE '%tooling/sobjects/WorkflowRule%']);
system.debug('Number of Cases: ' + retrievedWorkflowRuleCases.size());
 
for (Case WorkflowRule : retrievedWorkflowRuleCases){
    String WorkflowRuleUrl        = WorkflowRule.Subject.substringBeforeLast('# WFR');
    String WorkflowRuleMetadata   = WorkflowRule.Description.replace(WorkflowRule.Description.substringBetween('active":', ',"description'), 'false');
    Http h                        = new Http();
    HttpRequest req               = new HttpRequest();
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + WorkflowRuleUrl);
    req.setBody(WorkflowRuleMetadata);
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('PATCH');
    HttpResponse res = h.send(req);
    system.debug('HttpRequest: ' + req);  
} // END STEP 2


// START STEP 3 -> "SWITCH FLOW DEFINITION ON"
// SOQL all prior created cases >> process PATCH Calls to restore initial state >> delete all prior created cases
List<Case> retrievedWorkflowRuleCases = new List<Case>([SELECT Id, Subject, Description
                                                            FROM Case
                                                           WHERE Subject
                                                            LIKE '%tooling/sobjects/WorkflowRule%']);
System.debug('Number of Cases: ' + retrievedWorkflowRuleCases.size());
 
for (Case WorkflowRule : retrievedWorkflowRuleCases){
    String WorkflowRuleUrl        = WorkflowRule.Subject.substringBeforeLast('# WFR');
    String WorkflowRuleMetadata   = WorkflowRule.Description;
    Http h                        = new Http();
    HttpRequest req               = new HttpRequest();
    req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + WorkflowRuleUrl);
    req.setBody(WorkflowRuleMetadata);
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('PATCH');
    HttpResponse res = h.send(req);
}
delete retrievedWorkflowRuleCases;
// END STEP 3