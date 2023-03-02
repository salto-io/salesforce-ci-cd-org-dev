@isTest
private class TA_Case_SetCaseType_Test {

    private static final Map<String, Schema.RecordTypeInfo> CASE_RT_MAP_BY_NAME = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    private static String caseRtDevName = 'Support_Pipeline';

    private static Id suppportRecordTypeId {
        get {
            if(suppportRecordTypeId == NULL) {
                Map<String, Schema.RecordTypeInfo> caseMapByRtDevName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
                for(String rtDeveloperName :caseMapByRtDevName.keySet()) {
                   Schema.RecordTypeInfo recordTypeInfo =  caseMapByRtDevName.get(rtDeveloperName);
                    if(recordTypeInfo.getDeveloperName() == 'Support_Pipeline') {
                        suppportRecordTypeId = recordTypeInfo.getRecordTypeId();
                        break;
                    }
                }
            }
            return suppportRecordTypeId;
        }
        set;
    }

    private static String anyCaseType {
        get {
            if(anyCaseType == NULL) {
                for(Schema.PicklistEntry picklistEntryObj : Case.Type.getDescribe().getPicklistValues()) {
                    if(picklistEntryObj.isActive()) {
                        anyCaseType = picklistEntryObj.getValue();
                        break;
                    }
                }
            }
            return anyCaseType;
        }
        set;
    }

    @isTest private static void testMetadataSuccess() {

      Test.startTest();
       Map<String, String> caseTypeByRecordTypeDevName = TA_Case_SetCaseType.typeByCaseRtDevName;
      Test.stopTest();

        System.assert(
            caseTypeByRecordTypeDevName.size() != 0,
            '"TA_Case_SetCaseType.typeByCaseRtDevName" map should have metadata records with "Set CaseType By RecordType" namespace'+
            ' to set case type based on recordType developerName');
    }

    @isTest private static void insert_CaseRecord() {
        Case record = new Case(RecordTypeId = suppportRecordTypeId, Type = NULL, Status = 'New', Origin= 'Internal');
       final String EXPECTED_CASE_TYPE = anyCaseType;
       final String EXPECTED_CASE_RT = caseRtDevName;

        TA_Case_SetCaseType.typeByCaseRtDevName= new Map<String, String>{EXPECTED_CASE_RT => EXPECTED_CASE_TYPE};

        Test.startTest();
            insert record;
        Test.stopTest();


        List<Case> queriedCases = [SELECT Id, RecordTypeId, Type  FROM Case];

        System.assertEquals(
            1,
            queriedCases.size(),
            'Since one case record created, Query should return only 1 record');

        System.assertEquals(
            suppportRecordTypeId,
            queriedCases[0].RecordTypeId,
            'It should be the same record type in the case record as in the test data');

        System.assertEquals(
            EXPECTED_CASE_TYPE,
            queriedCases[0].Type,
            'CaseType should be set based on caseTypeByRecordType mapped value');
    }

     @isTest private static void update_CaseRtNotChanged() {
        final String EXPECTED_CASE_TYPE = anyCaseType;
        Id fakeCaseId = fflib_IDGenerator.generate(Case.SObjectType);
        Case oldRecord = new Case(Id = fakeCaseId, RecordTypeId = suppportRecordTypeId, Type = anyCaseType);
           Case newRecord = oldRecord.clone(true/*clone ids*/, false, false, false);

        TA_Case_SetCaseType obj = new TA_Case_SetCaseType();
        Test.startTest();
             obj.beforeUpdate(new List<Case>{newRecord}, new List<Case>{oldRecord});
        Test.stopTest();

        System.assertEquals(
            oldRecord.RecordTypeId,
            newRecord.RecordTypeId,
            'It should be the same record type in the case record');

        System.assertEquals(
            EXPECTED_CASE_TYPE,
            newRecord.Type,
            'Since RT is not changed it should not update CaseType value');
    }

    @isTest private static void update_CaseRtChangedToNull() {
        final String EXPECTED_CASE_TYPE = anyCaseType;
        Id fakeCaseId = fflib_IDGenerator.generate(Case.SObjectType);
        Case oldRecord = new Case(Id = fakeCaseId, RecordTypeId = suppportRecordTypeId, Type = anyCaseType);
           Case newRecord = oldRecord.clone(true/*clone ids*/, false, false, false);
        newRecord.RecordTypeId = NULL;

        TA_Case_SetCaseType obj = new TA_Case_SetCaseType();
        Test.startTest();
             obj.beforeUpdate(new List<Case>{newRecord}, new List<Case>{oldRecord});
        Test.stopTest();

        System.assertNotEquals(
            oldRecord.RecordTypeId,
            newRecord.RecordTypeId,
            'In update Case RecordType changed to NULL, old recordtype & new recordtype value should not be the same');

        System.assertEquals(
            NULL,
            newRecord.Type,
            'Since CaseRT is changed to NULL, it should update CaseType value to "Blank"');
    }
}