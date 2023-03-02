@isTest
public with sharing class AssetCBDIntegrationTest {
    private static final String EST_Timezone = 'EST - Eastern Standard Time - GMT-5:00';

    private static final Id CLOUD_ACCOUNT_RECORDTYPE_ID = SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Cloud_Account')
        .getRecordTypeId();

    @TestSetup
    public static void createTestData() {
        List<Account> accountsToCreate = new List<Account>();
        for (Integer i = 1; i <= 1; i++) {
            Account accountRecord = buildAccount('Asset testing Account ' + String.valueOf(i));
            accountsToCreate.add(accountRecord);
        }
        insert accountsToCreate;
    }

    @isTest
    public static void createAssetsOnAccount() {
        List<Asset> assetsToCreate = new List<Asset>();
        Account accountToLink = [SELECT Id FROM Account LIMIT 1];
        Integer numberOfAssetsToCreate = 2;

        for (Integer i = 1; i <= numberOfAssetsToCreate; i++) {
            assetsToCreate.add(buildAsset('Churned', 'Bitcoin', 0, accountToLink.Id, i));
        }

        Test.startTest();
        insert assetsToCreate;
        Test.stopTest();

        Account updatedAccount = [
            SELECT Number_Of_Assets__c
            FROM Account
            WHERE Id = :accountToLink.Id
        ];
        system.assertEquals(
            numberOfAssetsToCreate,
            updatedAccount.Number_Of_Assets__c,
            'Number of assets not updated on Account'
        );
    }

    @isTest
    public static void testAccountStatusUpdate() {
        List<Asset> assetsToCreate = new List<Asset>();
        Account accountToLink = [SELECT Id FROM Account LIMIT 1];
        Integer numberOfAssetsToCreate = 1;

        for (Integer i = 1; i <= numberOfAssetsToCreate; i++) {
            assetsToCreate.add(buildAsset('Churned', 'Bitcoin', 0, accountToLink.Id, i));
        }

        Test.startTest();
        insert assetsToCreate;
        Test.stopTest();

        Account updatedAccount = [
            SELECT CS_Account_Status__c, Number_Of_Assets__c
            FROM Account
            WHERE Id = :accountToLink.Id
        ];
        system.assertEquals(
            'Churned',
            updatedAccount.CS_Account_Status__c,
            'Account status not set correctly'
        );
    }

    private static Asset buildAsset(
        String status,
        String protocol,
        Decimal quantity,
        Id accountId,
        Integer counter
    ) {
        Asset assetRecord = new Asset();
        assetRecord.Name = 'Asset record for ' + String.valueOf(counter) + protocol;
        assetRecord.AccountId = accountId;
        assetRecord.Quantity = quantity;
        assetRecord.Status = status;
        assetRecord.Protocol__c = protocol;
        assetRecord.Product_Type__c = 'Delegation';
        return assetRecord;
    }

    private static Account buildAccount(String accountName) {
        Account accountRecord = new Account(Name = accountName);
        accountRecord.Customer_Tier__c = '3';
        accountRecord.RecordTypeId = CLOUD_ACCOUNT_RECORDTYPE_ID;
        accountRecord.Ideal_Timezone__c = EST_Timezone;
        return accountRecord;
    }
}