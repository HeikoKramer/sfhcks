/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Anonymous Apex to assign Permission Sets from one user to an other.
*
* Executing Steps:
* * [Step 1:] enter IDs from source and target user, execute
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