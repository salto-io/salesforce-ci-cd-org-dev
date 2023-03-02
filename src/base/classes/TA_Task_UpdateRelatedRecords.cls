/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
public class TA_Task_UpdateRelatedRecords implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
	
    public List<Task> newTaskList;
    public List<Task> oldTaskList;
    public Map<Id, Task> oldTaskMap;
    Set<Id> qualifiedRelatedToIds =  new Set<Id>();
    public static Boolean hasExecuted{ get { if(hasExecuted==null) hasExecuted = false; return hasExecuted; } public set;}

	@testVisible
    private static final Id WALLET_OPPORTUNITY_RECORDTYPE_ID = SObjectType.Opportunity
                                                                            .getRecordTypeInfosByDeveloperName()
                                                                            .get('Wallet_Opportunity')
                                                                            .getRecordTypeId();

	@testVisible
    private static final Id CLOUD_PIPELINE_RECORDTYPE_ID = SObjectType.Opportunity
                                                                            .getRecordTypeInfosByDeveloperName()
                                                                            .get('Cloud_Pipeline')
                                                                            .getRecordTypeId();
	
    public void afterInsert(List<Task> newList) {
        this.newTaskList = newList;
        execute();
    }
    
    public void afterUpdate(List<Task> newList, List<Task> oldList) {
        Map<Id, Task> oldMap = new Map<Id, Task>(oldList);
        this.newTaskList = newList;
        this.oldTaskMap = oldMap;
        execute();
    }
    
    public void execute(){
        if(!hasExecuted){
            qualify();
            if(!qualifiedRelatedToIds.isEmpty()){
                updateRelatedRecord();
                hasExecuted = true;
            }
        }
        
    }

    private void qualify(){
        for(Task t : newTaskList){
            String whatId = t.WhatId;
            if(
                t.WhatId != null && whatId.substring(0,3) == '006' && t.Status == 'Completed'
                &&
                (
                    t.Subject == 'Send Survey'
                    ||
                    t.Subject == 'Schedule a debrief call'
                )
                &&
                (
                    oldTaskMap == null
                    ||
                    (
                        oldTaskMap != null
                        &&
                        (
                            t.Subject != oldTaskMap.get(t.Id).Subject
                            ||
                            t.Status != oldTaskMap.get(t.Id).Status
                        )
                    )
                )
            )
            {
                qualifiedRelatedToIds.add(t.WhatId);
            }
        }
    }

    private void updateRelatedRecord(){
        List<Opportunity> updateOpps =  new List<Opportunity>();
        for(Task t  : newTaskList){
            Opportunity opp = oppMap.get(t.WhatId);
            if(t.Subject == 'Send Survey'){
                opp.Survey_Sent__c = true;
            }
            if(t.Subject == 'Schedule a debrief call'){
                opp.Debrief_Call_Scheduled__c = true;
            }
                
            updateOpps.add(opp);
        }

        try{
            update updateOpps;
        }
        catch(Exception ex){
            System.debug('Exception: '+ex);
        }
    }

    private Map<Id, Opportunity> oppMap{
        get{
            if(oppMap == null){
                oppMap =  new Map<Id, Opportunity>([SELECT Id, Survey_Sent__c 
                                                    FROM Opportunity 
                                                    WHERE Id IN: qualifiedRelatedToIds 
                                                    AND (RecordTypeId =: WALLET_OPPORTUNITY_RECORDTYPE_ID OR RecordTypeId =: CLOUD_PIPELINE_RECORDTYPE_ID)
                                                    AND (Survey_Sent__c = False OR Debrief_Call_Scheduled__c = False)]);

            }
            return oppMap;
        }
        private set;
    }
}
