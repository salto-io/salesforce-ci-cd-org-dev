@isTest
public class ContactsTodayController_test {

    @IsTest(SeeAllData=true)
    public static void TestContactsTodayController() {
        
        User u = [SELECT ID From User LIMIT 1];
        
        System.runAs(u) {
        
            Contact c = new Contact(FirstName = 'Joe', LastName = 'Test');
            insert c;
            
            Date td = Date.today();
            Task t = new Task(Subject = 'test', WhoId = c.Id, Status = 'Open');
            insert t;
            
            System.assertNotEquals(0,ContactsTodayController.getContactsForToday().size());
            
        }
        
    }
    
}