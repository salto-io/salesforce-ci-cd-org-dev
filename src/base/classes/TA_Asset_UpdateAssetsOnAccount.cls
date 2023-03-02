/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
public without sharing class TA_Asset_UpdateAssetsOnAccount implements TriggerAction.AfterDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    public void AfterDelete(List<Asset> oldList) {
        updateAssetNumberOnAccount(null, oldList);
    }

    public void AfterInsert(List<Asset> newList) {
        updateAssetNumberOnAccount(newList, null);
    }

    public void AfterUpdate(List<Asset> newList, List<Asset> oldList) {
        updateAssetNumberOnAccount(newList, oldList);
    }

    @TestVisible
    private List<Account> updateAssetNumberOnAccount(List<Asset> newAssets, List<Asset> oldAssets) {
        List<Account> accountList = buildAccountsForUpdate(newAssets, oldAssets);
        if (accountList != null && accountList.size() > 0) {
            update accountList;
        }
        return accountList;
    }

    @TestVisible
    private List<Account> buildAccountsForUpdate(List<Asset> newAssets, List<Asset> oldAssets) {
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        accountIds.addAll(getAccountIds(newAssets));
        accountIds.addAll(getAccountIds(oldAssets));

        if (!accountIds.isEmpty()) {
            Set<String> assetFields = new Set<String>{ 'Id', 'Name' };
            List<Account> accountList = AccountsSelectorCBD.newInstance()
                .selectByIdWithAssets(accountIds, assetFields);
            for (Account accountRow : accountList) {
                if (accountRow.Number_of_Assets__c != accountRow.Assets?.size()) {
                    accountRow.Number_of_Assets__c = accountRow.Assets?.size();
                    accountsToUpdate.add(accountRow);
                }
            }
        }
        return accountsToUpdate;
    }

    private Set<Id> getAccountIds(List<Asset> assetList) {
        if (assetList == null || assetList?.size() == 0) {
            return new Set<Id>();
        }
        Set<Id> accountIds = new Set<Id>();
        for (Asset assetRow : assetList) {
            if (assetRow.AccountId != null) {
                accountIds.add(assetRow.AccountId);
            }
        }
        return accountIds;
    }
}