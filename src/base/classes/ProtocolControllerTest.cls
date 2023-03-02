@isTest
private class ProtocolControllerTest {
    @testSetup
    static void setup() {
		TestDataHelper.getStandardLeads(1, true);
        
        Protocol__c protocol = new Protocol__c();
        protocol.name = 'test';
        insert protocol;
    }
    
    @isTest 
    static void testProtocolControllerMethods() {
        String leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        
        List<String> protocolIds = new List<String>();
        String protocolId = [SELECT Id FROM Protocol__c].Id;
        protocolIds.add(protocolId);
        
        Test.startTest();
        ProtocolController.getProtocolRecord();
        ProtocolController.getSelectedProtocol(leadId); 
        ProtocolController.updateProtocol(protocolIds, leadId);
        Test.stopTest();
        
        Protocol_Interest__c protocolInterest = [SELECT Protocol__c FROM Protocol_Interest__c];
        System.assertEquals(protocolId, protocolInterest.Protocol__c);
    }
    
    @isTest
    static void testAddingProtocols() {
        Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        
        Protocol__c testProtocol1 = new Protocol__c();
        testProtocol1.name = 'Test1';
        
        Protocol__c testProtocol2 = new Protocol__c();
        testProtocol2.name = 'Test2';
        
        Protocol__c testProtocol3 = new Protocol__c();
        testProtocol3.name = 'Test3';
        
        insert new List<Protocol__c>{testProtocol1, testProtocol2, testProtocol3};
        
        Test.startTest();
        List<String> protocolIds = new List<String>{testProtocol1.Id, testProtocol2.Id};
        ProtocolController.updateProtocol(protocolIds, leadId);
        
        protocolIds = new List<String>{testProtocol1.Id, testProtocol3.Id};
        ProtocolController.updateProtocol(protocolIds, leadId);
        Test.stopTest();
        
        List<Protocol_Interest__c> protocolInterests = [SELECT Protocol__c FROM Protocol_Interest__c WHERE Lead__c = :leadId];
        
        Set<Id> leadProtocolIds = new Set<Id>();
        for (Protocol_Interest__c pi : protocolInterests) {
            leadProtocolIds.add(pi.Protocol__c);
        }
        
        System.assert(leadProtocolIds.contains(testProtocol1.Id));
        System.assert(!leadProtocolIds.contains(testProtocol2.Id));
        System.assert(leadProtocolIds.contains(testProtocol3.Id));
    }
}