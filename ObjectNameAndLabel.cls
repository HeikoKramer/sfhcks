/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to send a list of object API Names & Labels via email.
*
* Executing Steps:
* * [Step 1:] replace "emailRecipients" variable below with your mail address, execute
* * [Step 2:] check your mails 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <sfhcks@myforce.net>
* @created        2020-07-28
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

/* HTML VERSION
** Quick way to get table format: Copy mail body into texteditor >> save as .html file >> open in browser
** Then copy it into Excel or wherever you need it. */

String emailRecipients = 'some.name@some-domain.com'; // <-- PLACE RECIPIENT(S) HERE

String objectNamesAndLabels = '<table style="width:100%"><tr><th>Name</th><th>Label</th></tr>';
Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

for(Schema.SObjectType objType : globalDescribe.values()) {
    
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   
            objectNamesAndLabels = objectNamesAndLabels + '<tr><td>' 
                                                        + objDescribe.getName() 
                                                        + '</td><td>' + objDescribe.getLabel() 
                                                        + '</td></tr>';
}
objectNamesAndLabels = objectNamesAndLabels + '</table>';

Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
message.toAddresses = new String[] { emailRecipients };
message.optOutPolicy = 'FILTER';
message.subject = 'Objects Names & Labels';
message.plainTextBody = objectNamesAndLabels;
Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
 
if (results[0].success)
{
    System.debug('The email was sent successfully.');
} else
{
   System.debug('The email failed to send: ' + results[0].errors[0].message);
} // END HTML VERSION

/* ################################################################################## */

/* PLAIN TEXT VERSION
** If you just need a quick overview on those orgs object names and labels */

String emailRecipients = 'some.name@some-domain.com'; // <-- PLACE RECIPIENT(S) HERE

String objectNamesAndLabels = '';
Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
 
for(Schema.SObjectType objType : globalDescribe.values()) {
    
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();   
            objectNamesAndLabels = objectNamesAndLabels +
                                         'Name: ' + objDescribe.getName()  +
                                      ', Label: ' + objDescribe.getLabel() + '\n';
}
 
Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
message.toAddresses = new String[] { emailRecipients };
message.optOutPolicy = 'FILTER';
message.subject = 'Objects Names & Labels';
message.plainTextBody = objectNamesAndLabels;
Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
 
if (results[0].success)
{
    System.debug('The email was sent successfully.');
} else
{
   System.debug('The email failed to send: ' + results[0].errors[0].message);
} // END PLAIN TEXT VERSION