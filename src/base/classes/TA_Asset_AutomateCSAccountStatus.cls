/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-06-2023
 * @last modified by  : Lavanya Tangati
**/
public class TA_Asset_AutomateCSAccountStatus implements TriggerAction.AfterDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    public static Boolean hasExecuted {
        public get {
            if (hasExecuted == null)
                hasExecuted = false;
            return hasExecuted;
        }
        public set;
    }

    public void AfterDelete(List<Asset> oldList) {
        execute(null, oldList, true);
    }

    public void AfterInsert(List<Asset> newList) {
        execute(newList, null, false);
    }

    public void AfterUpdate(List<Asset> newList, List<Asset> oldList) {
        execute(newList, oldList, false);
    }

    @TestVisible
    private void execute(List<Asset> newList, List<Asset> oldList, Boolean isDelete) {
        if (!hasExecuted) {
            List<Account> accountsToUpdate = getAccountsForUpdate(newList, oldList, isDelete);
            if (accountsToUpdate != null && accountsToUpdate.size() > 0) {
                Database.update(accountsToUpdate);
            }
            hasExecuted = true;
        }
    }

    @TestVisible
    private List<Account> getAccountsForUpdate(
        List<Asset> newList,
        List<Asset> oldList,
        Boolean isDelete
    ) {
        Set<Id> qualifiedAccountIds = new Set<Id>();
        if (newList != null && oldList != null) {
            qualifiedAccountIds = getQualifiedAccountIds(newList, oldList);
        } else if (newList == null && oldList != null && isDelete) {
            qualifiedAccountIds = getQualifiedAccountIds(oldList, isDelete);
        } else if (newList != null && oldList == null) {
            qualifiedAccountIds = getQualifiedAccountIds(newList, false);
        }
        return buildAccountsForUpdate(qualifiedAccountIds);
    }

    private Set<Id> getQualifiedAccountIds(List<Asset> assetList, Boolean isDelete) {
        Set<Id> qualifiedIds = new Set<Id>();
        for (Asset assetRow : assetList) {
            if (assetRow.AccountId != null && assetRow.Status != null && !isDelete) {
                qualifiedIds.add(assetRow.AccountId);
            } else if (assetRow.AccountId != null && isDelete) {
                qualifiedIds.add(assetRow.AccountId);
            }
        }
        return qualifiedIds;
    }

    private Set<Id> getQualifiedAccountIds(List<Asset> newList, List<Asset> oldList) {
        Set<Id> qualifiedIds = new Set<Id>();
        Map<Id, Asset> oldMap = new Map<Id, Asset>(oldList);

        for (Asset newAsset : newList) {
            Asset oldAsset = oldMap.get(newAsset.Id);
            if (
                newAsset.AccountId != null &&
                newAsset.Status != null &&
                checkHasQualifiedChange(newAsset, oldAsset)
            ) {
                qualifiedIds.add(newAsset.AccountId);
            }
        }
        return qualifiedIds;
    }

    private Boolean checkHasQualifiedChange(Asset newAsset, Asset oldAsset) {
        if (
            newAsset.AccountId != oldAsset.AccountId ||
            newAsset.Bill__c != oldAsset.Bill__c ||
            newAsset.Status != oldAsset.Status ||
            newAsset.Quantity != oldAsset.Quantity
        ) {
            return true;
        } else {
            return false;
        }
    }

    private List<Account> buildAccountsForUpdate(Set<Id> accountIds) {
        List<Account> accountsToUpdate = new List<Account>();
        Set<String> assetFieldsToQuery = new Set<String>{
            'Bill__c',
            'CS_Owner__c',
            'Status',
            'Quantity'
        };
        List<Account> accountList = AccountsSelectorCBD.newInstance()
            .selectByIdWithAssets(accountIds, assetFieldsToQuery);

        for (Account accountRow : accountList) {
            List<Asset> assetList = accountRow.Assets;
            String newAccountStatus = determineNewAccountStatus(accountRow, assetList);
            if (!String.isBlank(newAccountStatus)) {
                accountRow.CS_Account_Status__c = newAccountStatus;
                accountsToUpdate.add(accountRow);
            }
        }
        return accountsToUpdate;
    }

    private String determineNewAccountStatus(Account accountRecord, List<Asset> assetList) {
        Map<String, Boolean> statusToValidityMap = new Map<String, Boolean>();
        List<String> statusOrderedByPrecadence = new List<String>{
            'Active',
            'Inactive',
            'Onboarding',
            'Churned'
        };

        for (Asset assetRow : assetList) {
            if (
                accountRecord.CS_Owner__c != null &&
                assetRow.Bill__c != null &&
                assetRow.Status == 'Active' &&
                assetRow.Quantity >= 1
            ) {
                statusToValidityMap.put('Active', true);
            } else if (
                accountRecord.CS_Owner__c != null &&
                (assetRow.Status == 'Temporarily Inactive' ||
                assetRow.Status != 'Active')
            ) {
                statusToValidityMap.put('Inactive', true);
            } else if (
                accountRecord.CS_Owner__c != null &&
                assetRow.Bill__c == null &&
                assetRow.Status == 'Active'
            ) {
                statusToValidityMap.put('Onboarding', true);
            } else if (accountRecord.CS_Owner__c == null && assetRow.Status == 'Churned') {
                statusToValidityMap.put('Churned', true);
            }
        }

        //Statuses are ordered in a list by precadence. The first valid status we get is the one we will use
        for (String statusValue : statusOrderedByPrecadence) {
            if (
                statusToValidityMap.get(statusValue) != null &&
                statusToValidityMap.get(statusValue) == true
            ) {
                return statusValue;
            }
        }
        return null;
    }
}