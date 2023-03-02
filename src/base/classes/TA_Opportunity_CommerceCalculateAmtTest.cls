@isTest
private class TA_Opportunity_CommerceCalculateAmtTest {
    @isTest
    private static void calculateOmmerceOpprtunityAmount_Insert_fflib() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TA_Opportunity_CommerceCalculateAmount action = new TA_Opportunity_CommerceCalculateAmount();

        Id commerceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
            .get('Commerce')
            .getRecordTypeId();

        Account acc = new Account(
            Id = TestUtility.getFakeId(Account.SObjectType),
            Name = 'Best Account ONE'
        );
        system.debug(acc.Id);
        Opportunity opp = new Opportunity(
            Id = TestUtility.getFakeId(Opportunity.SObjectType),
            Name = 'Best Opportunity ONE',
            AccountId = acc.Id,
            RecordTypeId = commerceRecordTypeId,
            StageName = 'Discovery/Scoping',
            CloseDate = system.today().adddays(10),
            Average_Transaction_Amount__c = 600,
            Number_of_Transactions_per_Month__c = 500
        );

        action.BeforeInsert(new List<Opportunity>{ opp });
        system.assertEquals(36000, opp.Amount);
    }

    @isTest
    private static void calculateOmmerceOpprtunityAmount_Update_fflib() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TA_Opportunity_CommerceCalculateAmount action = new TA_Opportunity_CommerceCalculateAmount();

        Id commerceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
            .get('Commerce')
            .getRecordTypeId();

        Account acc = new Account(
            Id = TestUtility.getFakeId(Account.SObjectType),
            Name = 'Best Account ONE'
        );
        system.debug(acc.Id);
        Id oppId = TestUtility.getFakeId(Opportunity.SObjectType);
        Opportunity opp1 = new Opportunity(
            Id = oppId,
            Name = 'Best Opportunity ONE',
            AccountId = acc.Id,
            RecordTypeId = commerceRecordTypeId,
            StageName = 'Discovery/Scoping',
            CloseDate = system.today().adddays(10),
            Average_Transaction_Amount__c = 600,
            Number_of_Transactions_per_Month__c = 500
        );

        Opportunity opp2 = new Opportunity(
            Id = oppId,
            Name = 'Best Opportunity ONE',
            AccountId = acc.Id,
            RecordTypeId = commerceRecordTypeId,
            StageName = 'Discovery/Scoping',
            CloseDate = system.today().adddays(10),
            Average_Transaction_Amount__c = 601,
            Number_of_Transactions_per_Month__c = 501
        );

        action.BeforeUpdate(new List<Opportunity>{ opp2 }, new List<Opportunity>{ opp1 });
        system.assertEquals(36132, opp2.Amount);
    }
}