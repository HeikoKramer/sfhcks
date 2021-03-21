# Salesforce H@cks
This repo is a lose collection of Salesforce stuff I find useful enough to keep. <br>
Likely it will mostly contain anonymous Apex scripts, but let's see where this is going. <br> 
I have an other Salesforce related repo for the [command line stuff](https://github.com/HeikoKramer/sfdx) <br>

## ON / OFF Switches
The purpose of my [on-/off switch scripts](https://github.com/HeikoKramer/sfhcks/tree/master/OnOffSwitches) was a full sandbox replacement project. <br> 
We basically loaded production org backup into a partial sandbox via multiple etl jobs. <br>
The last things you need in such a situation are data validations and sorts of triggers. <br>
My scripts step 1&2 are deactivating most of that stuff and keep note of what was active. <br>
When you're done with the load, execute step 3 to easily switch back on all elements. <br>
The below shown method works with **validation rules**, **process builder** and **workflow rules**. <br>
*Apex triggers* wont work unfortunately as they can't be updated by the **tooling api**. <br> 
<br>
**Method:** <br>
* STEP1: Query vr, pb or wfr via **tooling api** -> store their meta data in **cases**. <br>
* STEP2: Loop through those **cases**, switch active elements **off** via **tooling api**. <br>
* STEP3: Loop again through those **cases**, switch prior activated elements back **on** via **tooling api**. <br>

**Start** and **End** of each step are marked within the scripts. <br>
Execute them one-by-one when they are needed. <br>

```java
// START STEP 1 -> "QUERY FLOW DEFINITIONS, STORE FD DATA"
// END STEP 1
```

**NOTE:** You could run into troubles if you've active trigger, routing or validation logic set on the case object. <br>
If you have a lot of rules in your org you might hit api call limits. <br> 
I believe if you have more than 100 elements (total, active + inactive) some script refactoring would be required. <br>
<br>
**Direct links to ON/OFF switch for element:** <br>
[Process Builder](https://github.com/HeikoKramer/sfhcks/blob/master/OnOffSwitches/ProcessBuilderOnOff) <br>
[Validation Rules](https://github.com/HeikoKramer/sfhcks/blob/master/OnOffSwitches/ValidationRuleOnOff) <br>
[Workflow Rules](https://github.com/HeikoKramer/sfhcks/blob/master/OnOffSwitches/WorkflowRuleOnOff) <br>
<br>

## PermissionSetAssignment
[PermissionSetAssignment](https://github.com/HeikoKramer/sfhcks/blob/main/PermissionSetAssignment) assignes Permission Sets from one user to an other. <br> 
Just place source and target user IDs in the script and execute anonymous. <br>

```java
String sourceUserId = ''; // <-- Place Id of user WITH permissions here (active or inactive user)
String targetUserId = ''; // <-- Place Id of user WITHOUT permissions here (only active user)
```

The script queries all permission set assignments of the source user …
and adds those which are missing to the source user. <br>
It is currently written to take only one source and one target user. This could easily be upgraded. <br>
<br>

## ObjectNameAndLabel
This sends you an email with api names & labels of all objects in your org. 
Replace the email address variable in the script with your recipients:  

```java
String emailRecipients = 'some.name@some-domain.com'; // <-- PLACE RECIPIENT(S) HERE
```

The script comes with a plain text and a html version. <br>
I have used the html version as a quick way to get that data in a table format. <br>
Just copy the mail body into a text editor >> save as .html file >> open in browser <br>  
From there, copy it into Excel or wherever you need it. <br>
<br>

## EmailAlertRecipients
Had to find all email alerts which where sending mails to a certain public group.  
Wrote this anonymous apex script to find a recipent with help of the **tooling api**.
