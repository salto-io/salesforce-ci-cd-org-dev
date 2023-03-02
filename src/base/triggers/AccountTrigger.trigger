/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 10-21-2022
 * @last modified by  : Lavanya Tangati
**/
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {

    /*if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.handleCountryCodesAndRegion(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AccountTriggerHandler.handleCountryCodesAndRegion(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isAfter){
        if (Trigger.isInsert) {
            new CreateAccountTasks(Trigger.new, null).execute();
        }
        if (Trigger.isUpdate) {
            new CreateAccountTasks(Trigger.new, Trigger.oldMap).execute();
        }
    }*/
    
    new MetadataTriggerHandler().run();
}