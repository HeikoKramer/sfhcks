# Salesforce H@cks
*stuff I'd like to keep …* 

## ~/EmailAlertReceipients.cls
Had to find all Email Alerts which where sending mails to a certain public group.  
Wrote this Anonymous Apex to find a receipent in alert metadata using Tooling API.

### How to execute 
Just specify your receipient in line 23 and fire >> results in the debug log
![receipient](https://github.com/HeikoKramer/sfhcks/blob/master/img/receipient.png)

## ~/ValidationRuleOnOff.cls
Trouble with some Validation Rules while loading data into a Sandbox …  
So why not switch them all off and back on again when we're done?

All we need is this 3 Steps **anonymous Apex ON/OFF switch for Validation Rules**  
![comments](https://github.com/HeikoKramer/sfhcks/blob/master/img/comments.png)


### Step 1 
some VRs in the org … some active, some inactive  
![vrBefore](https://github.com/HeikoKramer/sfhcks/blob/master/img/vrBefore.png)

execute STEP 1 will use the Tooling API to find active VRs and store their data in Cases

see … three cases created in demo org (testes with 39 Validation Rules in Sandbox)  
![cases](https://github.com/HeikoKramer/sfhcks/blob/master/img/cases.png)

The VR's enpoint get stored in the Subject, the Metadata in the Description of the Case  
![caseDetail](https://github.com/HeikoKramer/sfhcks/blob/master/img/caseDetail.png)


### Step 2
execute STEP 2 change Metadata active:false and perform a PATCH method call on all VRs  

All Validation Rules get switched OFF  
![vrWhile](https://github.com/HeikoKramer/sfhcks/blob/master/img/vrWhile.png)


### Step 3
when all loads are done, STEP 3 can be executed to restore the prior VC state  

prior active Validation Rules get switched ON  
![vrAfter](https://github.com/HeikoKramer/sfhcks/blob/master/img/vrAfter.png)

those data storage cases get deleted at the end of STEP 3 
