public with sharing class OpportunityPathComponentController {
    @AuraEnabled
    public static opportunityWrapper getCoreSalesOpportunity(String accountId) {
        opportunityWrapper oppWrap = new opportunityWrapper();
        oppWrap.coreSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
            .get('Core Sales')
            .getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [
            SELECT id, Name, isClosed, Account.Name
            FROM Opportunity
            WHERE AccountId = :accountId AND Recordtype.developerName = 'Core_Sales'
            ORDER BY CloseDate DESC
            LIMIT 1
        ];
        oppWrap.opp = oppList.isEmpty() ? null : oppList[0];

        return oppWrap;
    }

    public class opportunityWrapper {
        @AuraEnabled
        public Opportunity opp { get; set; }
        @AuraEnabled
        public String coreSalesRecordTypeId { get; set; }
    }
}