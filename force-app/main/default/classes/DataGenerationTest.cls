@isTest
private class DataGenerationTest {
  @testSetup
  static void dataCreation() {
      Account account = TestFactory.getAccount('Muddy Waters Inc.', true);
      Contact contact = TestFactory.getContact(account.Id, 'Muddy', 'Waters', true);
      Opportunity opp = New Opportunity();
      opp.Name = 'Long lost record';
      opp.AccountId = account.Id;
      opp.CloseDate = Date.today().addDays(14);
      opp.StageName = 'Prospecting';
      insert opp;
  }
  @isTest
  static void testBruteForceAccountCreation() {
      List<Account> accts = new List<Account>();
      Test.startTest();
          accts = [SELECT Id FROM Account];
      Test.stopTest();
      assert.isTrue(accts.size() > 0, 'Was expecting to find at least one account created on the Test Setup');
  }
  @isTest
  static void testUseTestFactoryToCreateAccountsWithContacts() {
      List<Account> accts;
      List<Contact> contacts;
      TestFactory.generateAccountWithContacts(5);
      Test.startTest();
          accts = [SELECT Id FROM Account];
          contacts = [SELECT Id FROM Contact];
      Test.stopTest();
      assert.isTrue(accts.size() > 0, 'Was expecting to find at least one account created');
      assert.isTrue(contacts.size() == 6, 'Was expecting to find 6 contacts');
      assert.areNotEqual(accts.size(), contacts.size(), 'Was expecting there to be a different number of account and contacts');
  }
  @isTest
  static void testAtTestSetupMethodsRule() {
      List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity];
      assert.areEqual(1, opps.size(), 'Expected test to find a single Opp');
  }
}