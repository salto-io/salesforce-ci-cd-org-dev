@isTest
private class TA_Opportunity_OnboardingCaseHandlerTest {
   private static final Id WALLET_RT_ID = TA_Opportunity_OnboardingCaseHandler.WALLET_OPPY_RECORDTYPE_ID;
   private static final Id NO_PIPELINE_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        												.get('No_Pipeline').getRecordTypeId();
   
    @isTest
    private static void onboardingQueueIdTest() {
      Test.startTest();
        	Id onboardingQueueId = TA_Opportunity_OnboardingCaseHandler.onboardingQueueId;
      Test.stopTest();
        
        System.assertNotEquals(
            NULL,
            onboardingQueueId,
            'DeveloperName "Onboarding_Queue" should returned Id by Salesforce.');
    }
    
    @isTest
    private static void onboardingNotificationIdTest() {
      Test.startTest();
        	Id onboardingNotificationId = TA_Opportunity_OnboardingCaseHandler.onboardingNotificationId;
      Test.stopTest();
        
        System.assertNotEquals(
            NULL,
            onboardingNotificationId,
            'DeveloperName "Onboarding_Notification" should returned Id by Salesforce.');
    }
    
    @isTest
    private static void insert_TrialStageOppy_Test() {
        Opportunity oppyTest = new Opportunity(StageName = 'Trial');
        TA_Opportunity_OnboardingCaseHandler handler = new TA_Opportunity_OnboardingCaseHandler();
        Test.startTest();
        	handler.beforeInsert(new List<Opportunity>{oppyTest});
        	Integer issuedDML = Limits.getDmlStatements();
        	Integer issuedQuery = Limits.getQueries();
        Test.stopTest();
        
        System.assertEquals(
            0,
            issuedDML,
            'When oppy stageName is not "Closed Won", system should skip the record and do not perform any DML operation');
        
        System.assertEquals(
            0,
            issuedQuery,
            'When oppy stageName is not "Closed Won", system should skip the record and do not perform any Query operation');  	
    }
    
    @isTest
    private static void insert_ClosedWon_PreviouslyClosedTrue_Test() {
        Opportunity oppyTest = new Opportunity(StageName = 'Closed Won', Previously_Closed__c = TRUE);
        TA_Opportunity_OnboardingCaseHandler handler = new TA_Opportunity_OnboardingCaseHandler();
        Test.startTest();
        	handler.beforeInsert(new List<Opportunity>{oppyTest});
        	Integer issuedDML = Limits.getDmlStatements();
        	Integer issuedQuery = Limits.getQueries();
        Test.stopTest();
        
        System.assertEquals(
            0,
            issuedDML,
            'When oppy is "Closed Won" but Previously_Closed is True, system should skip the record and do not perform any DML operation');
        
        System.assertEquals(
            0,
            issuedQuery,
            'When oppy is "Closed Won" but Previously_Closed is True, system should skip the record and do not perform any Query operation');  	
    }
    
    @isTest
    private static void insertOnboardingRequiredNo_Test() {
        final String NO_VALUE = TA_Opportunity_OnboardingCaseHandler.NO_VALUE;            
        Opportunity oppyTest = new Opportunity(
            StageName = 'Closed Won', 
            Previously_Closed__c = FALSE, 
            Onboarding_Required__c = NO_VALUE,
        	RecordTypeId = WALLET_RT_ID);
        TA_Opportunity_OnboardingCaseHandler handler = new TA_Opportunity_OnboardingCaseHandler();
        
        Test.startTest();
        	handler.beforeInsert(new List<Opportunity>{oppyTest});
        Test.stopTest();
        
         System.assertEquals(
        	NO_VALUE,
        	oppyTest.Onboarding_Required__c, 
            'When Opportunity is flipped to Closed Won, Previously_Closed is False and Onboarding_Required is "No", '+
             'System should create chatter feed on a record');
    }
    
