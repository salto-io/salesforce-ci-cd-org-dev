/**
 * @description       : API Usage Monitor class
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 12-05-2022
 * @last modified by  : Lavanya Tangati
**/
public class APIUsageMonitor {
    private final static string API_Usage_Last_7_Days = 'API_Calls_Made_Within_Last_7_Days';
    @testvisible static Integer callCount = 0;
    Map<String, String> mapFromReportNameToId = new Map<String, String>();

    public APIUsageMonitor() {
        for(Report report : [SELECT Id, Name, DeveloperName,Format
                             FROM Report 
                             WHERE DeveloperName =: API_Usage_Last_7_Days]){
            mapFromReportNameToId.put(report.DeveloperName, report.Id);
        }
    }

    public void monitorWebToLeadIntegration(){
        callCount = getCallCount();
        Integer callOutThreshold =Integer.valueOf(Label.Call_Out_Threshold);
        if(
            (callCount < callOutThreshold && leadsCreatedYesterday < callOutThreshold)
            ||
            (callCount > callOutThreshold && leadsCreatedYesterday < callOutThreshold)
            || 
            Test.isRunningTest()
        ){
            createLogAndReport(callCount);
        }
        
    }

    private Integer getCallCount(){
        Integer callCount = 0;
        String yesterDayOfWeek = OrgUtil.yesterDayOfWeek();

        //Get APi Usage report result
        String apiUsageReportId = mapFromReportNameToId.get(API_Usage_Last_7_Days);
        Reports.reportResults apiUsageResults = Reports.ReportManager.runReport(apiUsageReportId, true);

        //Get Report Columns
        List<String> reportColumns =  apiUsageResults.getReportMetadata().getDetailColumns();

        // Get "Call Count" and "Day Of Week" Column Index
        Integer dayIndex = 0;
        Integer callCountIndex = 0;
        for (Integer i=0; i<reportColumns.size(); i++) {
            String colApi = reportColumns[i];
            String colName = apiUsageResults.getReportExtendedMetadata().getDetailColumnInfo().get(colApi).getLabel();
            switch on colName{
                when 'Day Of Week' {
                    dayIndex = i;
                }
                when 'Call Count'{
                    callCountIndex = i;
                }
            }
        }

        // Get the fact map from the report results
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)apiUsageResults.getFactMap().get('T!T');

        //create a list of report rows and populate it with the result rows from fact map
        List<Reports.ReportDetailRow> reportRows = factDetails.getRows();
        if(reportRows.size() > 0){
            //Get Call count from the Report for Yesterday
            for(Reports.ReportDetailRow reportRow : reportRows){
                List<Reports.ReportDataCell> datacells = reportRow.getDataCells();
                if(datacells[dayIndex].getLabel() == yesterDayOfWeek){
                    callCount = Integer.valueOf(datacells[callCountIndex].getLabel());
                    break;
                }
            }
        }
        System.debug('callCount: '+callCount);

        return callCount;
    }

    //Get Leads created Yesterday by WTL form
    private Integer leadsCreatedYesterday{
        get{
            if(leadsCreatedYesterday == null){
                leadsCreatedYesterday = [SELECT count()
                                        FROM Lead
                                        WHERE CreatedById =: Label.Lead_Integration_User_Id
                                        AND CreatedDate = Yesterday];
            }
            return leadsCreatedYesterday;
        }
        private set;
    }

    private void createLogAndReport(Integer callCount){
        Date yesterday = Date.today().addDays(-1);
        Datetime yesterdayDateTime = yesterday;

        Integration_Logs__c il =  new Integration_Logs__c();
        il.API_Call_Count__c = callCount;
        il.API_Type__c = 'SOAP';
        il.Event_Type__c = 'Api Total Usage';
        il.Integration_Type__c = 'Web To Lead';
        il.Integration_User__c = (Test.isRunningTest()) ? UserInfo.getUserId() : Label.Lead_Integration_User_Id;
        il.Log_Date__c = yesterday;
        insert il;

        if(il.Id != null){
            List<EventLogFile> logFile = [SELECT Id ,EventType,LogDate,LogFileLength, LogFile FROM EventLogFile WHERE EventType = 'ApiTotalUsage' AND LogDate =: yesterdayDateTime];
            if(!logFile.isEmpty()){
                Attachment att=new Attachment(Name='EventLogFile.csv');
                att.Body= logFile[0].LogFile;
                att.ParentId=il.id;
                insert att;
            }
        }
           
    }
}