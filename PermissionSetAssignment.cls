/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to assign Permission Sets from one user to an other.
*
* Executing Steps:
* * [Step 1:] enter IDs from source and target user, execute
*
* Known Issues:
* - license based permission sets excludet  -> "AND PermissionSet.IsCustom = true"
* tbd: check for available licenses / assign license to target user
*
* tbd: testing with Permission Set Group
*
* Idea: PermissionSet Balancer for Teams
* Set of user ids -> Set of all assignments of those ids -> add missing assignments to all users
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <sfhcks@myforce.net>
* @created        2020-08-05
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

String sourceUserId = ''; // <-- Place Id of user WITH permissions here (active or inactive user)
String targetUserId = ''; // <-- Place Id of user WITHOUT permissions here (only active user)

// retrieve all permission set / permission set group assignments from source user
List<PermissionSetAssignment> sourceAssignments = new List<PermissionSetAssignment>([SELECT AssigneeId, PermissionSetGroupId, PermissionSetId, PermissionSet.LicenseId
                                                                                       FROM PermissionSetAssignment
                                                                                      WHERE AssigneeId = :sourceUserId
                                                                                        AND PermissionSet.IsOwnedByProfile = false
                                                                                        AND PermissionSet.IsCustom = true]); // excludes license based 
system.debug('sourceAssignments: ' + sourceAssignments);
system.debug('sourceAssignments.size(): ' + sourceAssignments.size());

// retriev existig assignments from target user 
List<PermissionSetAssignment> existingTargetAssignments = new List<PermissionSetAssignment>([SELECT PermissionSetGroupId, PermissionSetId
                                                                                               FROM PermissionSetAssignment
                                                                                              WHERE AssigneeId = :targetUserId
                                                                                                AND PermissionSet.IsOwnedByProfile = false]);
system.debug('existingTargetAssignments: ' + existingTargetAssignments);
system.debug('existingTargetAssignments.size(): ' + existingTargetAssignments.size());

// add id values of existing permission sets to a list for later comparison
List<Id> existingTargetPermSetIds = new List<Id>();
for (PermissionSetAssignment psa : existingTargetAssignments) {
    if (psa.PermissionSetId != null) {
        existingTargetPermSetIds.add(psa.PermissionSetId);
    }
    if (psa.PermissionSetGroupId != null) {
        existingTargetPermSetIds.add(psa.PermissionSetGroupId);
    }
}
system.debug('existingTargetPermSetIds: ' + existingTargetPermSetIds);
system.debug('existingTargetPermSetIds.size(): ' + existingTargetPermSetIds.size());
 
// list to store target user assignments
List<PermissionSetAssignment> newTargetAssignments = new List<PermissionSetAssignment>();

// get target user license Id to later exclude if not compatible
List<User> targetUserLicense = [SELECT Profile.UserLicenseId FROM User WHERE Id = :targetUserId];
String targetUserLicenseId   = targetUserLicense.get(0).Profile.UserLicenseId;

// loop through source user assignments -> check if ps already assigned -> add new assignments to list
for (PermissionSetAssignment sourceAssignment : sourceAssignments){
    
    if(existingTargetPermSetIds.contains(sourceAssignment.PermissionSetId)      != true && 
       existingTargetPermSetIds.contains(sourceAssignment.PermissionSetGroupId) != true &&
       (sourceAssignment.PermissionSet.LicenseId == null || sourceAssignment.PermissionSet.LicenseId == targetUserLicenseId)){
        
            PermissionSetAssignment targetAssignment = new PermissionSetAssignment();
            targetAssignment.AssigneeId              = targetUserId;
            targetAssignment.PermissionSetGroupId    = sourceAssignment.PermissionSetGroupId;
            targetAssignment.PermissionSetId         = sourceAssignment.PermissionSetId;
        
            newTargetAssignments.add(targetAssignment);
    }
}
system.debug('newTargetAssignments: ' + newTargetAssignments);
system.debug('newTargetAssignments.size(): ' + newTargetAssignments.size());

insert newTargetAssignments; // inserting the list will add the assignments for the target user into the org