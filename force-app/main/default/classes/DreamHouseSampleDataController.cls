global with sharing class DreamHouseSampleDataController {

    @RemoteAction
    global static void deleteAll() {
        DELETE [SELECT ID FROM favorite__c];    
        DELETE [SELECT ID FROM property__c];    
        DELETE [SELECT ID FROM broker__c];
        DELETE [SELECT ID FROM LeadAssociation__c];
		DELETE [SELECT ID FROM Lead WHERE company='Dreamhouse'];
    }
}