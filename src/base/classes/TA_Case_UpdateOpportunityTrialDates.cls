/******************************************************************************************************************************
* @description    : Handler class migrated from "Case Processes" PB to TAF framework, updating Parent Opportunity Trial Start/End
                    Date fields value based on Trail Case RecordType's Trial Start/End Date values
* @JIRA           : SFCC-1280
* @author         : Saurabh Sood
* @created        : 01/19/2023
* @test class     : TA_Case_UpdateOpportunityTrialDates_Test

* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
******************************************************************************************************************************/

public with sharing class TA_Case_UpdateOpportunityTrialDates implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {

    @testvisible private static final Id TRIAL_PIPELINE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Trial_Pipeline').getRecordTypeId();

    public void afterInsert(List<Case> newList) {
        trialCasesHandler(newList);
    }

    public void afterUpdate(List<Case> newList, List<Case> oldList) {
        trialDateChangedHandler(newList, new Map<Id, Case>(oldList));
    }

    /**
     * When case trial date changes, store records in list to update parent Opportunity Trial date fields
     * @param newList  Updated case records
     * @param newList  Updated old case records map
     */
    private static void trialDateChangedHandler(List<Case> newList, Map<Id, Case> oldMap) {
        List<Case> changedTrialCases = new List<Case>();

         for(Case record: newList) {
             Case oldRecord = oldMap.get(record.Id);
            if(record.Trial_Start_Date__c != oldRecord.Trial_Start_Date__c || record.Trial_End_Date__c != oldRecord.Trial_End_Date__c) {
                   changedTrialCases.add(record);
            }
        }
        if(changedTrialCases.size() == 0) {
            return;
        }

        trialCasesHandler(changedTrialCases);
    }

    /**
     * When new or changed trial case records has trial date values, store Opportunity ids to update parent Opportunity
     * trial date values
     * @param newList  Updated case records
     */
    private static void trialCasesHandler(List<Case> newList) {
        Map<Id,Case> trailCaseByOppyId = new Map<Id, Case>();

        for(Case record: newList) {
            if(record.RecordTypeId == TRIAL_PIPELINE_RT_ID && record.Opportunity__c != NULL &&
               (record.Trial_Start_Date__c != NULL || record.Trial_End_Date__c != NULL)) {
                   trailCaseByOppyId.put(record.Opportunity__c, record);
            }
        }
        if(trailCaseByOppyId.size() == 0) {
            return;
        }
        updateRelatedOpportunityTrialValue(trailCaseByOppyId);
    }

    /**
     * When Parent Opportunity Trial Start/End Date does not match with child Case Trial Start/End Date, update parent Opportunity
     * trial date values
     * @param trailCaseByOppyId  Map of oppyId with TrialCase Records
     */
    private static void updateRelatedOpportunityTrialValue(Map<Id, Case> trailCaseByOppyId) {
        List<Opportunity> updateOppyTrialValues = new List<Opportunity>();
        Boolean hasOppyUpdated = false;

        for(Opportunity opp: [SELECT Trial_Start_Date__c, Trial_End_Date__c FROM Opportunity WHERE Id IN: trailCaseByOppyId.keySet()]) {
             Case trialCase = trailCaseByOppyId.get(opp.Id);
            if(opp.Trial_Start_Date__c != trialCase.Trial_Start_Date__c || opp.Trial_End_Date__c != trialCase.Trial_End_Date__c) {
                opp.Trial_Start_Date__c = trialCase.Trial_Start_Date__c;
                opp.Trial_End_Date__c = trialCase.Trial_End_Date__c;
                hasOppyUpdated = true;
            }
            if(hasOppyUpdated) {
                updateOppyTrialValues.add(opp);
            }
            hasOppyUpdated = false;
        }

        update updateOppyTrialValues;
    }
}