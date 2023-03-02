/**
 * @description       : Test class for TA_Opportunity_OpportunityValidator
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-03-2023
 * @last modified by  : Lavanya Tangati
**/
@isTest
private class TA_Opportunity_OpportunityValidatorTest {
    @isTest
    static void validateOppFilesValidationNegative(){

        List<Account> a = TestDataHelper.getAccounts(1, true);
        List<Opportunity> opp = TestDataHelper.getOpportunities(a[0].Id, 1, false);
        opp[0].RecordTypeId =  TA_Opportunity_OpportunityValidator.WALLET_OPPORTUNITY_RECORDTYPE_ID;
        insert opp;

        opp[0].Wallet_Opportunity_Type__c = 'Wallet Campaign/Quest';
        opp[0].StageName = 'Executed';

        try{
            update opp[0];
            System.assert(false, 'An error should have thrown on moving the Stage to Executed and beyond');
        }
        catch(Exception ex){
            System.assert(true, ex.getMessage());
        }
    }

    @isTest
    static void validateOppFilesValidationPositive(){

        List<Account> a = TestDataHelper.getAccounts(1, true);
        List<Opportunity> opp = TestDataHelper.getOpportunities(a[0].Id, 1, false);
        opp[0].RecordTypeId =  TA_Opportunity_OpportunityValidator.WALLET_OPPORTUNITY_RECORDTYPE_ID;
        insert opp;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'order form',
            PathOnClient = 'order_form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );

        insert contentVersion;    
        List<ContentDocument> documents = [
        SELECT Id, Title, LatestPublishedVersionId 
        FROM ContentDocument
        ];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = opp[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        opp[0].Wallet_Opportunity_Type__c = 'Wallet Campaign/Quest';
        opp[0].StageName = 'Executed';
        opp[0].Internal_Review_Status__c = 'Approved';
        opp[0].Wallet_Campaign_Type__c = 'Incentive';

        try{
            update opp[0];
            System.assert(true, 'An error should not have thrown as there is afile attached to the Opportunity');
        }
        catch(Exception ex){
            System.assert(false, ex.getMessage());
        }
    }

    @isTest
    static void validateOppFilesWalletTypeCheck(){

        List<Account> a = TestDataHelper.getAccounts(1, false);
        a[0].Dapp_Sub_Type__c = 'Gaming';
        insert a;

        List<Opportunity> opp = TestDataHelper.getOpportunities(a[0].Id, 1, false);
        opp[0].RecordTypeId =  TA_Opportunity_OpportunityValidator.WALLET_OPPORTUNITY_RECORDTYPE_ID;
        insert opp;

        opp[0].Wallet_Opportunity_Type__c = 'Coinbase Wallet Integration';
        opp[0].Dapp_Url__c ='test.com';
        opp[0].Competitors__c ='Metamask';
        opp[0].Wallet_OKR_Cohort__c ='test123';
        opp[0].StageName = 'Executed';

        try{
            update opp[0];
            System.assert(true, 'An error should not have thrown as there is afile attached to the Opportunity');
        }
        catch(Exception ex){
            System.assert(false, ex.getMessage());
        }
    }
}