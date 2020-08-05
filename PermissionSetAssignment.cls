/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to assign Permission Sets from one user to an other.
*
* Executing Steps:
* * [Step 1:] enter IDs from source and target user, execute
*
* Known Issues:
* - Error if target user has already an assignemnt for at least one Permission Set from source
* - Error if target user is inactive
* - Error is target user profile doesn't match PermissionSet.LicenseId
* Fine working scope: New user without any permissions and same profile as source
*
* Idea: PermissionSet Balancer for Teams
* Set of user ids -> Set of all assignments of those ids -> add missing assignments to all users
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Heiko Krämer   <sfhcks@myforce.net>
* @created        2020-08-05
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

String sourceUserId = ''; // <-- Place Id of user WITH permissions here
 
// retrieve all permission set / permission set group assignments from source user
List<PermissionSetAssignment> sourceAssignments = new List<PermissionSetAssignment>([SELECT AssigneeId, PermissionSetGroupId, PermissionSetId
                                                                                       FROM PermissionSetAssignment
                                                                                      WHERE AssigneeId = :sourceUserId
                                                                                        AND PermissionSet.IsOwnedByProfile = false]);
 
String targetUserId = ''; // <-- Place Id of user WITHOUT permissions here
List<PermissionSetAssignment> targetAssignments = new List<PermissionSetAssignment>();
 
// loop through source user assignments -> change AssigneeId to targetUserId -> add modified assignment to list
for (PermissionSetAssignment sourceAssignment : sourceAssignments){
   
    PermissionSetAssignment targetAssignment = new PermissionSetAssignment();
    targetAssignment.AssigneeId           = targetUserId;
    targetAssignment.PermissionSetGroupId = sourceAssignment.PermissionSetGroupId;
    targetAssignment.PermissionSetId      = sourceAssignment.PermissionSetId;
 
    targetAssignments.add(targetAssignment);                                   
}
insert targetAssignments; // inserting the list will add the assignments for the target user into the org