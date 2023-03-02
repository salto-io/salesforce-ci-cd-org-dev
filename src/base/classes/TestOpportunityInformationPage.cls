@isTest
private class TestOpportunityInformationPage {

    static testmethod void TestOpportunityCreation() {
        OpportunityInformationPage oip = new OpportunityInformationPage();
        oip.Saveto();
    }
    /*@isTest static void TestOpportunityCreation() {
        OpportunityInformationPage oip = new OpportunityInformationPage();
        oip.Saveto();
    }*/
}