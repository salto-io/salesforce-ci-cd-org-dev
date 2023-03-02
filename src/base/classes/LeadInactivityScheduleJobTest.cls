/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
@isTest
private class LeadInactivityScheduleJobTest {
    @testSetup
    static void setup() {
        list<Lead> testLead = new list<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        for(integer i = 0 ; i < 4 ; i++){
            Lead l = new Lead();
            l.firstName = 'TestFirst';
            l.LastName = 'Last' +string.valueOf(i);
            l.Email = 'test'+string.valueOf(i)+'@nomail.invalid';
            l.Company = 'Test Company'+string.valueOf(i);
            l.LeadSource = 'Partner';
            l.Customer_Segment__c = 'Individual';
            l.Product_Interest__c = 'Participate';
            l.RecordTypeId = recordTypeId;
            testLead.add(l);
        }
        insert testLead;
        //Test.loadData(Lead.sObjectType, 'InactiveLeadTest');
    }
    
    @isTest 
    static void verifyScheduleJob() {
        LeadInactivityScheduleJob schJob = new LeadInactivityScheduleJob(5);
        
        Test.startTest();
        System.schedule('Test_LeadInactivityScheduleJob', '0 0 * * * ?', schJob);
        Test.stopTest();
    }
    
    @isTest
    static void verifyInactiveLeadNotice() {
        Test.startTest();
        BatchLeadInactiveNotification inactiveNoticeJob = new BatchLeadInactiveNotification();
        Database.executeBatch(inactiveNoticeJob, 5);
        Test.stopTest();
    }
    
    @isTest
    static void verifyInactiveLeadClosing() {
        Test.startTest();
        BatchLeadInactiveClosing inactiveClosingJob = new BatchLeadInactiveClosing();
        Database.executeBatch(inactiveClosingJob, 5);
        Test.stopTest();
        
        Lead lead = [SELECT Id, Status, Lead_Close_Reason__c FROM Lead LIMIT 1];
        
        System.assertEquals('Open', lead.Status);
        System.assertEquals(null, lead.Lead_Close_Reason__c);
    }
}