public class LeadInactivityScheduleJob implements Schedulable {
    private Integer batchSize;
    
    public LeadInactivityScheduleJob(Integer batchSize) {
        this.batchSize = batchSize;
    }
    
    public void execute(SchedulableContext sc) {
        BatchLeadInactiveNotification notificationJob = new BatchLeadInactiveNotification(); 
        Database.executeBatch(notificationJob, batchSize);
        
        BatchLeadInactiveClosing closingJob = new BatchLeadInactiveClosing(); 
        Database.executeBatch(closingJob, batchSize);
    }
}