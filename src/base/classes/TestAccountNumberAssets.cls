@isTest
private class TestAccountNumberAssets {
    @isTest static void TestAcctNotNull() {
        Test.startTest();
        Account acct = new Account(Name='Test Account', Size__c='Small Cap (< $150M)', Ideal_Timezone__c='GMT - Greenwich Mean Time - GMT', Industry='Analytics');
        insert acct;
        System.assertNotEquals(null, acct);
        Test.stopTest();
    }
    @isTest static void TestAcctAssetAssoc() {
        Test.startTest();
        Account acct = new Account(Name='Test Account', Size__c='Small Cap (< $150M)', Ideal_Timezone__c='GMT - Greenwich Mean Time - GMT', Industry='Analytics');
        insert acct;
        Asset asset = new Asset(AccountId = acct.Id,
                               Name = 'Asset',
                               Protocol__c = 'Algorand',
                               Product_Type__c = 'Delegation');
        insert asset;
        System.assertEquals(acct.Id, asset.AccountId);
        Test.stopTest();
    }
}