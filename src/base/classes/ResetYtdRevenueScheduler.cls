/******************************************************************************************************************************
* @description    : This scheduler runs the batch on every year January 1 at 1 am to reset YTD Revenue Rollup Summary  
					Amount on the Parent Account record
* @JIRA           : SFCC-1397
* @author         : Saurabh Sood
* @created        : 12/05/2022
* @test class     : ResetYtdRevenueScheduler_Test
* @schedule Job   : System.schedule('Reset YTD Revenue Rollup', '0 0 1 1 1 ? 2023-2040', new ResetYtdRevenueScheduler());


* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
******************************************************************************************************************************/
public class ResetYtdRevenueScheduler implements Schedulable {
 
    Public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ResetYtdRevenueBatch('SELECT Id, IsClosedDate_Current_Year__c FROM Opportunity '+
                                                                   'WHERE IsClosedDate_Current_Year__c = TRUE AND CloseDate = LAST_YEAR'));
    }
}