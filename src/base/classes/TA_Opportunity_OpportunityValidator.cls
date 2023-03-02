/**
 * @description       : This class is for all Custom Validations on Opportunity
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 12-09-2022
 * @last modified by  : Lavanya Tangati
**/
public with sharing class TA_Opportunity_OpportunityValidator implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    List<Opportunity> newList;
    Map<Id, Opportunity> oldMap;
    Set<Id> qualifiedOppIds =  new Set<Id>();
    Set<String> disqualifiedStages = new Set<String>{'Executed', 'Closed Won'};
    @testvisible private static final Id WALLET_OPPORTUNITY_RECORDTYPE_ID = SObjectType.Opportunity
                                                                .getRecordTypeInfosByDeveloperName()
                                                                .get('Wallet_Opportunity')
                                                                .getRecordTypeId();
    
    public void BeforeInsert(List<Opportunity> newList) {
        this.newList = newList;
        handleCustomValidations();
    }

    public void BeforeUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        this.newList = newList;
        this.oldMap = new Map<Id, Opportunity>(oldList);
        handleCustomValidations();
    }

    public void handleCustomValidations(){
        for(Opportunity opp : newList){
            if(
                opp.RecordTypeId == WALLET_OPPORTUNITY_RECORDTYPE_ID
                &&
                disqualifiedStages.contains(opp.StageName)
                &&
                opp.Wallet_Opportunity_Type__c == 'Wallet Campaign/Quest'
                &&
                (
                    oldMap == null
                    ||
                    ( 
                        oldMap != null 
                        &&
                        (
                            opp.StageName != oldMap.get(opp.Id).StageName
                            ||
                            opp.Wallet_Opportunity_Type__c != oldMap.get(opp.Id).Wallet_Opportunity_Type__c
                        ) 
                    )
                )
            ){
                qualifiedOppIds.add(opp.Id);
            }
        }

        for(Opportunity opp : newList){
            if(!qualifiedOppIds.isEmpty() && qualifiedOppIds.contains(opp.Id) && oppFiles.get(opp.Id).isEmpty()){
                opp.addError(Label.Validation_Error_Wallet_Opp_Type_And_NoFiles);
            }
        }

    }


    private Map<Id, List<ContentDocumentLink>> oppFiles {
        get{
            if(oppFiles == null){
                oppFiles =  new  Map<Id, List<ContentDocumentLink>>();
                for(Opportunity opp : [SELECT Id, (SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks) 
                                                FROM Opportunity WHERE Id IN: qualifiedOppIds]){
                    oppFiles.put(opp.Id, opp.ContentDocumentLinks);
                }
            }
            return oppFiles;
        }
        private set;
    }
}