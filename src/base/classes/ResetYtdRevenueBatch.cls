/******************************************************************************************************************************
* @description    : This batch runs every year on January 1 to flip IsClosedDate_Current_Year__c to FALSE. 
					In the Parent Account record, it recalculates the roll up summary of CurrentYEAR Opportunities Amount
* @JIRA           : SFCC-1397
* @author         : Saurabh Sood
* @created        : 12/01/2022
* @test class     : ResetYtdRevenueBatch_Test

* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
******************************************************************************************************************************/
public class ResetYtdRevenueBatch implements Database.Batchable<sObject>, Database.Stateful  {
    private final String header = 'Record Id, Error Message \n';
    @testVisible private final static String NAMESPACE = 'YTDRevenueEmails';

    private String finalstr = header ;
    private final String QUERY;
   
	public ResetYtdRevenueBatch(String q){
		 QUERY = q; 
	}
    /**
     * Get emailAddresses from the keyvalue metadata 
     */
    @testVisible private static Map<String,String> emailAddresses {
        get {
            if(emailAddresses == null) {
                emailAddresses = new Map<String,String>();
                for(KeyValue__mdt mtd: [SELECT Key__c, Value__c 
                                        FROM KeyValue__mdt 
                                        WHERE Namespace__c =: NAMESPACE 
                                        AND IsActive__c = TRUE]) {
                  emailAddresses.put(mtd.Key__c, mtd.Value__c);  
                }
            }
            return emailAddresses;
        }
        private set;
    }
    
    /**
     * Get orgWideFromEmailId based on fromEmailAddress from the keyvalue metadata 
     */
    @testVisible private static Id orgWideFromEmailId {
        get {
            if(orgWideFromEmailId == NULL && emailAddresses.get('fromAddress') != NULL) {
               orgWideFromEmailId = [SELECT Id 
                                     FROM OrgWideEmailAddress 
                                     WHERE Address =: emailAddresses.get('fromAddress')
                                    ]?.Id;            
            }
            return orgWideFromEmailId;
        }
        private set;
    }


    /**
    *   Returns a List of Opportunities whose IsClosedDate_Current_Year__c = TRUE and CloseDate is LAST_YEAR
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY); 
    }

	/**
     * Update Opportunity.IsClosedDate_Current_Year__c from TRUE to FALSE & store failed record with error message
     */
    public void execute(Database.BatchableContext bc, List<Opportunity> oppyList) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>(); 
        for(Opportunity opp: oppyList) {
           	opp.IsClosedDate_Current_Year__c = FALSE;
            opportunitiesToUpdate.add(opp);
        }

        List<Database.SaveResult> saveResultList  = Database.update(opportunitiesToUpdate,false);
        
        Integer recordId = 0;
        for (Database.SaveResult saveResult : saveResultList) {
            if (!saveResult.isSuccess()) {
                string recordErrorString = '"'+opportunitiesToUpdate[recordId].id+'","'+saveResult.getErrors()[0].getMessage()+'"\n';
       			finalstr += recordErrorString;
            }
            recordId++;
        }
    }
    public void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        email.setSubject('ResetYtdRevenueBatch Failed Opportunities');
        email.setOrgWideEmailAddressId(orgWideFromEmailId); 
        email.setToAddresses(new list<string>((List<String>)emailAddresses.get('toAddress').split(',')));
        email.setPlainTextBody('Hi Team,\nPlease review the attachment to see failed opportunity records!');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{getCsvAttachment(finalstr)});

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
    /**
     * Build Opportunity failed records as CSV attachment
     * @param failedRecords  List of failed records from the UPDATE Event
     * @return  CSV attachment file
     */
    private static Messaging.EmailFileAttachment getCsvAttachment(String failedRecords) {
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(failedRecords);
        csvAttachment.setFileName('FailedOpportunities.csv');
        csvAttachment.setBody(csvBlob);
        return csvAttachment;
    }
   
}