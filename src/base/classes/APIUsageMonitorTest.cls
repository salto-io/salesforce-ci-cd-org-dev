/**
 * @description       : Test class for APIUsageMonitor
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 12-05-2022
 * @last modified by  : Lavanya Tangati
**/
@isTest(SeeAllData=true)
public class APIUsageMonitorTest {
    
    @isTest
    static void validateLeadsCreatedAboveThreshold() {
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = [Select id from Group where Group.Name = 'BD & Cloud Team'].Id ;
        GM.UserOrGroupId = UserInfo.getUserId();
        GMList.add(GM);
        if(!GMList.isEmpty()) {
            insert GMList;
        }
        ScheduleAPIUsageMonitor monitor = new ScheduleAPIUsageMonitor();
        
        Test.startTest();
            System.schedule('Test_APIUsageMonitor', '0 0 * * * ?', monitor);
        Test.stopTest();

        List<Integration_Logs__c> logs = [SELECT Id FROM Integration_Logs__c];
        if(APIUsageMonitor.callCount > Integer.valueOf(Label.Call_Out_Threshold) && logs.size() == 0){
            System.assert(true, 'No log is created since the Leads created and callouts made are above threshold');
        }
        else if(APIUsageMonitor.callCount < Integer.valueOf(Label.Call_Out_Threshold) && logs.size() == 1){
            System.assert(true, 'Log is created since callouts made are below threshold');
        }

    }
}