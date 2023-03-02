@isTest
private class AccountContactRelationTriggerHandlerTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='account1', Customer_Tier__c = '5'));
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName='Contact', FirstName='First', AccountId=accounts[0].Id, Email='first.contact@test.cb'));
        contacts.add(new Contact(LastName='Contact', FirstName='Second', AccountId=accounts[0].Id, Email='second.contact@test.cb'));
        contacts.add(new Contact(LastName='Contact', FirstName='Third', AccountId=accounts[0].Id));
        insert contacts;
    }
    
    @isTest
    static void testNewACRWithEmail () {
        Account acc = [SELECT Id, 
                   Billing_Contact__c, 
                   (SELECT id, AccountId, ContactId, roles FROM AccountContactRelations) 
                   FROM Account 
                   WHERE Name = 'account1'];
        System.assertNotEquals(null, acc, 'Test account should be created first!');
        System.assertEquals(3, acc.AccountContactRelations.size(), 'Test account should be related to the test contacts!');
        System.assertEquals(null, acc.Billing_Contact__c, 'Billing contact should be null at the time of test account creation!');
        
        Account a = new Account(Name='New ACR Account', Customer_Tier__c = '5');
        insert a;
        Contact c = new Contact(LastName = 'lastName', AccountId = a.Id, Email = 'newacr.contact@test.cb');
        insert c;
        
        AccountContactRelation newACR = new AccountContactRelation(AccountId = acc.Id, ContactId = c.Id, Roles='Billing Primary');
        insert newACR;
        
        Account updatedAcc = [SELECT Id, 
                   Billing_Contact__c, 
                   (SELECT id, AccountId, ContactId, roles FROM AccountContactRelations) 
                   FROM Account 
                   WHERE Id = :acc.Id];
        System.assertEquals(4, updatedAcc.AccountContactRelations.size(), 'New ACR should be created!');
        System.assertEquals(c.Id, updatedAcc.Billing_Contact__c, 'Billing contact should be updated on account!'); 
    }
    
    @isTest
    static void testNewACRWithoutEmail () {
        Account acc = [SELECT Id, 
                   Billing_Contact__c, 
                   (SELECT id, AccountId, ContactId, roles FROM AccountContactRelations) 
                   FROM Account 
                   WHERE Name = 'account1'];
        System.assertNotEquals(null, acc, 'Test account should be created first!');
        System.assertEquals(3, acc.AccountContactRelations.size(), 'Test account should be related to the test contacts!');
        System.assertEquals(null, acc.Billing_Contact__c, 'Billing contact should be null at the time of test account creation!');
        
        Account a = new Account(Name='New ACR Account', Customer_Tier__c = '5');
        insert a;
        Contact c = new Contact(LastName = 'lastName', AccountId = a.Id);
        insert c;
        
        AccountContactRelation newACR = new AccountContactRelation(AccountId = acc.Id, ContactId = c.Id, Roles='Billing Primary');
        try {
            insert newACR;
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage()
                .contains(
                    'Contact Email should not be blank!'
                );
            System.AssertEquals(
                expectedExceptionThrown,
                true,
                'Contact should have an email before assigning the biling primary role!'
            );
        }
    }
    
    @isTest
    static void testACRRoleUpdate () {
        Account acc = [SELECT Id, 
                   Billing_Contact__c, 
                   (SELECT id, AccountId, ContactId, roles FROM AccountContactRelations) 
                   FROM Account 
                   WHERE Name = 'account1'];
        System.assertNotEquals(null, acc, 'Test account should be created first!');
        System.assertEquals(3, acc.AccountContactRelations.size(), 'Test account should be related to the test contacts!');
        System.assertEquals(null, acc.Billing_Contact__c, 'Billing contact should be null at the time of test account creation!');
        
        Map<Id, Contact> contactsMap = new Map<id, Contact>([SELECT Id, FirstName, LastName, Email FROM Contact]);
        System.assertEquals(3, contactsMap.values().Size(), 'Test contacts should be created!');
        Map<String, Contact> nameContactMap = new Map<String, Contact>();
        for (Contact con : contactsMap.values()) {
            nameContactMap.put(con.FirstName, con);
        }
        
        Map<Id, AccountContactRelation> contactIdtoACRMap = new Map<Id, AccountContactRelation>();
        for (AccountContactRelation acr : acc.AccountContactRelations) {
            contactIdtoACRMap.put(acr.ContactId, acr);
        }
        
        Contact firstContact = nameContactMap.get('First');
        AccountContactRelation firstACRToUpdate = new AccountContactRelation();
        firstACRToUpdate.Id = contactIdtoACRMap.get(firstContact.Id).Id;
        firstACRToUpdate.Roles = 'Billing Primary';

        update firstACRToUpdate;
        
        Account updatedAccount = [SELECT Id, Billing_Contact__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(firstContact.Id, updatedAccount.Billing_Contact__c, 'Account billing contact should be updated to first contact!');
        
        Contact secondContact = nameContactMap.get('Second');
        AccountContactRelation secondACRToUpdate = new AccountContactRelation();
        secondACRToUpdate.Id = contactIdtoACRMap.get(secondContact.Id).Id;
        secondACRToUpdate.Roles = 'Billing Primary';
        
        test.startTest();
        try{
            update secondACRToUpdate;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('There is already a contact with role as Billing Primary!'));
            Boolean expectedExceptionThrown = e.getMessage()
                .contains(
                    'There is already a contact with role as Billing Primary!'
                );
            System.AssertEquals(
                expectedExceptionThrown,
                true,
                'Only one contact can have role as Billing Primary!'
            );
        }
        test.stopTest();
        
        Account updatedAccountAgain = [SELECT Id, Billing_Contact__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(firstContact.Id, updatedAccountAgain.Billing_Contact__c, 'Account billing contact should remain same to first contact!');
    }
}