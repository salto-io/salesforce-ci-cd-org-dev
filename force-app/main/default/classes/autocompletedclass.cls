public class autocompletedclass {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        List < sObject > searchList = new List < sObject > ();
         
        String sQuery =  'select id, Name from ' +ObjectName + ' ';  //SOQL query for fetching the records
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            searchList.add(obj);
        }
        return searchList;
    }
}