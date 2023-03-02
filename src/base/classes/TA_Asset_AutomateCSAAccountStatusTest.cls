//@isTest
public class TA_Asset_AutomateCSAAccountStatusTest {
/*
    private static List<Asset> mockAssets = new List<Asset>();
    private static List<Account> mockAccounts = new List<Account>();

    @isTest
    public static void testActiveStatus() {
        Id csOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Account mockAccount = buildMockAccount('New Automate CSA Test', csOwnerId);
        Asset mockAssetActive = buildMockAsset('Asset Active', 'Active', 15, mockAccount.Id);

        Account accountWithRelation = linkAssetsToAccount(
            mockAccount,
            new List<Asset>{ mockAssetActive }
        );
        Set<Id> accIds = new Set<Id>{ accountWithRelation.Id };

        setAccountMockSelector(accIds, new List<Account>{ accountWithRelation });
        Test.startTest();
        TA_Asset_AutomateCSAccountStatus triggerObject = new TA_Asset_AutomateCSAccountStatus();
        List<Account> newAccounts = triggerObject.getAccountsForUpdate(
            new List<Asset>{ mockAssetActive },
            null,
            false
        );
        Test.stopTest();

        system.assert(
            newAccounts[0].CS_Account_Status__c == 'Active',
            'CS Account Status was expected to be set to active'
        );
    }

    @isTest
    public static void testOnboardingStatus() {
        Id csOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Account mockAccount = buildMockAccount('New Automate CSA Test', csOwnerId);
        Asset mockInactiveAsset = buildMockAsset(
            'Asset Active',
            'Temporarily Inactive',
            15,
            mockAccount.Id
        );

        Account accountWithRelation = linkAssetsToAccount(
            mockAccount,
            new List<Asset>{ mockInactiveAsset }
        );
        Set<Id> accIds = new Set<Id>{ accountWithRelation.Id };

        setAccountMockSelector(accIds, new List<Account>{ accountWithRelation });
        Test.startTest();
        TA_Asset_AutomateCSAccountStatus triggerObject = new TA_Asset_AutomateCSAccountStatus();
        List<Account> newAccounts = triggerObject.getAccountsForUpdate(
            new List<Asset>{ mockInactiveAsset },
            null,
            false
        );
        Test.stopTest();

        system.assertEquals(
            'Inactive',
            newAccounts[0].CS_Account_Status__c,
            'CS Account Status was expected to be set to Inactive'
        );
    }
    @isTest
    public static void testChurnedStatus() {
        Account mockAccount = buildMockAccount('New Automate CSA Test', null);
        Asset mockAssetChurned = buildMockAsset('Asset Active', 'Churned', 0, mockAccount.Id);

        Account accountWithRelation = linkAssetsToAccount(
            mockAccount,
            new List<Asset>{ mockAssetChurned }
        );
        Set<Id> accIds = new Set<Id>{ accountWithRelation.Id };

        setAccountMockSelector(accIds, new List<Account>{ accountWithRelation });
        Test.startTest();
        TA_Asset_AutomateCSAccountStatus triggerObject = new TA_Asset_AutomateCSAccountStatus();
        List<Account> newAccounts = triggerObject.getAccountsForUpdate(
            new List<Asset>{ mockAssetChurned },
            null,
            false
        );
        Test.stopTest();

        system.assertEquals(
            'Churned',
            newAccounts[0].CS_Account_Status__c,
            'CS Account Status was expected to be set to Churned'
        );
    }

    @isTest
    public static void testAssetWithNoAccounts() {
        Asset mockChurnedAsset = buildMockAsset('Asset Churned', 'Churned', 0, null);

        Test.startTest();
        TA_Asset_AutomateCSAccountStatus triggerObject = new TA_Asset_AutomateCSAccountStatus();
        triggerObject.AfterUpdate(
            new List<Asset>{ mockChurnedAsset },
            new List<Asset>{ mockChurnedAsset }
        );
        Test.stopTest();

        system.assertEquals(
            true,
            TA_Asset_AutomateCSAccountStatus.hasExecuted,
            'Has executed flag not set after class execution'
        );
    }
    @isTest
    public static void testChurnedToActiveStatus() {
        Id csOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Account mockAccount = buildMockAccount('New Automate CSA Test', csOwnerId);
        Asset mockChurnedAsset = buildMockAsset('Asset Churned', 'Churned', 0, mockAccount.Id);

        Asset mockActiveAsset = mockChurnedAsset.clone(true);
        mockActiveAsset.Status = 'Active';
        mockActiveAsset.Quantity = 22;

        Account accountWithRelation = linkAssetsToAccount(
            mockAccount,
            new List<Asset>{ mockActiveAsset }
        );
        Set<Id> accIds = new Set<Id>{ accountWithRelation.Id };

        setAccountMockSelector(accIds, new List<Account>{ accountWithRelation });
        Test.startTest();
        TA_Asset_AutomateCSAccountStatus triggerObject = new TA_Asset_AutomateCSAccountStatus();
        List<Account> newAccounts = triggerObject.getAccountsForUpdate(
            new List<Asset>{ mockActiveAsset },
            new List<Asset>{ mockChurnedAsset },
            false
        );
        Test.stopTest();

        system.assertEquals(
            'Active',
            newAccounts[0].CS_Account_Status__c,
            'CS Account Status not properly set to Active'
        );
    }

    @isTest
    public static void testHasExecutedFlagSet() {
        Asset mockAssetActive = buildMockAsset('Asset Active', 'Active', 15, null);
        Test.startTest();
        TA_Asset_AutomateCSAccountStatus triggerObject = new TA_Asset_AutomateCSAccountStatus();
        triggerObject.AfterInsert(new List<Asset>{ mockAssetActive });
        Test.stopTest();

        system.assertEquals(
            true,
            TA_Asset_AutomateCSAccountStatus.hasExecuted,
            'Has executed flag not set after class execution'
        );
    }
    private static Account buildMockAccount(String accountName, Id csOwnerId) {
        Account mockAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = accountName,
            Customer_Tier__c = '3'
        );

        if (csOwnerId != null) {
            mockAccount.CS_Owner__c = csOwnerId;
        }
        return mockAccount;
    }

    private static Asset buildMockAsset(
        String assetName,
        String assetStatus,
        Integer assetQuantity,
        Id accountId
    ) {
        Asset mockAsset = new Asset(
            Id = fflib_IDGenerator.generate(Asset.SObjectType),
            Name = assetName,
            Status = assetStatus,
            Quantity = assetQuantity,
            Bill__c = fflib_IDGenerator.generate(Bill__c.SObjectType)
        );

        if (accountId != null) {
            mockAsset.AccountId = accountId;
        }

        return mockAsset;
    }

    private static Account linkAssetsToAccount(Account mockAccount, List<Asset> assetList) {
        List<Account> mockedRelationList = (List<Account>) fflib_ApexMocksUtils.makeRelationship(
            List<Account>.class,
            new List<Account>{ mockAccount },
            Asset.AccountId,
            new List<List<Asset>>{ assetList }
        );

        return mockedRelationList[0];
    }

    private static void setAccountMockSelector(Set<Id> idsToQuery, List<Account> listToReturn) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        // Start stubbing
        mocks.startStubbing();
        Set<String> assetFieldsToQuery = new Set<String>{
            'Bill__c',
            'CS_Owner__c',
            'Status',
            'Quantity'
        };
        mocks.when(mockSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockSelector.selectByIdWithAssets(idsToQuery, assetFieldsToQuery))
            .thenReturn(listToReturn);
        mocks.stopStubbing();

        //Inject Mock
        Application.Selector.setMock(mockSelector);
    }
	*/
}