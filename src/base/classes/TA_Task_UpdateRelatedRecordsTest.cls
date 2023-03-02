/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
@isTest
private class TA_Task_UpdateRelatedRecordsTest {
    
    private static final Id CLOUD_PIPELINE_RECORDTYPE_ID = SObjectType.Opportunity
                                                                            .getRecordTypeInfosByDeveloperName()
                                                                            .get('Cloud_Pipeline')
                                                                            .getRecordTypeId();

    private static final Id WALLET_OPPORTUNITY_RECORDTYPE_ID = SObjectType.Opportunity
                                                                            .getRecordTypeInfosByDeveloperName()
                                                                            .get('Wallet_Opportunity')
                                                                            .getRecordTypeId();
    @isTest
    static void sendSurveyCheckedWalletOpps() {
        List<Account> accs = TestDataHelper.getAccounts(1, true);

        List<Opportunity> opps =  TestDataHelper.getOpportunities(accs[0].Id, 1, false);
        opps[0].RecordTypeId = WALLET_OPPORTUNITY_RECORDTYPE_ID;
        insert opps[0];

        Task t = TestDataHelper.getTask(opps[0].Id, true);
        Test.startTest();
            t.Status = 'Completed';
            t.Subject = 'Send Survey';
            update t;
        Test.stopTest();

        Opportunity o = [SELECT Survey_Sent__c  FROM Opportunity WHERE Id =: opps[0].Id];
        System.assert(o.Survey_Sent__c);
    }
	
    @isTest
    static void sendSurveyCheckedCoinbasePayOpps() {
        List<Account> accs = TestDataHelper.getAccounts(1, true);

        List<Opportunity> opps =  TestDataHelper.getOpportunities(accs[0].Id, 1, false);
        opps[0].RecordTypeId = CLOUD_PIPELINE_RECORDTYPE_ID;
        insert opps[0];

        Task t = TestDataHelper.getTask(opps[0].Id, true);
        Test.startTest();
            t.Status = 'Completed';
            t.Subject = 'Send Survey';
            update t;
        Test.stopTest();

        Opportunity o = [SELECT Survey_Sent__c  FROM Opportunity WHERE Id =: opps[0].Id];
        System.assert(o.Survey_Sent__c);
    }

    @isTest
    static void ScheduleDebriefCallChecked() {
        List<Account> accs = TestDataHelper.getAccounts(1, true);

        List<Opportunity> opps =  TestDataHelper.getOpportunities(accs[0].Id, 1, false);
        opps[0].RecordTypeId = WALLET_OPPORTUNITY_RECORDTYPE_ID;
        insert opps[0];

        Task t = TestDataHelper.getTask(opps[0].Id, false);
        t.Subject = 'Open';
        t.Subject = 'Schedule a debrief call';
        insert t;

        Test.startTest();
            t.Status = 'Completed';
            update t;
        Test.stopTest();

        Opportunity o = [SELECT Debrief_Call_Scheduled__c  FROM Opportunity WHERE Id =: opps[0].Id];
        System.assert(o.Debrief_Call_Scheduled__c);
    }

    @isTest
    static void validateNothingChecked() {
        List<Account> accs = TestDataHelper.getAccounts(1, true);

        List<Opportunity> opps =  TestDataHelper.getOpportunities(accs[0].Id, 1, false);
        opps[0].RecordTypeId = WALLET_OPPORTUNITY_RECORDTYPE_ID;
        insert opps[0];

        Task t = TestDataHelper.getTask(opps[0].Id, false);
        t.Subject = 'Open';

        Test.startTest();
            insert t;
        Test.stopTest();

        Opportunity o = [SELECT Survey_Sent__c, Debrief_Call_Scheduled__c  FROM Opportunity WHERE Id =: opps[0].Id];
        System.assert(!o.Debrief_Call_Scheduled__c);
        System.assert(!o.Survey_Sent__c);
    }
}
