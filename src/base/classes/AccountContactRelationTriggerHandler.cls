public class AccountContactRelationTriggerHandler {
	public static void updateBillingContactOnAccount(
        List<AccountContactRelation> newList,
        Map<Id, AccountContactRelation> oldMap
    ) {
        Map<Id, AccountContactRelation> acrsToUpdate = new Map<Id, AccountContactRelation>();
        List<Id> accountIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        Map<Id, AccountContactRelation> accountACRMap = new Map<Id, AccountContactRelation>();
        for (AccountContactRelation acr : newList) {
            if (acr.Roles != null) {
                List<String> newRoleSelections = acr.Roles.split(';');
                List<String> oldRoleSelections;
                if (oldMap != null && oldMap.get(acr.Id).Roles != null) {
                    oldRoleSelections = oldMap.get(acr.Id).Roles.split(';');
                }
    			if (newRoleSelections.contains('Billing Primary')){
                    if (oldMap == null 
                        || (oldMap != null && oldMap.get(acr.Id).Roles == null) 
                        || (oldMap != null && oldRoleSelections != null 
                            && !(oldRoleSelections.contains('Billing Primary')))
                       ) {
                        acrsToUpdate.put(acr.Id, acr);
                        accountIds.add(acr.AccountId);
                        contactIds.add(acr.ContactId);
                        accountACRMap.put(acr.AccountId, acr);
                    }
                }
            }
        }
        
        Map<Id, Contact> contactMap;
        Map<Id, Account> accountMap;
        
        if (!contactIds.isEmpty()) {
            contactMap = new Map<Id, Contact>([SELECT Id, 
                                               Email 
                                               FROM Contact 
                                               WHERE Id IN :contactIds]);
        }
        
        if (!accountIds.isEmpty()) {
            accountMap = new Map<Id, Account>([SELECT Id, 
                                               Billing_Contact__c, 
                                               (SELECT id, accountId, contactId, roles FROM AccountContactRelations) 
                                               FROM Account 
                                               WHERE Id IN :accountIds]);
        }
        
        List <Account> accountsToUpdate = new List<Account>();
        
        for (AccountContactRelation acr : newList) {
            if (acrsToUpdate.keySet().Contains(acr.Id)) {
                // check if contact email is blank
                if (contactMap != null && String.isBlank(contactMap.get(acr.ContactId).Email)) {
                    acr.addError('Contact Email should not be blank!');
                }
                
                // check if more than one account contact relationship has billing primary role
                if (accountMap != null) {
                    for (AccountContactRelation r : accountMap.get(acr.AccountId).AccountContactRelations) {
                        if (r.Id != acr.Id && r.Roles != null) {
                            List<String> rRoles = r.Roles.split(';');
                            if (rRoles.contains('Billing Primary')) {
                               acr.addError('There is already a contact with role as Billing Primary!'); 
                            }
                        }
                    }
                }
                Account a = new Account();
                a.Id = acr.AccountId;
                a.Billing_Contact__c = acr.ContactId;
                accountsToUpdate.add(a);
            }
        }
        
        if (!accountsToUpdate.isEmpty()) {
        	update accountsToUpdate;
        }
    }
}
