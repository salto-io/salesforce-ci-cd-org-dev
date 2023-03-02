/**
 * @description       : Scheudle job to monitor API usage
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 08-26-2022
 * @last modified by  : Lavanya Tangati
**/
public class ScheduleAPIUsageMonitor implements Schedulable {
    public void execute(SchedulableContext sc) {
        APIUsageMonitor apiMonitor =  new APIUsageMonitor();
        apiMonitor.monitorWebToLeadIntegration();
    }
}