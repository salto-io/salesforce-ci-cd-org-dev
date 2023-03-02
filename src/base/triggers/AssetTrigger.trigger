/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : Lavanya Tangati
**/
trigger AssetTrigger on Asset (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
	/*
	if(Trigger.isInsert && Trigger.isBefore){
		AssetTriggerHandler triggerHandler = new AssetTriggerHandler(Trigger.new);
		//triggerHandler.validateActiveAssets(Trigger.new, null);
	} else if(Trigger.isUpdate && Trigger.isBefore) {
		AssetTriggerHandler triggerHandler = new AssetTriggerHandler(Trigger.new, Trigger.oldMap);
	//	triggerHandler.validateActiveAssets(Trigger.new, Trigger.oldMap);
	} else if(Trigger.isDelete && Trigger.isAfter) {
		AssetTriggerHandler triggerHandler = new AssetTriggerHandler(Trigger.old);
		triggerHandler.updateRelatedAccounts();
        new AutomateCSAccountStatus(null, Trigger.oldMap).execute();
	} else if(Trigger.isInsert && Trigger.isAfter) {
		AssetTriggerHandler triggerHandler = new AssetTriggerHandler(Trigger.new);
		triggerHandler.updateRelatedAccounts();
        new AutomateCSAccountStatus(Trigger.new, null).execute();
	} else if(Trigger.isAfter) {
		AssetTriggerHandler triggerHandler = new AssetTriggerHandler(Trigger.new, Trigger.oldMap);
		triggerHandler.updateRelatedAccounts();
        new AutomateCSAccountStatus(Trigger.new, Trigger.oldMap).execute();
	}
	*/
    
     new MetadataTriggerHandler().run();

}