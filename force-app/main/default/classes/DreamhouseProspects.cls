public with sharing class DreamhouseProspects {
    public String sortOrder {set; get;}
    
    public List<Lead> getLeads() {
        if (sortOrder == null) {
            sortOrder = 'LastName';
        }
        
        return Database.query('SELECT Description,Email,FirstName,Id,LastName,Phone FROM Lead WHERE Company=\'Dreamhouse\' ORDER BY '+sortOrder);
    }
    
    public pageReference sortList() {
        getLeads();
        return null;
    }
}