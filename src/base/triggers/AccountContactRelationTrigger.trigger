trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
        	AccountContactRelationTriggerHandler.updateBillingContactOnAccount(Trigger.new, null);
    	}
        if (Trigger.isUpdate) {
        	AccountContactRelationTriggerHandler.updateBillingContactOnAccount(Trigger.new, Trigger.oldMap);
    	}
    }
}