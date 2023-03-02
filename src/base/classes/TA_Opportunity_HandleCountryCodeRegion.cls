/**
 * @description       : Handle CountryCode And Region updates
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 12-09-2022
 * @last modified by  : Lavanya Tangati
**/
public without sharing class TA_Opportunity_HandleCountryCodeRegion implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    
    private static Set<Id> accountIds = new Set<Id>();
    List<Opportunity> qualifiedOpps =  new List<Opportunity>();

    public void BeforeInsert(List<Opportunity> newList) {
        //qualify
        for (Opportunity opp : newList) {
            accountIds.add(opp.AccountId);
        }

        if(!accountIds.isEmpty()){
            updateFieldsFromAccount(newList);
        }

        //first fields on Opp needs to be set from Account from the above method, then only we can set Country Codes and Region
        for (Opportunity opp : newList) {
            if (String.isNotEmpty(opp.Countries_of_Incorporation__c)) {
                CountryCodeCalculator.setCountryCodesAndRegion(opp);
            }
        }

    }

    public void BeforeUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        Map<Id, Opportunity>  oldMap = new Map<Id, Opportunity>(oldList);
        
        //qualify
        for (Opportunity opp : newList) {
            Opportunity oldOpp = oldMap.get(opp.Id);
            accountIds.add(opp.AccountId);
            if(opp.Countries_of_Incorporation__c != oldOpp.Countries_of_Incorporation__c){
                qualifiedOpps.add(opp);
            }
        }

        //Set CountryCode and Region
        for (Opportunity opp : qualifiedOpps) {
            Account accountRecord = accountMap?.get(opp.AccountId);
            if (String.isEmpty(opp.Countries_of_Incorporation__c)) {
                opp.Country_Codes__c = null;
                opp.Region__c = null;
            } 
            else {
                validateOppCountryIncorporation(opp, accountRecord);
                CountryCodeCalculator.setCountryCodesAndRegion(opp);
            }
        }
    }

    private static void validateOppCountryIncorporation(Opportunity oppRecord, Account accountRecord) {
        Set<String> oppCountries = OrgUtil.createSetFromPicklistField( oppRecord?.Countries_of_Incorporation__c);
        Set<String> accountCountries = OrgUtil.createSetFromPicklistField( accountRecord?.Countries_of_Incorporation__c);
        for (String oppCountry : oppCountries) {
            if (!accountCountries.contains(oppCountry)) {
                oppRecord.addError(
					'Cannot add ' + oppCountry + ' as a Country of Incorporation. ' + 
					'You must first add ' + oppCountry + ' to the Countries of Incorporation of this Opportunity\'s Account record '
                );
            }
        }
    }

    public static void updateFieldsFromAccount(List<Opportunity> newList) {
        for (Opportunity opp : newList) {
            Account account = accountMap.get(opp.AccountId);
            opp.Countries_of_Incorporation__c = account.Countries_of_Incorporation__c;
            opp.Customer_Segment__c = account.Customer_Segment__c;
            opp.Customer_Subsegment__c = account.Customer_Subsegment__c;
        }
    }

    private static Map<Id,Account> accountMap{
        get{
            if(accountMap == null){
                accountMap =  new Map<Id, Account>( [
                    SELECT Id, Countries_of_Incorporation__c, Customer_Segment__c, Customer_Subsegment__c
                    FROM Account
                    WHERE Id IN :accountIds
                ]);
            }
            return accountMap;
        }
        private set;
    }

}