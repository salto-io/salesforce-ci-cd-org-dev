public class BatchLeadInactiveClosing implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id,
            (SELECT Id FROM Tasks WHERE LastModifiedDate = LAST_N_DAYS:30),
            (SELECT Id FROM OpenActivities WHERE LastModifiedDate = LAST_N_DAYS:30),
            (SELECT Id FROM ActivityHistories WHERE LastModifiedDate = LAST_N_DAYS:30)
            FROM Lead
            WHERE Status != 'Closed'
            AND IsConverted = false
            AND RecordType.DeveloperName IN ('Standard_Lead', 'Business_Development_Partnerships') 
            AND LastModifiedDate != LAST_N_DAYS:30
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        for (Lead lead : scope) {
            if (lead.Tasks.size() == 0 && lead.OpenActivities.size() == 0 && lead.ActivityHistories.size() == 0) {
                lead.Status = 'Closed';
                lead.Lead_Close_Reason__c = 'Inactive';
            }
        }
        Database.update(scope, false);
    
    }
    
    public void finish(Database.BatchableContext bc) {
    }
}