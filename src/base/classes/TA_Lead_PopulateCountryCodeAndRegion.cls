public without sharing class TA_Lead_PopulateCountryCodeAndRegion implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
	public void beforeInsert(List<Lead> newList) {
        handleCountryCodesAndRegion(newList);
    }
    
    public void beforeUpdate(List<Lead> newList, List<Lead> oldList) {
        Map<Id, Lead> oldMap = new Map<Id, Lead>(oldList);
        handleCountryCodesAndRegion(newList, oldMap);
    }
    
    public static void handleCountryCodesAndRegion(List<Lead> newLeads) {
        for (Lead lead : newLeads) {
            if(String.isNotEmpty(lead.Location__c)){
                updateLead(lead);
            }
            if (String.isNotEmpty(lead.Countries_of_Incorporation__c)) {
                CountryCodeCalculator.setCountryCodesAndRegion(lead);
            }
        }
    }
    
    public static void handleCountryCodesAndRegion(List<Lead> newLeads, Map<Id, Lead> oldLeads) {
        for (Lead lead : newLeads) {
            if(String.isNotEmpty(lead.Location__c)){
                updateLead(lead);
            }
            if (String.isEmpty(lead.Countries_of_Incorporation__c)) {
                lead.Country_Codes__c = null;
                lead.Region__c = null;
            } else {
                Lead oldLead = oldLeads.get(lead.Id);

                if (lead.Countries_of_Incorporation__c != oldLead.Countries_of_Incorporation__c) {
                    CountryCodeCalculator.setCountryCodesAndRegion(lead);
                }
            }
        }
    }
    
    public static void updateLead (Lead l) {
        l.Countries_of_Incorporation__c = l.Location__c;
        l.Country_Attributes__c = 'Incorporation';
    }
}