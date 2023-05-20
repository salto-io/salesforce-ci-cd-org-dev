public class ContactsTodayController {
    //test
    @AuraEnabled
    public static List<Contact> getContactsForToday() {
        List<Contact> important_contacts = new List<Contact>();
        List<Id> important_ids = new List<Id>();
        
        List<Task> my_tasks = [SELECT Id, Subject, WhoId from Task WHERE OwnerId = :UserInfo.getUserId() AND Status != 'Completed' AND WhoId != null];
        List<Event> my_events = [SELECT Id, Subject, WhoId from Event WHERE OwnerId = :UserInfo.getUserId() AND StartDateTime >= :Date.today() AND WhoId != null];
        List<Case> my_cases = [SELECT ID, ContactID, Status, Subject from Case where OwnerId = :UserInfo.getUserId() AND Status != 'Closed'];
        
        List<Id> taskContacts = new List<Id>();
        for(Task t : my_tasks) {
            taskContacts.add(t.WhoId);
        }
        List<Contact> task_contacts = [SELECT Id, Name, Phone, Description from Contact where ID IN: taskContacts];
        System.debug(task_contacts.size() + ' task contacts found');
        for(Contact c : task_contacts) {
            for(Task t : my_tasks) {
                if(t.WhoId == c.Id) {
                    c.Description = 'Because of Task "'+t.Subject+'"';
                    System.debug(c.Description);
                }
            }
        }
        important_contacts.addAll(task_contacts);

        List<Id> eventContacts = new List<Id>();
        for(Event e : my_events) {
            eventContacts.add(e.WhoId);
        }
        
        List<Contact> event_contacts = [SELECT Id, Name, Phone, Description from Contact where ID IN: eventContacts];
        System.debug(event_contacts.size() + ' event contacts found');
        for(Contact c : event_contacts) {
            for(Event e : my_events) {
                System.debug(e.WhoId +';;;'+ c.Id);
                if(e.WhoId == c.Id) {
                    c.Description = 'Because of Event "'+e.Subject+'"';
                    System.debug(c.Description);
                }
            }
        }
        important_contacts.addAll(event_contacts);
        
        List<Id> caseContacts = new List<Id>();
        for(Case c : my_cases) {
            caseContacts.add(c.ContactId);
        }
        
        List<Contact> case_contacts = [SELECT Id, Name, Phone, Description from Contact where ID IN: caseContacts];
        for(Contact c : case_contacts) {
            for(Case ca : my_cases) {
                if(ca.ContactId == c.Id) {
                    c.Description = 'Because of Case "'+ca.Subject+'"';
                    System.debug(c.Description);
                }
            }
        }
        important_contacts.addAll(case_contacts);
        
        return important_contacts;
    }
    

}