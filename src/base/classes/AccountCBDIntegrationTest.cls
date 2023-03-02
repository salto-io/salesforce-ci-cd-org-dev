@isTest
public with sharing class AccountCBDIntegrationTest {
    private static final String EST_Timezone = 'EST - Eastern Standard Time - GMT-5:00';

    private static final Id BD_ACCOUNT_RECORDTYPE_ID = SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Business_Development_Partnerships')
        .getRecordTypeId();

    private static final Id CLOUD_ACCOUNT_RECORDTYPE_ID = SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Cloud_Account')
        .getRecordTypeId();

    @isTest
    public static void testCountryCodes() {
        Account accountRecord = buildAccount('New Account Integration', '3');
        accountRecord.Countries_of_Incorporation__c = 'Japan;Germany';
        accountRecord.RecordTypeId = CLOUD_ACCOUNT_RECORDTYPE_ID;
        accountRecord.Ideal_Timezone__c = EST_Timezone;

        Test.startTest();
        insert accountRecord;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Country_Codes__c, Region__c
            FROM Account
            WHERE Id = :accountRecord.Id
        ];
        system.assert(
            updatedAccount.Country_Codes__c.contains('DE'),
            'Country Code not set as expected'
        );

        system.assert(
            updatedAccount.Country_Codes__c.contains('JP'),
            'Country Code not set as expected'
        );
        system.assertEquals('Global', updatedAccount.Region__c, 'Region not set as expected');
    }

    @isTest
    public static void testTaskCreation() {
        Account accountRecord = buildAccount('New Account Integration Tasking', '3');
        accountRecord.RecordTypeId = BD_ACCOUNT_RECORDTYPE_ID;
        accountRecord.Ideal_Timezone__c = EST_Timezone;
        accountRecord.Coinbase_Wallet_Connection_Date__c = Date.today().addDays(3);
        insert accountRecord;

        List<Task> taskList = [SELECT Status, Priority FROM Task WHERE WhatId = :accountRecord.Id];
        system.assertEquals(1, taskList.size(), 'Incorrect number of tasks created');
        system.assertEquals(taskList[0].Status, 'Open', 'Task created in incorrect status');
        system.assertEquals(taskList[0].Priority, 'Normal', 'Task priority is incorrect');
    }

    private static Account buildAccount(String accountName, String customerTier) {
        Account accountRecord = new Account(Name = accountName, Customer_Tier__c = customerTier);
        return accountRecord;
    }
}