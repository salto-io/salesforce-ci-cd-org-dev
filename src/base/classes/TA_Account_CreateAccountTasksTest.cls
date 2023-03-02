/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
@isTest
class TA_Account_CreateAccountTasksTest {
    private static Id bizdevRecordTypeId = TA_Account_CreateAccountTasks.BD_ACC_RECORDTYPE_ID;

    @isTest
    public static void testTaskCreateOnInsert() {
        Date connectionDate = Date.Today().addDays(5);
        Account mockAccount = buildMockAccount(
            'New Automate Task Test',
            bizdevRecordTypeId,
            connectionDate
        );
        TA_Account_CreateAccountTasks triggerObject = new TA_Account_CreateAccountTasks();

        List<Task> taskList = triggerObject.execute(
            new List<Account>{ mockAccount },
            null,
            System.TriggerOperation.After_Insert
        );
        system.assertEquals(1, taskList.size(), 'Number of tasks created should be equal to 1');
        system.assertEquals('Open', taskList[0].Status, 'Task should be in Open status');
        system.assertEquals('Send Survey', taskList[0].Subject, 'Subject not set correctly');
    }

    @isTest
    public static void testTaskCreateOnUpdate() {
        Account mockAccountOld = buildMockAccount(
            'New Automate Task Test',
            bizdevRecordTypeId,
            null
        );
        Account mockAccountNew = mockAccountOld.clone(true);
        mockAccountNew.Coinbase_Wallet_Connection_Date__c = Date.Today().addDays(5);

        TA_Account_CreateAccountTasks triggerObject = new TA_Account_CreateAccountTasks();
        List<Task> taskList = triggerObject.execute(
            new List<Account>{ mockAccountNew },
            new List<Account>{ mockAccountOld },
            System.TriggerOperation.After_Update
        );
        system.assertEquals(1, taskList.size(), 'Number of tasks created should be equal to 1');
        system.assertEquals('Open', taskList[0].Status, 'Task should be in Open status');
        system.assertEquals('Send Survey', taskList[0].Subject, 'Subject not set correctly');
    }

    @isTest
    public static void testNoTaskCreation() {
        Date connectionDate = Date.Today().addDays(-100);
        Account mockAccount = buildMockAccount(
            'New Automate Task Test',
            bizdevRecordTypeId,
            connectionDate
        );
        TA_Account_CreateAccountTasks triggerObject = new TA_Account_CreateAccountTasks();

        List<Task> taskList = triggerObject.execute(
            new List<Account>{ mockAccount },
            null,
            System.TriggerOperation.After_Insert
        );
        system.assertEquals(0, taskList.size(), 'Number of tasks created should be equal to 0');
    }

    @isTest
    public static void testNoTaskUpdate() {
        Date connectionDate = Date.Today().addDays(-100);
        Account mockAccountOld = buildMockAccount(
            'New Automate Task Test',
            bizdevRecordTypeId,
            connectionDate
        );
		Account mockAccountNew = mockAccountOld.clone(true);
		mockAccountNew.Coinbase_Wallet_Connection_Date__c = null;

        TA_Account_CreateAccountTasks triggerObject = new TA_Account_CreateAccountTasks();
        List<Task> taskList = triggerObject.execute(
            new List<Account>{ mockAccountNew },
            new List<Account>{ mockAccountOld },
            System.TriggerOperation.After_Update
        );

        system.assertEquals(0, taskList.size(), 'Number of tasks created should be equal to 0');
    }

    private static Account buildMockAccount(
        String accountName,
        Id recordTypeId,
        Date connectionDate
    ) {
        Account mockAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = accountName,
            Customer_Tier__c = '3',
            RecordTypeId = recordTypeId
        );

        if (connectionDate != null) {
            mockAccount.Coinbase_Wallet_Connection_Date__c = connectionDate;
        }

        return mockAccount;
    }
}