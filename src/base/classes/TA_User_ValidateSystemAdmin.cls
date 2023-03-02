public class TA_User_ValidateSystemAdmin implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    public static final Boolean isSandbox;
    public static final Id adminProfileId;
    public static final Set<String> allowedUsernames = SystemAdminsAllowed.ALLOWED_SYSTEM_ADMINS;

    static {
        Organization organization = [SELECT isSandbox FROM Organization];
        isSandbox = organization.isSandbox;
    }

    static {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        adminProfileId = adminProfile.Id;
    }

    public void BeforeInsert(List<User> newList) {
        execute(newList, null, System.TriggerOperation.BEFORE_INSERT);
    }

    public void BeforeUpdate(List<User> newList, List<User> oldList) {
        execute(newList, oldList, System.TriggerOperation.BEFORE_UPDATE);
    }

    public void execute(List<User> userList, List<User> oldList, System.TriggerOperation triggerOperation) {
        Map<Id,User> oldMap = new Map<Id,User>();
		if (isSandbox && !Test.isRunningTest()) {
            return;
        }

		if(triggerOperation == System.TriggerOperation.BEFORE_UPDATE) {
			oldMap = new Map<Id,User>(oldList);
		}
		
		
        for (User userRecord : userList) {
            Boolean isInAdminList = allowedUsernames.contains(userRecord.Username);
            if (userRecord.ProfileId == adminProfileId && !isInAdminList && userRecord.IsActive) {
                userRecord.addError(
                    'Following username not allowed to be a System Admin: ' + userRecord.Username
                );
            }
            if (
                triggerOperation == System.TriggerOperation.BEFORE_UPDATE &&
                userRecord.ProfileId != adminProfileId &&
				userRecord.ProfileId != oldMap.get(userRecord.Id).ProfileId && 
                isInAdminList &&
                userRecord.IsActive
            ) {
                userRecord.addError(
                    'Following username is a reserved System Admin and must remain a System Admin: ' +
                    userRecord.Username
                );
            }
        }
    }
}
