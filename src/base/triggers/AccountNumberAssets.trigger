trigger AccountNumberAssets on Asset (after delete, after insert, after undelete,
after update) {
/*
    Set<Id> accountIds = new Set<Id>();
    if(Trigger.isDelete){
        for(Asset assetRecord : Trigger.old) {
            accountIds.add(assetRecord.AccountId);
        }
    } else {
        for(Asset assetRecord : Trigger.New) {
            if(Trigger.isInsert || Trigger.isUndelete) {
                accountIds.add(assetRecord.AccountId);
            }
            if(Trigger.isUpdate && assetRecord.AccountId != Trigger.oldMap.get(assetRecord.Id).AccountId){
                accountIds.add(assetRecord.AccountId);
                accountIds.add(Trigger.oldMap.get(assetRecord.Id).AccountId);
            }
        }
    }
    if(accountIds.size() > 0) {
        List<Account> accountList = [SELECT Number_of_Assets__c, (SELECT Id FROM Assets) FROM Account WHERE Id in: accountIds];
        if (accountList.size() > 0) {
            for(Account accRecord : accountList) {
                accRecord.Number_of_Assets__c = accRecord.Assets.size();
                UPDATE accountList;
            }
        }
    }
	*/
}