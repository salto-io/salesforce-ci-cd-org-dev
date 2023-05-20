@IsTest
public class OpportunityAlertController_test {

    testmethod public static void testOpportunityAlertController() {
        List<Opportunity> opps = OpportunityAlertController.getOpportunities(0, 'Prospecting', false);
        opps = OpportunityAlertController.getOpportunities(0, 'Prospecting', true);
        System.assertEquals(opps.size(),0);
    }
    
}