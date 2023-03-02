public class BatchLeadInactiveNotification implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, OwnerId, 
            (SELECT Id FROM Tasks WHERE LastModifiedDate = LAST_N_DAYS:20),
            (SELECT Id FROM OpenActivities WHERE LastModifiedDate = LAST_N_DAYS:20),
            (SELECT Id FROM ActivityHistories WHERE LastModifiedDate = LAST_N_DAYS:20)
            FROM Lead
            WHERE Status != 'Closed'
            AND IsConverted = false
            AND RecordType.DeveloperName = 'Standard_Lead'
            AND LastModifiedDate != LAST_N_DAYS:20
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        System.debug('BatchLeadInactiveNotification scope: ' + scope);
        
        CustomNotificationType noticeType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Lead_Inactive' LIMIT 1];
        
        for (Lead lead : scope) {
            if (lead.tasks.size() == 0 && lead.openActivities.size() == 0 && lead.ActivityHistories.size() == 0) {
                Messaging.CustomNotification notice = new Messaging.CustomNotification();
                
                // Notification click will be redirected to the targetId
                notice.setTargetId(lead.Id);
                notice.setTitle('Inactive Lead ' + lead.Name + ' Closer'); 
                notice.setBody('Lead is not active for the last 20 days, this lead will be closed after 10 days');
                notice.setNotificationTypeId(noticeType.Id);
                
                // Notification can be sent to User, Group or Queue member
                notice.send(new Set<String>{lead.OwnerId});
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
}