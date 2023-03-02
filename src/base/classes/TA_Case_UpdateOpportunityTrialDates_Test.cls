@isTest
private class TA_Case_UpdateOpportunityTrialDates_Test {

    private static final Date TODAY_DATE = System.today();
    private static final Id TRIAL_PIPELINE_RT_Id = TA_Case_UpdateOpportunityTrialDates.TRIAL_PIPELINE_RT_Id;
    private static Map<String, Schema.RecordTypeInfo> recordTypeInfoByDeveloperName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

    private static  Id notTrailCaseRtId {
        get {
            if(notTrailCaseRtId == NULL) {

                for(String rtDeveloperName :recordTypeInfoByDeveloperName.keySet()) {
                   Schema.RecordTypeInfo recordTypeInfo =  recordTypeInfoByDeveloperName.get(rtDeveloperName);
                    if(recordTypeInfo.isActive() && recordTypeInfo.getRecordTypeId() != TRIAL_PIPELINE_RT_Id) {
                        notTrailCaseRtId = recordTypeInfo.getRecordTypeId();
                        break;
                    }
                }
            }
        return notTrailCaseRtId;
        }
        set;
    }

    @isTest
    private static void insert_OtherThanTrialCase() {
        Case record = new Case(
            RecordTypeId = notTrailCaseRtId,
            Opportunity__c = fflib_IDGenerator.generate(Opportunity.SObjectType),
            Trial_Start_Date__c  = TODAY_DATE,
            Trial_End_Date__c = TODAY_DATE
        );

        TA_Case_UpdateOpportunityTrialDates caseTrialObj = new TA_Case_UpdateOpportunityTrialDates();

        Test.startTest();
            caseTrialObj.afterInsert(new List<Case>{record});
            Integer issuedSOQL = Limits.getQueries();
            Integer issuedDML = Limits.getDmlStatements();
        Test.stopTest();

         System.assertEquals(
            0,
            issuedSOQL,
            'When Case record types other than "Trial_Pipeline",system should not be performed SOQL');

        System.assertEquals(
            0,
            issuedDML,
            'When Case record types other than "Trial_Pipeline",system should not be perfromed DML operation');
    }

    @isTest
    private static void insert_TrialCaseWithoutParentOppy() {
        Case record = new Case(
            RecordTypeId = TRIAL_PIPELINE_RT_Id,
            Opportunity__c = NULL,
            Trial_Start_Date__c  = TODAY_DATE,
            Trial_End_Date__c = TODAY_DATE
        );

        TA_Case_UpdateOpportunityTrialDates caseTrialObj = new TA_Case_UpdateOpportunityTrialDates();

        Test.startTest();
            caseTrialObj.afterInsert(new List<Case>{record});
            Integer issuedSOQL = Limits.getQueries();
            Integer issuedDML = Limits.getDmlStatements();
        Test.stopTest();

         System.assertEquals(
            0,
            issuedSOQL,
            'When Case does not have Parent Opportunity Id, system should not be performed SOQL to update Parent Opportunity record');

        System.assertEquals(
            0,
            issuedDML,
            'When Case does not have Parent Opportunity Id, system should not be performed DML to update Parent Opportunity record');
    }

    @isTest
    private static void insert_TrialCaseWithoutTrialDates() {
        Case record = new Case(
            RecordTypeId = TRIAL_PIPELINE_RT_Id,
            Opportunity__c = fflib_IDGenerator.generate(Opportunity.SObjectType),
            Trial_Start_Date__c  = NULL,
            Trial_End_Date__c = NULL
        );

        TA_Case_UpdateOpportunityTrialDates caseTrialObj = new TA_Case_UpdateOpportunityTrialDates();

        Test.startTest();
            caseTrialObj.afterInsert(new List<Case>{record});
            Integer issuedSOQL = Limits.getQueries();
            Integer issuedDML = Limits.getDmlStatements();
        Test.stopTest();

         System.assertEquals(
            0,
            issuedSOQL,
            'When Case record does not have Trial Start/End Dates, system should not be performed SOQL to update Parent Opportunity record');

        System.assertEquals(
            0,
            issuedDML,
            'When Case record does not have Trial Start/End Dates, system should not be performed DML to update Parent Opportunity record');
    }

    @isTest
    private static void insert_TrialCasesWithSameTrialDates_AsOppy() {
        Account testAccount = TestDataHelper.getAccounts(1, true /*create Account*/)[0];

        Opportunity testOppy = TestDataHelper.getOpportunities(testAccount.Id, 1, false /*create Oppy*/)[0];
        testOppy.Trial_Start_Date__c = TODAY_DATE;
        testOppy.Trial_End_Date__c = TODAY_DATE;
        insert testOppy;

        Case record = new Case(
            RecordTypeId = TRIAL_PIPELINE_RT_Id,
            Opportunity__c = testOppy.Id,
            Trial_Start_Date__c  = TODAY_DATE,
            Trial_End_Date__c = TODAY_DATE
        );

        TA_Case_UpdateOpportunityTrialDates caseTrialObj = new TA_Case_UpdateOpportunityTrialDates();

        Test.startTest();
            caseTrialObj.afterInsert(new List<Case>{record});
            Integer issuedSOQL = Limits.getQueries();
            Integer issuedDML = Limits.getDmlStatements();
        Test.stopTest();

         System.assertEquals(
            1,
            issuedSOQL,
            'When Case record have Trial Start/End Dates & Parent Oppy Id, system should performed SOQL to update Parent Opportunity record');

        System.assertEquals(
            0,
            issuedDML,
            'When Case record Trial Start/End Dates is same as Parent Oppy Trial Start/End Date,'+
            ' system should not be performed DML to update Parent Opportunity record');
    }


