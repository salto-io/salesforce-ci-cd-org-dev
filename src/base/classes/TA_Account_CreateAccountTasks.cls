/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
public class TA_Account_CreateAccountTasks implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    public static Boolean hasExecuted {
        get {
            if (hasExecuted == null)
                hasExecuted = false;
            return hasExecuted;
        }
        public set;
    }

    public void AfterInsert(List<Account> newList) {
        List<Task> tasksToCreate = execute(newList, null, System.TriggerOperation.After_Insert);
        if (tasksToCreate?.size() > 0) {
            insert tasksToCreate;
        }
    }

    public void AfterUpdate(List<Account> newList, List<Account> oldList) {
        List<Task> tasksToCreate = execute(newList, oldList, System.TriggerOperation.After_Update);
        if (tasksToCreate?.size() > 0) {
            insert tasksToCreate;
        }
    }

    @TestVisible
    private static final Id BD_ACC_RECORDTYPE_ID = SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Business_Development_Partnerships')
        .getRecordTypeId();

    @TestVisible
    private static final Id WALLET_OPPORTUNITY_RECORDTYPE_ID = SObjectType.Opportunity
        .getRecordTypeInfosByDeveloperName()
        .get('Wallet_Opportunity')
        .getRecordTypeId();

    @TestVisible
    public List<Task> execute(
        List<Account> newAccountList,
        List<Account> oldAccountList,
        System.TriggerOperation triggerOperation
    ) {
        List<Task> tasksToCreate = new List<Task>();
        if (!hasExecuted) {
            List<Account> qualifiedAccountList = new List<Account>();
            if (triggerOperation == System.TriggerOperation.After_Update) {
                qualifiedAccountList = getQualifiedAccounts(newAccountList, oldAccountList);
            } else if (triggerOperation == System.TriggerOperation.After_Insert) {
                qualifiedAccountList = getQualifiedAccounts(newAccountList);
            }

            if (qualifiedAccountList != null && qualifiedAccountList.size() > 0) {
                tasksToCreate = buildTaskList(qualifiedAccountList);
            }
        }
        hasExecuted = true;
        return tasksToCreate;
    }

    @TestVisible
    private List<Account> getQualifiedAccounts(
        List<Account> newAccountList,
        List<Account> oldAccountList
    ) {
        Map<Id, Account> oldAccountMap = new Map<Id, Account>(oldAccountList);
        List<Account> qualifiedAccountList = new List<Account>();
        for (Account accountRecord : newAccountList) {
            Account oldAccount = oldAccountMap.get(accountRecord.Id);
            if (
                accountRecord.RecordTypeId == BD_ACC_RECORDTYPE_ID &&
                accountRecord.Coinbase_Wallet_Connection_Date__c != null &&
                isCoinbaseConnectionDateValid(accountRecord.Coinbase_Wallet_Connection_Date__c) &&
                accountRecord.Coinbase_Wallet_Connection_Date__c !=
                oldAccount.Coinbase_Wallet_Connection_Date__c
            ) {
                qualifiedAccountList.add(accountRecord);
            }
        }

        return qualifiedAccountList;
    }

    private List<Account> getQualifiedAccounts(List<Account> newList) {
        List<Account> qualifiedAccountList = new List<Account>();
        for (Account newAccount : newList) {
            if (
                newAccount.RecordTypeId == BD_ACC_RECORDTYPE_ID &&
                newAccount.Coinbase_Wallet_Connection_Date__c != null &&
                isCoinbaseConnectionDateValid(newAccount.Coinbase_Wallet_Connection_Date__c)
            ) {
                qualifiedAccountList.add(newAccount);
            }
        }

        return qualifiedAccountList;
    }

    @TestVisible
    private List<Task> buildTaskList(List<Account> qualifiedAccountList) {
        List<Task> tasksToCreate = new List<Task>();
        Map<Id, Id> accountIdToOppOwnerIdMap = buildAccountIdToOppOwnerIdMap(qualifiedAccountList);

        for (Account qualifiedAccount : qualifiedAccountList) {
            Task taskRecord = new Task();
            taskRecord.WhatId = qualifiedAccount.Id;
            taskRecord.Subject = 'Send Survey';
            if (
                !accountIdToOppOwnerIdMap.isEmpty() &&
                accountIdToOppOwnerIdMap.containsKey(qualifiedAccount.Id) &&
                accountIdToOppOwnerIdMap.get(qualifiedAccount.Id) != null
            ) {
                taskRecord.OwnerId = accountIdToOppOwnerIdMap.get(qualifiedAccount.Id);
            } else {
                taskRecord.OwnerId = qualifiedAccount.OwnerId;
            }
            taskRecord.ActivityDate = qualifiedAccount.Coinbase_Wallet_Connection_Date__c.addDays(
                90
            );
            taskRecord.Priority = 'Normal';
            taskRecord.Status = 'Open';
            taskRecord.Description = 'Send a 90-day post integration survey to the account contact for feedback.';
            taskRecord.IsReminderSet = true;
            taskRecord.ReminderDateTime = Datetime.newInstance(
                taskRecord.ActivityDate.addDays(-7),
                Time.newInstance(10, 0, 0, 0)
            );
            tasksToCreate.add(taskRecord);
        }

        return tasksToCreate;
    }

    //IMPORTANT: Must get the most recent applicable Opportunity linked to the Accounts we pass in
    private Map<Id, Id> buildAccountIdToOppOwnerIdMap(List<Account> qualifiedAccountList) {
        Map<Id, Id> accountIdToOppOwnerIdMap = new Map<Id, Id>();
        for (Opportunity opportunityRow : [
            SELECT Id, AccountId, OwnerId
            FROM Opportunity
            WHERE
                AccountId IN :qualifiedAccountList
                AND RecordTypeId = :WALLET_OPPORTUNITY_RECORDTYPE_ID
                AND Wallet_Opportunity_Type__c = 'Coinbase Wallet Integration'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ]) {
            accountIdToOppOwnerIdMap.put(opportunityRow.AccountId, opportunityRow.OwnerId);
        }
        return accountIdToOppOwnerIdMap;
    }

    private Boolean isCoinbaseConnectionDateValid(Date connectionDate) {
        return !(System.today() > connectionDate &&
        connectionDate.daysBetween(System.today()) > 90);
    }
}