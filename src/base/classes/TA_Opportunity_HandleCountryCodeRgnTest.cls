/**
 * @description       : Test class for TA_Opportunity_HandleCountryCodeRegion
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 12-09-2022
 * @last modified by  : Lavanya Tangati
**/
@isTest
private class TA_Opportunity_HandleCountryCodeRgnTest {
    @isTest
    static void testCountryCodesAndRegionOnInsert() {
        List<Account> accounts = TestDataHelper.getAccounts(3, false);
        accounts[0].Countries_of_Incorporation__c = 'France;Germany;United States;Japan;China';
        accounts[1].Countries_of_Incorporation__c = 'France;Germany;United States;Japan;China';
        accounts[2].Countries_of_Incorporation__c = 'France;Germany;United States;Japan;China';
        insert accounts;

        Opportunity opp1 = TestDataHelper.getOpportunities(accounts[0].Id, 1, false)[0];
        Opportunity opp2 = TestDataHelper.getOpportunities(accounts[1].Id, 1, false)[0];
        Opportunity opp3 = TestDataHelper.getOpportunities(accounts[2].Id, 1, false)[0];

        List<Opportunity> opps = new List<Opportunity>{ opp1, opp2, opp3 };

        Test.startTest();
        insert opps;
        Test.stopTest();

        Set<Id> oppIds = new Map<Id, Opportunity>(opps).keySet();
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>(
            [SELECT Id, Country_Codes__c, Region__c FROM Opportunity WHERE Id IN :oppIds]
        );

        Opportunity opp = new Opportunity();
        opp = oppsMap.get(opps[1].Id);
        System.assert(
            opp.Country_Codes__c.contains('JP'),
            'Country code should include correct value'
        );
        System.assert(
            opp.Country_Codes__c.contains('CN'),
            'Country code should include correct value'
        );

        opp = oppsMap.get(opps[2].Id);
        System.assert(
            opp.Country_Codes__c.contains('US'),
            'Country code should include correct value'
        );
        System.assert(
            opp.Country_Codes__c.contains('JP'),
            'Country code should include correct value'
        );
        System.assert(
            opp.Country_Codes__c.contains('DE'),
            'Country code should include correct value'
        );
        System.assertEquals('Global', opp.Region__c);
    }

    @isTest
    static void testCountryCodesAndRegionOnUpdate() {
        List<Account> accounts = TestDataHelper.getAccounts(1, true);
        Account accountRecord = accounts[0];

        List<Opportunity> opps = TestDataHelper.getOpportunities(accountRecord.Id, 1, false);
        Opportunity oppRecord = opps[0];
        oppRecord.Countries_of_Incorporation__c = null;

        insert oppRecord;

        Test.startTest();
        oppRecord.Countries_of_Incorporation__c = 'France';
        Database.update(oppRecord, false);
        Test.stopTest();

        Opportunity updatedOpportunity = [
            SELECT Countries_of_Incorporation__c
            FROM Opportunity
            WHERE Id = :oppRecord.Id
        ];
        system.assert(
            updatedOpportunity.Countries_of_Incorporation__c == null,
            'Validation of Countries of Incorporation on Opportunities failed'
        );
    }
}