    @isTest
    private static void insert_TrialCasesWithDifferentTrialDates_AsOppy() {
        Account testAccount = TestDataHelper.getAccounts(1, true /*create Account*/)[0];

        Opportunity testOppy = TestDataHelper.getOpportunities(testAccount.Id, 1, false /*create Oppy*/)[0];
        testOppy.Trial_Start_Date__c = System.today().addDays(+1);
        testOppy.Trial_End_Date__c = TODAY_DATE;
        insert testOppy;

        Case caseRecord = new Case(
            RecordTypeId = TRIAL_PIPELINE_RT_Id,
            Opportunity__c = testOppy.Id,
            Trial_Start_Date__c  = TODAY_DATE,
            Trial_End_Date__c = TODAY_DATE
        );

        TA_Case_UpdateOpportunityTrialDates caseTrialObj = new TA_Case_UpdateOpportunityTrialDates();

        Test.startTest();
            insert caseRecord;
        Test.stopTest();

        List<Opportunity> quieryOppies = [SELECT Trial_Start_Date__c, Trial_End_Date__c FROM Opportunity];

         System.assertEquals(
            1,
            quieryOppies.size(),
            'System should have only one Opportunity exists in the Database');

        Opportunity queriedOppy = quieryOppies[0];

        System.assertEquals(
            testOppy.Id,
            queriedOppy.Id,
            'Queried oppy should be same as instered oppy in the test method');

        System.assertEquals(
            caseRecord.Trial_Start_Date__c,
            queriedOppy.Trial_Start_Date__c,
            'System should update Opportunity Trial_Start_Date__c as child Case Trail_Start_Date__c value');

        System.assertEquals(
            caseRecord.Trial_End_Date__c,
            queriedOppy.Trial_End_Date__c,
            'System should update Opportunity Trial_Start_Date__c as child Case Trail_Start_Date__c value');
    }

    @isTest
    private static void update_CaseWith_SameTrialDates() {
        Case oldRecord = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType),
            RecordTypeId = TRIAL_PIPELINE_RT_Id,
            Opportunity__c = fflib_IDGenerator.generate(Opportunity.SObjectType),
            Trial_Start_Date__c  = TODAY_DATE,
            Trial_End_Date__c = TODAY_DATE
        );

        Case newRecord = oldRecord.clone(true /*clone Ids*/, false, false, false);
        TA_Case_UpdateOpportunityTrialDates caseTrialObj = new TA_Case_UpdateOpportunityTrialDates();

        Test.startTest();
            caseTrialObj.afterUpdate(new List<Case>{newRecord}, new List<Case>{oldRecord});
            Integer issuedSOQL = Limits.getQueries();
            Integer issuedDML = Limits.getDmlStatements();
        Test.stopTest();

         System.assertEquals(
            0,
            issuedSOQL,
            'The system should not perform SOQL updates to Parent Opportunities when Case updated records have same Trial Start and End dates as inserted cases');

        System.assertEquals(
            0,
            issuedDML,
            'The system should not perform DML updates to Parent Opportunities when Case updated records have same Trial Start and End dates as inserted cases');
    }

    @isTest
    private static void update_NoTrialCaseWith_DifferentTrialDates() {
        Case oldRecord = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType),
            RecordTypeId = notTrailCaseRtId,
            Opportunity__c = fflib_IDGenerator.generate(Opportunity.SObjectType),
            Trial_Start_Date__c  = TODAY_DATE,
            Trial_End_Date__c = TODAY_DATE
        );

        Case newRecord = oldRecord.clone(true /*clone Ids*/, false, false, false);
        newRecord.Trial_Start_Date__c = System.today().addDays(-1);

        TA_Case_UpdateOpportunityTrialDates caseTrialObj = new TA_Case_UpdateOpportunityTrialDates();

        Test.startTest();
            caseTrialObj.afterUpdate(new List<Case>{newRecord}, new List<Case>{oldRecord});
            Integer issuedSOQL = Limits.getQueries();
            Integer issuedDML = Limits.getDmlStatements();
        Test.stopTest();

         System.assertEquals(
            0,
            issuedSOQL,
            'when Case record type is not "Trial_Pipeline" and Trial_Start_Date changes, The system should not perform SOQL updates to Parent Opportunities ');

        System.assertEquals(
            0,
            issuedDML,
            'when Case record type is not "Trial_Pipeline" and Trial_Start_Date changes, The system should not perform DML updates to Parent Opportunities');
    }
}