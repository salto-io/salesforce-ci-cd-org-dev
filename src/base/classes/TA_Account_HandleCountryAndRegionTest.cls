/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
//Note: This test class takes advantage of the fact that Lists and SObjects are passed by reference,
//so changes to these objects within a trigger class can be read and detected outside the trigger classes in this
//test class
@isTest
private class TA_Account_HandleCountryAndRegionTest {
    @isTest
    public static void testAccountNoCountries() {
        Account mockAccount = buildMockAccount('Incorp Testing', '');
        List<Account> accountList = new List<Account>{ mockAccount };

        TA_Account_HandleCountryCodeAndRegion triggerObject = new TA_Account_HandleCountryCodeAndRegion();
        triggerObject.BeforeInsert(accountList);

        Account modifiedAccount = accountList[0];
        system.assertEquals(null, modifiedAccount.Region__c, 'Region should be null');
    }

    @isTest
    public static void testAccountWithOneRegion() {
        Account mockAccount = buildMockAccount('Incorp Testing', 'Japan;China');
        List<Account> accountList = new List<Account>{ mockAccount };

        TA_Account_HandleCountryCodeAndRegion triggerObject = new TA_Account_HandleCountryCodeAndRegion();
        triggerObject.BeforeInsert(accountList);

        Account modifiedAccount = accountList[0];
        system.assertEquals('APAC', modifiedAccount.Region__c, 'Region not set as expected');
        system.assert(
            modifiedAccount.Country_Codes__c.contains('JP'),
            'Country Code not set as expected'
        );
        system.assert(
            modifiedAccount.Country_Codes__c.contains('CN'),
            'Country Code not set as expected'
        );
    }

    @isTest
    public static void testAccountWithTwoRegions() {
        Account mockAccount = buildMockAccount('Incorp Testing', 'Japan;Germany');
        List<Account> accountList = new List<Account>{ mockAccount };

        TA_Account_HandleCountryCodeAndRegion triggerObject = new TA_Account_HandleCountryCodeAndRegion();
        triggerObject.BeforeInsert(accountList);

        Account modifiedAccount = accountList[0];
        system.assertEquals('Global', modifiedAccount.Region__c, 'Region not set as expected');
        system.assert(
            modifiedAccount.Country_Codes__c.contains('JP'),
            'Country Code not set as expected'
        );
        system.assert(
            modifiedAccount.Country_Codes__c.contains('DE'),
            'Country Code not set as expected'
        );
    }

    @isTest
    public static void testAccountWithOneRegionOnUpdate() {
        Account mockAccountOld = buildMockAccount('Incorp Testing', 'Japan;China');
        List<Account> accountListOld = new List<Account>{ mockAccountOld };

        Account mockAccountNew = mockAccountOld.clone(true);
        mockAccountNew.Countries_of_Incorporation__c = 'Japan;China;Canada';
        List<Account> accountListNew = new List<Account>{ mockAccountNew };

        TA_Account_HandleCountryCodeAndRegion triggerObject = new TA_Account_HandleCountryCodeAndRegion();
        triggerObject.BeforeUpdate(accountListNew, accountListOld);

        Account modifiedAccount = accountListNew[0];
        system.assertEquals('Global', modifiedAccount.Region__c, 'Region not set as expected');
        system.assert(
            modifiedAccount.Country_Codes__c.contains('JP'),
            'Country Code not set as expected'
        );
        system.assert(
            modifiedAccount.Country_Codes__c.contains('CN'),
            'Country Code not set as expected'
        );
    }

    @isTest
    public static void testTwoAccounts() {
        Account mockAccountApac = buildMockAccount('Incorp Testing', 'Japan;China');
        Account mockAccountGlobal = buildMockAccount('Incorp Testing', 'Japan;Canada;Ireland');
        List<Account> accountList = new List<Account>{ mockAccountApac, mockAccountGlobal };

        TA_Account_HandleCountryCodeAndRegion triggerObject = new TA_Account_HandleCountryCodeAndRegion();
        triggerObject.BeforeInsert(accountList);

        Account modifiedAccountApac = accountList[0];
        system.assertEquals('APAC', modifiedAccountApac.Region__c, 'Region not set as expected');
        system.assert(
            modifiedAccountApac.Country_Codes__c.contains('JP'),
            'Country Code not set as expected'
        );
        system.assert(
            modifiedAccountApac.Country_Codes__c.contains('CN'),
            'Country Code not set as expected'
        );

        Account modifiedAccountGlobal = accountList[1];
        system.assertEquals(
            'Global',
            modifiedAccountGlobal.Region__c,
            'Region not set as expected'
        );
        system.assert(
            modifiedAccountGlobal.Country_Codes__c.contains('JP'),
            'Country Code not set as expected'
        );
        system.assert(
            modifiedAccountGlobal.Country_Codes__c.contains('IE'),
            'Country Code not set as expected'
        );
        system.assert(
            modifiedAccountGlobal.Country_Codes__c.contains('CA'),
            'Country Code not set as expected'
        );
    }

    private static Account buildMockAccount(String accountName, String countryString) {
        Account mockAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = accountName,
            Customer_Tier__c = '3',
            Countries_of_Incorporation__c = countryString
        );

        return mockAccount;
    }
}