@isTest
private with sharing class TA_Asset_ChurnedNotifier_Test {
  private static final String STATUS_CHURNED = TA_Asset_ChurnedNotifier.STATUS_CHURNED;

  private static String statusNotChurned {
    get {
      if (statusNotChurned == null) {
        String status;
        for (
          Schema.PicklistEntry entryObj : Asset.Status.getDescribe()
            .getPicklistValues()
        ) {
          status = entryObj.getValue();
          if (status != TA_Asset_ChurnedNotifier.STATUS_CHURNED) {
            statusNotChurned = status;
            break;
          }
        }
      }
      return statusNotChurned;
    }
    set;
  }

  private static String churnedReason {
    get {
      if (churnedReason == null) {
        for (
          Schema.PicklistEntry entryObj : Asset.Churned_Reason__c.getDescribe()
            .getPicklistValues()
        ) {
          churnedReason = entryObj.getValue();
          break;
        }
      }
      return churnedReason;
    }
    set;
  }

  @testSetup
  static void setup() {
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    update standardPricebook;

    Product2 product = new Product2(Name = 'Standard Sale', IsActive = true);
    insert product;

    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = standardPricebook.Id,
      Product2Id = product.Id,
      isActive = true,
      UnitPrice = 1.00
    );
    insert pbe;
  }

  @isTest
  private static void checkAssetStatusIsNotChurned_Insert() {
    Asset record = new Asset(Status = statusNotChurned);
    TA_Asset_ChurnedNotifier obj = new TA_Asset_ChurnedNotifier();

    Test.startTest();
    obj.AfterInsert(new List<Asset>{ record });
    Integer issuedSOQL = Limits.getQueries();
    Integer issueDML = Limits.getDmlStatements();
    Test.stopTest();

    System.assertEquals(
      0,
      issuedSOQL,
      'A SOQL should not be performed on parent record, When Asset status is not "' +
      STATUS_CHURNED +
      '"'
    );

    System.assertEquals(
      0,
      issueDML,
      'A DML operation should not be performed to update the parent record, When the Asset status is not "' +
      STATUS_CHURNED +
      '"'
    );
  }

  @isTest
  private static void checkAssetStatusIsChurnedWithoutBTProduct_Insert() {
    Id assetId = fflib_IDGenerator.generate(Asset.SObjectType);
    Asset record = new Asset(Id = assetId, Status = STATUS_CHURNED);
    TA_Asset_ChurnedNotifier obj = new TA_Asset_ChurnedNotifier();

    Test.startTest();
    obj.AfterInsert(new List<Asset>{ record });
    Integer issuedSOQL = Limits.getQueries();
    Integer issueDML = Limits.getDmlStatements();
    Test.stopTest();

    System.assertEquals(
      1,
      issuedSOQL,
      'When Asset status is "' +
      STATUS_CHURNED +
      '" System should performed SOQL to Update Parent BT_Product as Churned "' +
      STATUS_CHURNED +
      '"'
    );

    System.assertEquals(
      0,
      issueDML,
      'Since Parent BT_Product is not present in Asset, it should not perform any updates to parent records'
    );
  }

  @isTest
  private static void checkAssetStatusChangedToNotChurned_Update() {
    Id assetId = fflib_IDGenerator.generate(Asset.SObjectType);
    Asset newRecord = new Asset(Id = assetId, Status = statusNotChurned);
    Asset oldRecord = newRecord.clone(
      true /*preserved ids*/,
      false,
      false,
      false
    );
    oldRecord.Status = STATUS_CHURNED;

    TA_Asset_ChurnedNotifier obj = new TA_Asset_ChurnedNotifier();

    Test.startTest();
    obj.AfterUpdate(new List<Asset>{ newRecord }, new List<Asset>{ oldRecord });
    Integer issuedSOQL = Limits.getQueries();
    Integer issueDML = Limits.getDmlStatements();
    Test.stopTest();

    System.assertEquals(
      0,
      issuedSOQL,
      'A SOQL should not be performed on parent record, When Asset status not changed to "' +
      STATUS_CHURNED +
      '"'
    );

    System.assertEquals(
      0,
      issueDML,
      'A DML operation should not be performed to update the parent record, When the Asset status is not changed to "' +
      STATUS_CHURNED +
      '"'
    );
  }

  @isTest
  private static void assetChangedToChurnedWithBTProduct_Insert() {
    String nodeString = 'Node';
    Account testAccount = TestDataHelper.getAccounts(1, true)[0];
    Contact testContact = TestDataHelper.getContacts(
      testAccount.Id,
      1,
      true
    )[0];

    Opportunity testOpportunity = TestDataHelper.getOpportunities(
      testAccount.Id,
      1,
      false
    )[0];
    testOpportunity.Pricebook2Id = Test.getStandardPricebookId();
    insert testOpportunity;

    List<Opportunity> queriedOppies = [SELECT Id, Churned__c FROM Opportunity];
    System.assertEquals(
      1,
      queriedOppies.size(),
      'System should create only one Opportunity record'
    );

    System.assertEquals(
      false,
      queriedOppies[0].Churned__c,
      'On Insert Opportunity should set Churned value as FALSE'
    );

    Protocol__c protocol = new Protocol__c(Name = 'test');
    insert protocol;

    Node__c node = new Node__c(
      Protocol__c = protocol.Id,
      Node_Family__c = nodeString,
      Base_Node_Price__c = 1
    );
    insert node;

    BT_Product__c testBtProductRecord = new BT_Product__c();
    testBtProductRecord.Opportunity__c = queriedOppies[0].Id;
    testBtProductRecord.Account__c = testAccount.Id;
    testBtProductRecord.Node__c = node.Id;
    testBtProductRecord.Quantity__c = 1;
    testBtProductRecord.Churned__c = false;
    testBtProductRecord.Billing_Frequency__c = 'Monthly';
    testBtProductRecord.Has_Standard_Product__c = true;
    testBtProductRecord.Tokens_Staked__c = 5;
    insert testBtProductRecord;

    Test.startTest();
    Asset record = new Asset(
      Name = 'testAsset',
      AccountId = testAccount.Id,
      ContactId = testContact.Id,
      Status = STATUS_CHURNED,
      Churned_Reason__c = churnedReason,
      BT_Product__c = testBtProductRecord.Id,
      UsageEndDate = System.today().addDays(-1),
      Protocol__c = 'Acala',
      Product_Type__c = nodeString
    );
    insert record;
    Test.stopTest();

    List<Asset> assets = [
      SELECT
        Id,
        BT_Product__r.Id,
        BT_Product__r.Churned__c,
        BT_Product__r.Opportunity__r.Id,
        BT_Product__r.Opportunity__r.Churned__c
      FROM Asset
    ];

    System.assertEquals(
      1,
      assets.size(),
      'System should create only one asset record'
    );

    System.assertEquals(
      testBtProductRecord.Id,
      assets[0].BT_Product__r.Id,
      'The Asset parent BT_Product record should be the same as the BT_Product record inserted in the test'
    );

    System.assertEquals(
      true,
      assets[0].BT_Product__r.Churned__c,
      'When Asset Status set as "' +
      STATUS_CHURNED +
      '", it should update parent Asset.BT_Product object field "' +
      STATUS_CHURNED +
      '" to true'
    );

    System.assertEquals(
      testOpportunity.Id,
      assets[0].BT_Product__r.Opportunity__r.Id,
      'The Asset parent BT_Product parent Opportunity should be the same as the Opportunity record inserted in the test'
    );

    System.assertEquals(
      true,
      assets[0].BT_Product__r.Churned__c,
      'When Asset Status set as "' +
      STATUS_CHURNED +
      '", it should update parent Asset.BT_Product__r.Opportunity__r object field "' +
      STATUS_CHURNED +
      '" to true'
    );
  }

  @isTest
  private static void sObjectDMLException_test() {
    Id fakeBtProductId = fflib_IDGenerator.generate(BT_Product__c.SObjectType);
    BT_Product__c dmlExceptionRecordToUpdate = new BT_Product__c(
      Id = fakeBtProductId,
      Churned__c = true
    );
    Exception expectedException;

    try {
      TA_Asset_ChurnedNotifier.updateRelatedChurnedRecords(
        new List<SObject>{ dmlExceptionRecordToUpdate }
      );
    } catch (DMLException ex) {
      expectedException = ex;
    }
    System.assertEquals(
      null,
      expectedException,
      'When updating a related record, the system should throw an exception if there is an exception'
    );
  }
}
