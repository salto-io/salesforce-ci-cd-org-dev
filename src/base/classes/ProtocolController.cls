public with sharing class ProtocolController {
    @AuraEnabled
    public static List<Protocol__c> getProtocolRecord() {
        return [Select Id, Name from Protocol__c];
    }
    
    @AuraEnabled
    public static List<Protocol_Interest__c> getSelectedProtocol(String leadId) {
        return [Select Id, Protocol__c from Protocol_Interest__c where Lead__c = :leadId];
    }
    
    @AuraEnabled
    public static void updateProtocol(List<String> protocolIds, String leadId) {
        System.debug('protocolIds are ' + protocolIds);
        
        Set<Id> existingProtocolInterestList = new Set<Id>();
        Set<Id> removeProtocolInterestSet = new Set<Id>();
        Set<Id> addProtocolInterestSet = new Set<Id>();
        for(Protocol_Interest__c protocolInterest : [Select Protocol__c from Protocol_Interest__c where Lead__c = :leadId]) {
            existingProtocolInterestList.add(protocolInterest.Protocol__c); 
        }
        
        removeProtocolInterestSet  = existingProtocolInterestList.clone();
        
        List<Protocol_Interest__c > protocolInterestList = new List<Protocol_Interest__c >();
        for(String protocol: protocolIds){
            addProtocolInterestSet.add(protocol);
            
            if(!existingProtocolInterestList.contains(protocol)){
                Protocol_Interest__c pc = new Protocol_Interest__c();
                pc.Lead__c = leadId;
                pc.Protocol__c  = protocol;
                protocolInterestList.add(pc);
            }
        }
        removeProtocolInterestSet.removeAll(addProtocolInterestSet);
        
        Delete [Select id from Protocol_Interest__c where Protocol__c IN: removeProtocolInterestSet and Lead__c = :leadId];
        insert protocolInterestList;
    }    
}