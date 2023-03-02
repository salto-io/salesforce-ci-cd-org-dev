@isTest
private class TA_Lead_PopulateCountryCodeAndRegionTest {
    @isTest
    static void testCountryCodesAndRegionOnInsert() {
        List<Lead> leads = TestDataHelper.getStandardLeads(3, false);
        leads[0].Countries_of_Incorporation__c = null;
        leads[1].Countries_of_Incorporation__c = 'Japan;China';
        leads[2].Location__c = 'United States;Japan;Germany';

        Test.startTest();
        insert leads;
        Test.stopTest();

        Set<Id> leadIds = new Map<Id, Lead>(leads).keySet();
        Map<Id, Lead> leadsMap = new Map<Id, Lead>(
            [SELECT Id, Country_Codes__c, Region__c FROM Lead WHERE Id IN :leadIds]
        );

        Lead lead = leadsMap.get(leads[0].Id);
        System.assertEquals(null, lead.Country_Codes__c);
        System.assertEquals(null, lead.Region__c);

        lead = leadsMap.get(leads[1].Id);
        System.assert(lead.Country_Codes__c.contains('JP'), 'Country code should include correct value');
        System.assert(lead.Country_Codes__c.contains('CN'), 'Country code should include correct value');
        System.assertEquals('APAC', lead.Region__c);

        lead = leadsMap.get(leads[2].Id);
        System.assert(lead.Country_Codes__c.contains('US'), 'Country code should include correct value');
        System.assert(lead.Country_Codes__c.contains('JP'), 'Country code should include correct value');
        System.assert(lead.Country_Codes__c.contains('DE'), 'Country code should include correct value');
        System.assertEquals('Global', lead.Region__c);
    }
    
    @isTest
    static void testCountryCodesAndRegionOnUpdate() {
        List<Lead> leads = TestDataHelper.getStandardLeads(3, false);
        leads[0].Countries_of_Incorporation__c = null;
        leads[1].Countries_of_Incorporation__c = 'Japan;China';
        leads[2].Location__c = 'United States;Japan;Germany';
        
        insert leads;

        Test.startTest();
        List<Lead> leadUpdate = new List<Lead>();
        leadUpdate.add(new Lead(Id = leads[0].Id, Countries_of_Incorporation__c = 'France;Germany'));
        leadUpdate.add(new Lead(Id = leads[1].Id, Countries_of_Incorporation__c = null));
        leadUpdate.add(new Lead(Id = leads[2].Id, Location__c = 'United States;France'));

        update leadUpdate;
        Test.stopTest();

        Set<Id> leadIds = new Map<Id, Lead>(leads).keySet();
        Map<Id, Lead> leadsMap = new Map<Id, Lead>(
            [SELECT Id, Country_Codes__c, Region__c FROM Lead WHERE Id IN :leadIds]
        );

        Lead lead = leadsMap.get(leads[0].Id);
        System.assert(lead.Country_Codes__c.contains('FR'), 'Country code should include correct value');
        System.assert(lead.Country_Codes__c.contains('DE'), 'Country code should include correct value');
        System.assertEquals('EMEA', lead.Region__c);

        lead = leadsMap.get(leads[1].Id);
        System.assertEquals(null, lead.Country_Codes__c);
        System.assertEquals(null, lead.Region__c);

        lead = leadsMap.get(leads[2].Id);
        System.assert(lead.Country_Codes__c.contains('US'), 'Country code should include correct value');
        System.assert(lead.Country_Codes__c.contains('FR'), 'Country code should include correct value');
        System.assertEquals('Global', lead.Region__c);
    }
}