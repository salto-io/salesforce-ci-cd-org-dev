trigger LeadTrigger on Lead (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    /*
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.handleCountryCodesAndRegion(Trigger.new);
        }
        if (Trigger.isUpdate) {
            LeadTriggerHandler.handleCountryCodesAndRegion(Trigger.new, Trigger.oldMap);
        }
    }
    */
    new MetadataTriggerHandler().run();
}