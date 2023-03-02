@isTest
private class ResetYtdRevenueScheduler_Test {

    private static final String CRON_EXP = '0 0 1 1 1 ? 2023-2040';
    
@isTest private static void test() {
   Test.startTest();

      //Account a = new Account();
      //a.Name = 'testScheduledApexFromTestMethod';
      //insert a;

      // Schedule the test job

      String jobId = System.schedule('Reset YTD Revenue Rollup', CRON_EXP, new ResetYtdRevenueScheduler());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
     // System.assertEquals('2042-09-03 00:00:00', 
        // String.valueOf(ct.NextFireTime));
     // System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
       //  [SELECT id, name FROM account WHERE id = :a.id].name);

   Test.stopTest();

  // System.assertEquals('testScheduledApexFromTestMethodUpdated',
   //[SELECT Id, Name FROM Account WHERE Id = :a.Id].Name);

   }
}