@isTest
public class TA_BTProduct_CheckStandardProductTest {
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

    List<Account> a = TestDataHelper.getAccounts(1, true);
    List<Opportunity> opp = TestDataHelper.getOpportunities(a[0].Id, 1, false);
    opp[0]
      .RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get('Cloud_Pipeline')
      .getRecordTypeId();
    opp[0].closeDate = System.today().addDays(30);
    insert opp;

    Protocol__c protocol = new Protocol__c();
    protocol.Inflation_Rate__c = 1.00;
    protocol.Price__c = 0.15;
    protocol.Name = 'My Test Token';
    protocol.Symbol__c = 'MTT';

    insert protocol;

    Node__c node = new Node__c();
    node.Base_Node_Price__c = 1.00;
    node.Delegation_Fee__c = 5.00;
    node.Name = 'Test Node';
    node.Node_Family__c = 'Participation';
    node.Participatory_Fee__c = 5.00;
    node.Protocol__c = protocol.Id;
    insert node;

    BT_Product__c btp = new BT_Product__c();
    btp.Account__c = a[0].Id;
    btp.Opportunity__c = opp[0].Id;
    btp.Availability_Commitment__c = '99.0%';
    btp.Billing_Frequency__c = 'Monthly';
    btp.Quantity__c = 1.0;
    btp.Participatory_Fee__c = 10.00;
    btp.Node_Price__c = 100.00;
    btp.Node__c = node.Id;
    btp.Tokens_Staked__c = 5;
    insert btp;
  }

  @isTest
  static void createBTProductHasStdProduct() {
    Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 LIMIT 1];
    Account a = [SELECT Id FROM Account LIMIT 1];
    Node__c node = [
      SELECT Id, Node_Family__c, Protocol__r.Name
      FROM Node__c
      LIMIT 1
    ];
    Protocol__c protocol = [SELECT Id FROM Protocol__c LIMIT 1];
    Opportunity opp = [SELECT Id, PriceBook2Id FROM Opportunity LIMIT 1];
    BT_Product__c btp = [
      SELECT
        Id,
        Account__c,
        Opportunity__c,
        Availability_Commitment__c,
        Billing_Frequency__c,
        Quantity__c,
        Participatory_Fee__c,
        Node_Price__c,
        Node__c,
        Has_Standard_Product__c
      FROM BT_Product__c
      LIMIT 1
    ];

    System.assertEquals(
      true,
      btp.Has_Standard_Product__c,
      'Has standard product field should be updated to true after record insert!'
    );
    System.assertEquals(
      Test.getStandardPricebookId(),
      opp.PriceBook2Id,
      'Standard price book id should be updated on opportunity!'
    );
    System.assertEquals(
      1,
      [SELECT Id FROM OpportunityLineItem WHERE BT_Product__c = :btp.Id].size(),
      'An opportunity product record should get created to the BT product record!'
    );
    System.assertEquals(
      btp.Billing_Frequency__c,
      [
        SELECT Id, Billing_Frequency__c
        FROM OpportunityLineItem
        WHERE BT_Product__c = :btp.Id
      ]
      .Billing_Frequency__c,
      'An opportunity product record should should have the same billing frequency as the BT product record!'
    );

    btp.Billing_Frequency__c = 'Yearly';
    btp.Availability_Commitment__c = '99.0%';
    update btp;

    BT_Product__c updatedRecord = [
      SELECT
        Id,
        Availability_Commitment__c,
        Billing_Frequency__c,
        Node__r.Node_Family__c,
        Quantity__c,
        Participatory_Fee__c,
        Opportunity__r.CloseDate,
        Node_Price__c,
        Sub_Total__c,
        (
          SELECT
            Availability_Commitment__c,
            BT_Product__c,
            Billing_Frequency__c,
            Had_BT_Product__c,
            Hosted_Service__c,
            Node_Count__c,
            Participatory_Fee__c,
            Quantity,
            ServiceDate,
            Subscription_Fee__c,
            UnitPrice
          FROM Opportunity_Product__r
        )
      FROM BT_Product__c
      WHERE Id = :btp.Id
    ];

    System.assertEquals(
      'Yearly',
      updatedRecord.Opportunity_Product__r[0].Billing_Frequency__c,
      'Billing frequesncy should be updated!'
    );
    System.assertEquals(
      '99.0%',
      updatedRecord.Opportunity_Product__r[0].Availability_Commitment__c,
      'Availability commitment should be updated!'
    );
  }

  @isTest
  static void createBTProductHasNoStdProduct() {
    Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 LIMIT 1];
    Account a = [SELECT Id FROM Account LIMIT 1];
    Node__c node = [
      SELECT Id, Node_Family__c, Protocol__r.Name
      FROM Node__c
      LIMIT 1
    ];
    Protocol__c protocol = [SELECT Id FROM Protocol__c LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    BT_Product__c btp = [
      SELECT
        Id,
        Account__c,
        Opportunity__c,
        Availability_Commitment__c,
        Billing_Frequency__c,
        Quantity__c,
        Participatory_Fee__c,
        Node_Price__c,
        Node__c,
        Sub_Total__c
      FROM BT_Product__c
      LIMIT 1
    ];

    List<OpportunityLineItem> oli = [
      SELECT
        Id,
        OpportunityId,
        Availability_Commitment__c,
        Billing_Frequency__c,
        Had_BT_Product__c,
        Hosted_Service__c,
        Node_Count__c,
        Participatory_Fee__c,
        Protocol__c,
        Quantity,
        Subscription_Fee__c,
        UnitPrice
      FROM OpportunityLineItem
    ];

    System.assertEquals(
      1,
      oli.size(),
      'New Opportunity Product record should get created for the BT product!'
    );
    System.assertEquals(opp.Id, oli[0].OpportunityId);
    System.assertEquals(
      btp.Availability_Commitment__c,
      oli[0].Availability_Commitment__c
    );
    System.assertEquals(btp.Billing_Frequency__c, oli[0].Billing_Frequency__c);
    System.assertEquals(true, oli[0].Had_BT_Product__c);
    System.assertEquals('Network Participation', oli[0].Hosted_Service__c);
    System.assertEquals(btp.Quantity__c, oli[0].Node_Count__c);
    System.assertEquals(btp.Participatory_Fee__c, oli[0].Participatory_Fee__c);
    System.assertEquals(Node.Protocol__r.Name, oli[0].Protocol__c);
    System.assertEquals(1, oli[0].Quantity);
    System.assertEquals(btp.Node_Price__c, oli[0].Subscription_Fee__c);
    System.assertEquals(btp.Sub_Total__c, oli[0].UnitPrice);
  }
}
