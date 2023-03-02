public class OpportunityInformationPage {
    public opportunity oppstring{get; set;}
    public OpportunityInformationPage(){
        oppstring= new opportunity();
    }
    public void Saveto(){
        opportunity opp= new opportunity();
        opp.AccountId= oppstring.AccountId;
        opp.Amount= oppstring.Amount;
        opp.CloseDate= oppstring.CloseDate;
        opp.Name= oppstring.Name;

        opp.StageName= oppstring.StageName;
        
        opp.LeadSource= oppstring.LeadSource;
        
        opp.OwnerId= oppstring.OwnerId;
        
        opp.Type= oppstring.Type;
        
        opp.Probability= oppstring.Probability;
        
        opp.Product_Type__c= oppstring.Product_Type__c;
        
        opp.Primary_Contact__c= oppstring.Primary_Contact__c;
        
        opp.RecordTypeId = oppstring.RecordTypeId;
        
        opp.Estimated_Value__c = oppstring.Estimated_Value__c;
        
        try {
            insert opp;
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.severity.CONFIRM,
                'Record successfully saved'
            ));
            oppstring.Name = null;oppstring.AccountId = null;oppstring.Amount = null;oppstring.CloseDate = null;oppstring.StageName = null;oppstring.LeadSource = null;oppstring.OwnerId = null;oppstring.Type = null;oppstring.Probability = null;oppstring.Product_Type__c = null;oppstring.RecordTypeId = null;oppstring.Estimated_Value__c = null;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.severity.FATAL,
                ex.getMessage()
            ));
        }
    }

}