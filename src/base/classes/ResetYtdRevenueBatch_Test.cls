/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
@isTest
private without Sharing class ResetYtdRevenueBatch_Test {
    private static final Id CLOUD_PIPELINE_RECORDTYPE_ID = SObjectType.Opportunity
                                                                            .getRecordTypeInfosByDeveloperName()
                                                                            .get('Cloud_Pipeline')
                                                                            .getRecordTypeId();

 	private static final String BATCH_QUERY = 'SELECT Id, IsClosedDate_Current_Year__c FROM Opportunity WHERE IsClosedDate_Current_Year__c = TRUE AND CloseDate = THIS_YEAR'; 
 
   @TestSetup
    static void makeData(){
        GroupMember GM = new GroupMember();
        GM.GroupId = [Select id from Group where Name = 'Onboarding Queue'  AND Type = 'Queue'].Id ;
        GM.UserOrGroupId = UserInfo.getUserId();
        insert GM;
    }

    @isTest
    private static void keyValueMetadata_SuccessTest() {
        final String EXPECTED_FROM_ADDRESS = 'abc@gmail.com';
        ResetYtdRevenueBatch.emailAddresses = new Map<String, String>{'fromAddress'=> EXPECTED_FROM_ADDRESS};
        
        Test.startTest();
        	Map<String, String> actualEmailsMap = ResetYtdRevenueBatch.emailAddresses;
        Test.stopTest();
        
        System.assert(
            actualEmailsMap != NULL, 
            'EmailAddresses map should have typeofEmail with email address value');
        
        System.assertEquals(
            actualEmailsMap.get('fromAddress'),
            EXPECTED_FROM_ADDRESS,
            'actualEmailsMap should have fromAddress key with "abc@gmail.com" value');
         
    }
    @isTest
    private static void batchWithThisYearOpportunity() {
        System.assertEquals([SELECT Id FROM GroUPMember WHERE Group.Name = 'Onboarding Queue' ].size(), 1);

        Account accountRecord = TestDataHelper.getAccounts(1, true)[0];
		Contact contactRecord = createContactRecord(accountRecord, 'ctc-record-test@cointest.com');
        
        Opportunity oppRecord = TestDataHelper.getOpportunities(accountRecord.Id, 1, false)[0];
        oppRecord.RecordTypeId = CLOUD_PIPELINE_RECORDTYPE_ID;
		oppREcord.Type = 'Upsell';
		oppRecord.Primary_Contact__c = contactRecord.Id;
        oppRecord.StageName = 'Closed Won';
        oppRecord.CloseDate = System.today();
        oppRecord.Survey_Sent__c = true;
        oppRecord.Date_Override__c = true;
		oppRecord.Onboarding_Required__c = 'Existing Customer - Onboard';
		oppRecord.Ideal_Timezone__c = 'EST - Eastern Standard Time - GMT-5:00';
		oppRecord.Product_Type__c = 'Coinbase Pay SDK';
		oppRecord.Product_Interest__c = 'Other (Unspecified)';
		oppRecord.Other_Amount__c = 123.45;
        insert oppRecord;

        List<Opportunity> queryOppyRecords = [SELECT Id, IsClosedDate_Current_Year__c FROM Opportunity];
        
        System.assertEquals(
            queryOppyRecords.size(), 
            1, 
            'As system created one opportunity, it should return one opportunity record only');
            
        System.assertEquals(
            queryOppyRecords[0].IsClosedDate_Current_Year__c, 
            TRUE, 
            'Opportunity ClosedDate is THIS_YEAR AND StageName is "Closed Won", IsClosedDate_Current_Year__c should be TRUE by before trigger flow');
            
            
            Test.startTest();
                String query = BATCH_QUERY + ' AND CloseDate = THIS_YEAR';
                Database.executeBatch(new ResetYtdRevenueBatch(query));
            Test.stopTest();
            
        List<Opportunity> queryUpdatedOppyRecords = [SELECT Id, IsClosedDate_Current_Year__c FROM Opportunity];
            
            System.assertEquals(
            queryUpdatedOppyRecords.size(), 
            1, 
            'As system has one opportunity, it should return one opportunity record only');
            
            System.assertEquals(
            queryOppyRecords[0].IsClosedDate_Current_Year__c, 
            TRUE, 
            'Due to flow and opportunity closeWon in THIS_YEAR conditions being met, '+
            'batch run should flip Opportunity.IsClosedDate_Current_Year__c value to false, '+
            'and then update checkbox back to true');
    }

	private static Contact createContactRecord(Account accountRecord, String emailStr){
		Contact contactRecord = new Contact();
		contactRecord.AccountId = accountRecord.Id;
		contactRecord.LastName = 'Ctc-Opp-Test';
		contactRecord.Email = emailStr;
		insert contactRecord;

		return contactRecord;
	}
    
}
