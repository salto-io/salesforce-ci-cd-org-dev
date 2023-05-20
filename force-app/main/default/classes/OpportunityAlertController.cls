public class OpportunityAlertController {

    @AuraEnabled
    public static List<Opportunity> getOpportunities(Decimal daysSinceLastModified, String oppStage, Boolean hasOpen) {
        Date t = Date.today();
        daysSinceLastModified *= -1;
        t.addDays((Integer)daysSinceLastModified);
        List<Opportunity> opportunities = 
                [SELECT Id, Name, StageName, LastModifiedDate, CloseDate FROM Opportunity WHERE StageName =: oppStage AND LastModifiedDate <= :t];
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>(opportunities);
       if(hasOpen == true) {
            List<Task> tasks = [SELECT ID, WhatId from TASK where Status != 'Closed' and WhatId IN: oppMap.keySet()];    
            List<Opportunity> opps_with_tasks = new List<Opportunity>();
            for(Task ta : tasks) {
                if(oppMap.containsKey(ta.WhatId)) {
                    opps_with_tasks.add(oppMap.get(ta.WhatId));
                }
            }
            opportunities = opps_with_tasks;
        } 
        return opportunities;
    }


    
}