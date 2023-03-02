/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-03-2023
 * @last modified by  : Lavanya Tangati
**/
trigger TaskTrigger on Task (after insert, after update) {
    /*if(Trigger.isAfter){
        if(Trigger.isInsert){
            new UpdateRelatedRecords(Trigger.new, null).execute();
        }

        if(Trigger.isUpdate){
            new UpdateRelatedRecords(Trigger.new, Trigger.oldMap).execute();
        }
    }*/
    
    new MetadataTriggerHandler().run();
}