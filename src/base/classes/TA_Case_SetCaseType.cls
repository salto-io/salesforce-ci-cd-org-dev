/******************************************************************************************************************************
* @description    : Handler class migrated from "Refresh CaseType" PB to TAF framework, updating CaseType field based on
					Case Recordtype value stored in KeyValue metadata
* @JIRA           : SFCC-1280
* @author         : Saurabh Sood
* @created        : 01/19/2023
* @test class     : TA_Case_SetCaseType_Test

* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
******************************************************************************************************************************/

public with sharing class TA_Case_SetCaseType implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {

    @testvisible private static final String NAMESPACE = 'Set CaseType By RecordType';
   	private static final Map<Id, Schema.RecordTypeInfo> CASE_RT_MAP_BY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosById();

    /**
	 *The CaseRecordTypeDeveloperName is stored in the metadata along with the CaseType
	 */
  	@testVisible private static Map<String,String> typeByCaseRtDevName {
        get {
            if(typeByCaseRtDevName == null) {
                typeByCaseRtDevName = new Map<String,String>();
                for(KeyValue__mdt mtd: [SELECT Key__c, Value__c
                                        FROM KeyValue__mdt
                                        WHERE Namespace__c =: NAMESPACE
                                        AND IsActive__c = TRUE]) {
                                            typeByCaseRtDevName.put(mtd.Key__c, mtd.Value__c);
                                        }
            }
            return typeByCaseRtDevName;
        }
        private set;
    }

     public void beforeInsert(List<Case> newList) {
        setCaseTypeHandler(newList);
    }

    public void beforeUpdate(List<Case> newList, List<Case> oldList) {
        changedRecordTypeHandler(newList, new Map<Id, Case>(oldList));
    }

	/**
     * Set CaseType based on RecordType stored in metadata
     * @param newList  Case list to set CaseType
     */
    private static void setCaseTypeHandler(List<Case> newList) {
        for(Case record: newList) {
             if(record.RecordTypeId == NULL) {
                return;
            }
            String rtDevName = CASE_RT_MAP_BY_RT_ID.get(record.RecordTypeId).getDeveloperName();
            if(typeByCaseRtDevName.containsKey(rtDevName)) {
                record.Type = typeByCaseRtDevName.get(rtDevName);
            }
        }
    }

    /**
     * When case RecordType is changed, reset case type value
     * @param newList   New Case records on update event
     * @param oldMap    Old CaseMap records on update event
     */
    private static void changedRecordTypeHandler(List<Case> newList, Map<Id, Case> oldMap) {
        List<Case> changedRtCaseList = new List<Case>();
        for(Case record: newList) {
            if(record.RecordTypeId != oldMap.get(record.Id).RecordTypeId) {
                record.Type = NULL;
                changedRtCaseList.add(record);
            }
        }
        if(changedRtCaseList.size() == 0) {
            return;
        }
        setCaseTypeHandler(changedRtCaseList);
    }
}