    @isTest
    private static void insertClosedWithDelegationProductType_Test() {
        final String DELEGATION_VALUE = TA_Opportunity_OnboardingCaseHandler.DELEGATION_PRODUCT_TYPE;
        
         Opportunity oppyTest = new Opportunity(
            StageName = 'Closed Won', 
            Previously_Closed__c = FALSE, 
            Product_Type__c = DELEGATION_VALUE,
        	RecordTypeId = WALLET_RT_ID);
        TA_Opportunity_OnboardingCaseHandler handler = new TA_Opportunity_OnboardingCaseHandler();
            
        Test.startTest();
        	handler.beforeInsert(new List<Opportunity>{oppyTest});
        Test.stopTest();
        
         System.assertEquals(
        	DELEGATION_VALUE,
        	oppyTest.Product_Type__c, 
            'When Opportunity is flipped to Closed Won, Previously_Closed is False and Product Type is "Delegation", '+
             'System should create chatter feed on a record');
    }
    
    @isTest
    private static void updateClosedWonSendNotification_Test() {
       final Date EXPECTED_TODAY_DATE = System.today();
       Account testAccount = TestDataHelper.getAccounts(1, true /*create Account*/)[0];
       Contact testContact = TestDataHelper.getContacts(testAccount.Id, 1, true /*create Contact*/)[0];

        Opportunity testOppy = TestDataHelper.getOpportunities(testAccount.Id, 1, false /*create Oppy*/)[0];
        testOppy.Previously_Closed__c = FALSE;
        testOppy.Product_Interest__c = 'Other (Unspecified)';
		testOppy.Other_Amount__c = 2;
        testOppy.Type = 'Renewal';
        testOppy.Ideal_Timezone__c = 'EST - Eastern Standard Time - GMT-5:00';
        testOppy.Primary_Contact__c = testContact.Id;
		insert testOppy;
        Test.startTest();
       		testOppy.StageName = 'Closed Won';
        	testOppy.Previously_Closed__c = FALSE;
        	testOppy.Date_Override__c = FALSE;
        	testOppy.Onboarding_Required__c = 'New Customer - Onboard';
        	update testOppy;
        Integer issuedCustomNotification = Limits.getMobilePushApexCalls();
        Test.stopTest();
        
        List<Opportunity> queriedOppies = [SELECT Id, CloseDate FROM Opportunity];
        
        System.assertEquals(
            1, 
        	queriedOppies.size(),
        	'Total inserted opportunity should be 1');
        
         System.assertEquals(
            testOppy.Id, 
        	queriedOppies[0].Id,
        	'Queried opportunity should be same as inserted opportunity in the test');
        
        System.assertEquals(
        	EXPECTED_TODAY_DATE,
        	queriedOppies[0].CloseDate, 
            'When Opportunity is flipped to Closed Won and Date Override is False, System should update '+
            'CloseDate to Today');
    }
    
    @isTest
    private static void updateClosedWithDateOverrideFalse_Test() {
        final String DELEGATION_VALUE = TA_Opportunity_OnboardingCaseHandler.DELEGATION_PRODUCT_TYPE;
        Date todayDate = System.today();
         Opportunity oldRecord = new Opportunity(
            Id = fflib_IDGenerator.generate(Opportunity.SobjectType),
            StageName = 'Closed Won', 
            Previously_Closed__c = FALSE,
            CloseDate = todayDate.addDays(-2),
            Date_Override__c = FALSE,
            Product_Type__C = DELEGATION_VALUE,
        	RecordTypeId = NO_PIPELINE_RT_ID);
        
        Opportunity newRecord = oldRecord.clone(true /*clone ids*/, false, false, false);
        newRecord.Product_Type__C = 'Participation';
        
        TA_Opportunity_OnboardingCaseHandler handler = new TA_Opportunity_OnboardingCaseHandler();
            
        Test.startTest();
        	handler.beforeUpdate(new List<Opportunity>{newRecord}, new List<Opportunity>{oldRecord});
        Test.stopTest();
        
         System.assertEquals(
        	todayDate,
        	newRecord.CloseDate, 
            'When Opportunity is flipped to Closed Won and Date Override is False, System should update '+
            'CloseDate to Today');
    }
}