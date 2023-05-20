@IsTest
public class DreamhouseTests {
    
    static testmethod void testController() {
        DreamHouseSampleDataController.deleteAll();
        System.assertEquals(0, [select count() from favorite__c]);
        System.assertEquals(0, [select count() from favorite__c]);
        System.assertEquals(0, [select count() from property__c]);
        System.assertEquals(0, [select count() from broker__c]);
        System.assertEquals(0, [select count() from LeadAssociation__c]);
        System.assertEquals(0, [select count() from Lead WHERE company='Dreamhouse']);
    }
    
    static testmethod void testGetPropertiesApexController() {
        Property__c p1 = new Property__c(Name='Prop 1', Beds__c=2, Baths__c=2, Price__c=1000);
        Property__c p2 = new Property__c(Name='Prop 2', Beds__c=2, Baths__c=2, Price__c=2000);
        insert p1;
        insert p2;
        
        PageReference pref = Page.Similar_Properties;
        pref.getParameters().put('id',p1.id);
        Test.setCurrentPage(pref);
        
        ApexPages.StandardController con = new ApexPages.StandardController(p1);
        GetPropertiesApexController ext = new GetPropertiesApexController(con);
        System.assertEquals(1, ext.getProperties().size());
    }
    
    static testmethod void testDreamhouseProspects() {
        Lead l = new Lead(LastName='the Bear', Company='Dreamhouse');
        insert l;
        DreamhouseProspects dhp = new DreamhouseProspects();
        System.assertEquals(1, dhp.getLeads().size());
        dhp.sortList();
        dhp.sortOrder = 'LastName';
        System.assertEquals(1, dhp.getLeads().size());
        //List<Lead> leads = dhp.getLeads();
        
        
    }

}