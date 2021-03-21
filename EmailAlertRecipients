/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to sitch to find all Email Alerts for a certain recipient
*
* Executing Steps:
* * [Step 1:] replace "alertRecipient" variable below with the recipient your interested in, execute
* * [Step 2:] check debug log to see the Alert Ids 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <sfhcks@myforce.net>
* @created        2020-07-28
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/


/* The recipient is stored in the Metadata of each WorkflowAlert.
** There are many recipient types, you should check how the output for your searched type looks like.
** To check the output copy the Id of an alert with that recipient type
** and paste it at the end of the link below. Check result with >>Workbench REST Explorer<<.
** services/data/v48.0/tooling/query/?q=Select+Metadata+from+WorkflowAlert+Where+Id+=+''
** Example type "Group": recipient: Some_Group_Name
** Example type "User" : recipient: some.name@some-domain.com */
 
String alertRecipient = 'some.name@some-domain.com'; // <-- place recipient here

List<Id> listOfworkflowAlertIds = new List<Id>();
Integer workflowAlertsFound     = 0; 
Integer workflowAlertsProcessed = 0; 
 
// Tooling API Call to receive IDs from WorkflowAlerts
String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Id+From+WorkflowAlert';
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
 
// Parse JSON response for IDs >> store IDs in List.
JSONParser parser = JSON.createParser(hresp.getBody());
while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
        (parser.getText() == 'Id')) {
            parser.nextToken();
            listOfworkflowAlertIds.add(parser.getIdValue());
        }
}
workflowAlertsFound = listOfworkflowAlertIds.size();
system.debug('workflowAlertsFound: ' + workflowAlertsFound);
 
// Loop through WorkflowAlert IDs and query all Metadata info via Tooling API
for (Id workflowAlertId : listOfworkflowAlertIds) {
    String workflowAlertIdString = '\'' + workflowAlertId + '\'';
    String toolingSOQL = '/services/data/v48.0/tooling/query/?q=Select+Metadata+From+WorkflowAlert+Where+Id+=+';
    String baseURL     = URL.getSalesforceBaseUrl().toExternalForm();
    String endpoint    = baseURL + toolingSOQL + workflowAlertIdString;
   
    Http NewReq        = new Http();
    HttpRequest hreq   = new HttpRequest();
   
    hreq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    hreq.setTimeout(60000);
    hreq.setEndpoint(endPoint);
    hreq.setMethod('GET');
    HttpResponse hresp = NewReq.send(hreq);
   
    String body = hresp.getBody();
   
    // check if the response body contains our searched recipient -> if so show the Alert Id
    if (body.contains(alertRecipient)) {
        system.debug('This Alert is send to ' + alertRecipient + ': ' + workflowAlertId);
    }
   
    workflowAlertsProcessed = workflowAlertsProcessed + 1;
}
system.debug('workflowAlertsProcessed: ' + workflowAlertsProcessed);