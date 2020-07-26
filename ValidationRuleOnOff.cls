/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to sitch ON/OFF Validation Rules >> active:true / active:false) <<
*
* Execute Step 1-3 anonymous to 
* * [Step 1:] find all active Validation Rules in the org >> Store their Data in Cases
* * [Step 2:] turn all Validation Rules OFF (active:false)
* * [Step 3:] turn all Validation Rules back ON (active:true)
*
* All prior active Validation Rules will be re-activated. 
* Data Storage Cases will be delted at the end of Step 3.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <ValidationRuleOnOff@myforce.net>
* @created        2020-07-26
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

// START STEP 1 -> "QUERY VALIDATION RULES, STORE VR DATA"
// Retreive active Validation Rules from Org, store their URL and Metadata in Cases
List<Id> listOfValidationRuleIds       = new List<Id>(); 
List<Case> valdidationRuleStorageCases = new List<Case>(); 
Integer validationRulesFound           = 0;
Integer validationRulesProcessed       = 0;

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

// Parse JSON response for IDs >> store IDs in List.
JSONParser parser = JSON.createParser(hresp.getBody());
while (parser.nextToken() != null) {
 if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
     (parser.getText() == 'Id')) {
         parser.nextToken();
         listOfValidationRuleIds.add(parser.getIdValue());
     }
 validationRulesFound = listOfValidationRuleIds.size();
}

// Loop through ValidationRule IDs and query all Metadata info via Tooling API
for (Id valId : listOfValidationRuleIds) {
 String valIdString = '\'' + valId + '\'';
 String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Metadata+From+ValidationRule+Where+Id+=+';
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
 
 validationRulesProcessed = validationRulesProcessed + 1;
 
 // create cases to store ValidationRule data
 // Case Subject is used to store the Validation Rule endpoint URL
 // Case Description is used to store Validation Rule Metadada
 case valdidationRuleStorageCase        = new case();
 valdidationRuleStorageCase.subject     = '/services/data/v48.0/tooling/sobjects/ValidationRule/' + valId + '# VR' + validationRulesProcessed + '/' + validationRulesFound;
 valdidationRuleStorageCase.description = '{"Metadata' + body.substringAfter('Metadata').removeEnd(']}');
 valdidationRuleStorageCase.origin      = 'Web';
 valdidationRuleStorageCase.status      = 'Closed';
 valdidationRuleStorageCases.add(valdidationRuleStorageCase);
}
insert valdidationRuleStorageCases;
// END STEP 1

// START STEP 2 -> "SWITCH VALIDATION RULES OFF"
// SOQL all prior created cases >> update "active":false >> process PATCH Calls
List<Case> retrievedValidationRuleCases = new List<Case>([SELECT Id, Subject, Description 
                                                            FROM Case 
                                                           WHERE Subject 
                                                            LIKE '%tooling/sobjects/ValidationRule%']);
system.debug('Number of Cases: ' + retrievedValidationRuleCases.size());

for (Case validationRule : retrievedValidationRuleCases){
 
 String validationRuleUrl      = validationRule.Subject.substringBeforeLast('# VR');
 String validationRuleMetadata = validationRule.Description.replace('true}}', 'false}}');
 
 Http h = new Http();
 HttpRequest req = new HttpRequest();
 
 req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + validationRuleUrl);
 req.setBody(validationRuleMetadata);
 
 req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
 req.setHeader('Content-Type', 'application/json');
 
 req.setMethod('PATCH');
 HttpResponse res = h.send(req);
 system.debug('HttpRequest: ' + req);  
} // END STEP 2

// START STEP 3 -> "SWITCH VALIDATION RULES ON" 
// SOQL all prior created cases >> process PATCH Calls to restore initial state >> delete all prior created cases
List<Case> retrievedValidationRuleCases = new List<Case>([SELECT Id, Subject, Description 
                                                            FROM Case 
                                                           WHERE Subject 
                                                            LIKE '%tooling/sobjects/ValidationRule%']);
system.debug('Number of Cases: ' + retrievedValidationRuleCases.size());

for (Case validationRule : retrievedValidationRuleCases){
 
 String validationRuleUrl      = validationRule.Subject.substringBeforeLast('# VR');
 String validationRuleMetadata = validationRule.Description;
 
 Http h = new Http();
 HttpRequest req = new HttpRequest();
 
 req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + validationRuleUrl);
 req.setBody(validationRuleMetadata);
 
 req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
 req.setHeader('Content-Type', 'application/json');
 
 req.setMethod('PATCH');
 HttpResponse res = h.send(req);
 system.debug('HttpRequest: ' + req);  
}
delete retrievedValidationRuleCases; 
// END STEP 3