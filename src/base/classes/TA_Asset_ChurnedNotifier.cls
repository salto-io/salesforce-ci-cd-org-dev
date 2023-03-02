/******************************************************************************************************************************
* @description    : This trigger handler updates Asset related parent BT_Product and BT_Product parent's Opportunity objects
					Churned value to TRUE.
* @JIRA           : SFCC-1278
* @author         : Saurabh Sood
* @created        : 01/04/2023
* @test class     : TA_Asset_ChurnedNotifier_Test

* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
******************************************************************************************************************************/
public with sharing class TA_Asset_ChurnedNotifier implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
	@testVisible 
    private static final String STATUS_CHURNED = 'Churned';
    
    private class userException extends Exception {}
  
    /**
     * TriggerAction.AfterInsert interface implementation method
     */
    public void AfterInsert(List<Asset> newList) {
        checkAssetChurned(newList);
    }

    /**
     * TriggerAction.AfterUpdate interface implementation method
     */
    public void AfterUpdate(List<Asset> newList, List<Asset> oldList) {
        assetStatusChangedOnUpdate(newList, new Map<Id, Asset>(oldList));
    }
    
    /**
	 * Check if status flipped to 'Churned', call another methods to update BT_Product & its Opportunity churned value 
     * @param newList  List of inserted or Status changed Assets 
     */
    @testVisible 
    private static void checkAssetChurned(List<Asset> newList) {
        Set<Id> churnedAssetIds = new Set<Id>(); 
        for(Asset record: newList) {
            if(record.Status == STATUS_CHURNED) {
                churnedAssetIds.add(record.Id);
            }   
        }
        if(churnedAssetIds.size() == 0) {
            return;
        }
        assetHasChurnedRelatedUpdates(churnedAssetIds);
    }
    
    /**
	 * Asset status flipped to 'Churned' when updated, call another method to verify
     * @param newList  List of new Assets 
     * @param oldMap   Map of old Assets 
     */
    @testVisible 
    private static void assetStatusChangedOnUpdate(List<Asset> newList, Map<Id, Asset> oldMap) {
        List<Asset> changedStatusAssets = new List<Asset> (); 
        for(Asset record: newList) {
            if(record.Status != oldMap.get(record.Id).Status) {
                changedStatusAssets.add(record);
            }   
        }
        checkAssetChurned(changedStatusAssets);
    }
    
     /**
	 * Update BT_Product & its Opportunity to Churned = TRUE for Asset Status is flipped to 'Churned' 
     * @param churnedAssetIds  Set of 'Churned' Asset Ids 
     */
    @testVisible
    private static void assetHasChurnedRelatedUpdates(Set<Id> churnedAssetIds) {
        List<SObject> updateRelatedChurnedRecords = new List<SObject>(); 
        for(Asset record: [
            SELECT Id, BT_Product__r.Id, BT_Product__r.Churned__c, BT_Product__r.Opportunity__r.Id,  BT_Product__r.Opportunity__r.Churned__c 
            FROM Asset 
            WHERE Id IN: churnedAssetIds AND 
            BT_Product__c != NULL
        ]) {
            if(record.BT_Product__r.Churned__c == FALSE) {
                BT_Product__c updateBtProductRecord = new BT_Product__c(Id = record.BT_Product__r.Id, Churned__c = TRUE);
                updateRelatedChurnedRecords.add(updateBtProductRecord);
            }
            if(record.BT_Product__r.Opportunity__r.Churned__c == FALSE) {
                Opportunity updateOpportunityRecord = new Opportunity(Id = record.BT_Product__r.Opportunity__r.Id, Churned__c = TRUE);
                updateRelatedChurnedRecords.add(updateOpportunityRecord);   
            }
        }
        updateRelatedChurnedRecords(updateRelatedChurnedRecords);
    }
    
    /**
	 * Update asset related parent BT_Product & its Opportunity records
     * @param relatedRecords  List of BT_Product & Opportunity records
     */
    @testVisible
    private static void updateRelatedChurnedRecords(List<SObject> relatedRecords) {
         try {
            update relatedRecords;
        } catch(DMLException ex) {
            relatedRecords[0].addError(new userException(ex.getMessage()));
        }
    }
}