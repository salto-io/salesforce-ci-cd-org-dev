public without sharing class TA_Opportunity_CommerceCalculateAmount implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    public static final Decimal TRN_AMOUNT = .01;
    public static final Integer MONTHS_IN_YEAR = 12;
    public static Id commerceRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
        .get('Commerce')
        .getRecordTypeId();

    public void BeforeInsert(List<Opportunity> newList) {
        calculateAmountforCommerceOpportunity(newList, null);
    }

    public void BeforeUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>(oldList);
        calculateAmountforCommerceOpportunity(newList, oldMap);
    }

    public static void calculateAmountforCommerceOpportunity(
        List<Opportunity> oppList,
        Map<Id, Opportunity> oldMap
    ) {
        if (oldMap == null) {
            for (Opportunity opty : oppList) {
                if (Opty.RecordTypeId == commerceRecordTypeId) {
                    if (
                        (Opty.Average_Transaction_Amount__c != null) &&
                        (Opty.Number_of_Transactions_per_Month__c != null) &&
                        (opty.RecordTypeId == commerceRecordTypeId)
                    ) {
                        opty.Amount = Math.round(
                            (opty.Average_Transaction_Amount__c *
                            opty.Number_of_Transactions_per_Month__c *
                            TRN_AMOUNT *
                            MONTHS_IN_YEAR)
                        );
                    }
                }
            }
        } else {
            for (Opportunity opty : oppList) {
                if (Opty.RecordTypeId == commerceRecordTypeId) {
                    if (
                        (Opty.Average_Transaction_Amount__c != null) &&
                        (Opty.Number_of_Transactions_per_Month__c != null) ||
                        (opty.Average_Transaction_Amount__c !=
                        oldMap.get(Opty.Id).Average_Transaction_Amount__c &&
                        Opty.Number_of_Transactions_per_Month__c !=
                        oldMap.get(Opty.id).Number_of_Transactions_per_Month__c) &&
                        (Opty.Number_of_Transactions_per_Month__c !=
                        oldMap.get(Opty.id).Number_of_Transactions_per_Month__c ||
                        (opty.Average_Transaction_Amount__c !=
                        oldMap.get(Opty.Id).Average_Transaction_Amount__c))
                    ) {
                        opty.Amount = Math.round(
                            (opty.Average_Transaction_Amount__c *
                            opty.Number_of_Transactions_per_Month__c *
                            TRN_AMOUNT *
                            MONTHS_IN_YEAR)
                        );
                    }
                }
            }
        }
    }
}