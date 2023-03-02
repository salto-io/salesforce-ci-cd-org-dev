/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
@isTest
public with sharing class TA_Asset_UpdateAssetsOnAccountTest {
    @isTest
    public static void testAssetWithAccount() {
        Id csOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Account mockAccount = buildMockAccount('New Automate CSA Test', csOwnerId, 0);
        Asset mockAsset = buildMockAsset('Asset Active', 'Active', 15, mockAccount.Id);

        Account accountWithRelation = linkAssetsToAccount(
            mockAccount,
            new List<Asset>{ mockAsset }
        );
        Set<Id> accIds = new Set<Id>{ accountWithRelation.Id };
        setAccountMockSelector(accIds, new List<Account>{ accountWithRelation });
        Test.startTest();
        TA_Asset_UpdateAssetsOnAccount triggerObject = new TA_Asset_UpdateAssetsOnAccount();
        List<Account> newAccounts = triggerObject.buildAccountsForUpdate(
            new List<Asset>{ mockAsset },
            null
        );
        Test.stopTest();
        system.assertEquals(
            1,
            newAccounts[0].Number_Of_Assets__c,
            'Number of Assets on Account not set as expected'
        );
    }

    @isTest
    public static void testAssetUpdate() {
        Id csOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Account mockAccount = buildMockAccount('New Automate CSA Test', csOwnerId, 1);
        Asset mockAsset = buildMockAsset('Asset Active', 'Active', 15, mockAccount.Id);
        Asset updatedAsset = mockAsset.clone(true);

        Account accountWithRelation = linkAssetsToAccount(
            mockAccount,
            new List<Asset>{ mockAsset }
        );
        Set<Id> accIds = new Set<Id>{ accountWithRelation.Id };
        setAccountMockSelector(accIds, new List<Account>{ accountWithRelation });
        Test.startTest();
        TA_Asset_UpdateAssetsOnAccount triggerObject = new TA_Asset_UpdateAssetsOnAccount();
        List<Account> newAccounts = triggerObject.updateAssetNumberOnAccount(
            new List<Asset>{ mockAsset },
            new List<Asset>{ updatedAsset }
        );
        Test.stopTest();
        system.assertEquals(
            0,
            newAccounts.size(),
            'Non-relevant Asset update triggered an Account update'
        );
    }
    private static Account buildMockAccount(
        String accountName,
        Id csOwnerId,
        Decimal numberOfAssets
    ) {
        Account mockAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = accountName,
            Customer_Tier__c = '3',
            Number_Of_Assets__c = numberOfAssets
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
        Set<String> assetFieldsToQuery = new Set<String>{ 'Id', 'Name' };
        mocks.when(mockSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockSelector.selectByIdWithAssets(idsToQuery, assetFieldsToQuery))
            .thenReturn(listToReturn);
        mocks.stopStubbing();

        //Inject Mock
        Application.Selector.setMock(mockSelector);
    }
}