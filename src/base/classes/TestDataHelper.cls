/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : Lavanya Tangati
**/
@isTest
public class TestDataHelper {
    public static Id stdLeadRecTypeId {
        get {
            if (stdLeadRecTypeId == null) {
                stdLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Standard_Lead').getRecordTypeId();
            }
            
            return stdLeadRecTypeId;
        }
        private set;
    }
    
    public static Id algoOppRecTypeId {
        get {
            if (algoOppRecTypeId == null) {
                algoOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Algorand_Pipeline').getRecordTypeId();
            }
            
            return algoOppRecTypeId;
        }
        private set;
    }
    
    public static List<Lead> getStandardLeads(Integer size, Boolean isCreate) {
        List<Lead> leads = new List<Lead>();
        
        for (Integer i = 0; i < size; i++) {
            leads.add(new Lead(
                RecordTypeId = stdLeadRecTypeId,
                FirstName = 'First ' + i,
                LastName = 'Last ' + i,
                Company = 'New York Corp ' + i, 
                Description = 'Test Lead',
                Email = 'test.lead' + i + '@nomail.invalid',
                LeadSource = 'Partner',
                Customer_Segment__c = 'Individual',
                Product_Interest__c = 'Participate'
            ));
        }
        
        if (isCreate) {
            insert leads;
        }
        
        return leads;
    }
    
    public static List<Account> getAccounts(Integer size, Boolean isCreate) {
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 0; i < size; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Size__c = 'Small Cap (< $150M)',
                Ideal_Timezone__c = 'EST - Eastern Standard Time - GMT-5:00',
                Industry = 'Custodian',
                Customer_Tier__c = '1'
            ));
        }
        
        if (isCreate) {
            insert accounts;
        }
        
        return accounts;
    }
    
    public static List<Contact> getContacts(Id accountId, Integer size, Boolean isCreate) {
        List<Contact> contacts = new List<Contact>();
        
        for (Integer i = 0; i < size; i++) {
            contacts.add(new Contact(
                AccountId = accountId,
                FirstName = 'Test ' + i,
                LastName = 'Contact',
                Email = 'test.contact' + i + '@nomail.invalid',
                Phone = '6465551234'
            ));
        }
        
        if (isCreate) {
            insert contacts;
        }
        
        return contacts;
    }
    
    public static List<Opportunity> getOpportunities(Id accountId, Integer size, Boolean isCreate) {
        List<Opportunity> opps = new List<Opportunity>();
        
        for (Integer i = 0; i < size; i++) {
            opps.add(new Opportunity(
                RecordTypeId = algoOppRecTypeId,
                AccountId = accountId,
                Name = 'Test Oppty ' + i,
                CloseDate = System.today().addDays(30),
                StageName = 'Qualification'
            ));
        }
        
        if (isCreate) {
            insert opps;
        }
        
        return opps;
    }
    
    public static void setOpportunityFieldsForWon(List<Opportunity> opps, Id contactId) {
        for (Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
            opp.Product_Interest__c = 'Other (Unspecified)';
            opp.Ideal_Timezone__c = 'EST - Eastern Standard Time - GMT-5:00';
            opp.Primary_Contact__c = contactId;
            opp.Type = 'Upsell';
            opp.Onboarding_Required__c = 'No';
            opp.Other_Amount__c = 10000;
        }
    }

    public static List<Asset>  getAssets(Id accountId, Integer size, Boolean isCreate){
        List<Asset> assets = new List<Asset>();
        
        for (Integer i = 0; i < size; i++) {
            assets.add(new Asset(
                Name = 'Test Asset ' + i,
                Protocol__c = 'Bitcoin',
                Product_Type__c = 'Delegation',
                AccountId = accountId
            ));
        }
        
        if (isCreate) {
            insert assets;
        }
        
        return assets;
    }

    public static Bill__c  getBill(Id accountId, Boolean isCreate){
        Bill__c bill = new Bill__c(
            Name = 'Test Bill' ,
            Billing_Frequency__c = 'Weekly',
            Account__c = accountId
        );
        
        if (isCreate) {
            insert bill;
        }
        
        return bill;
    }

    public static User getUser( String p, Boolean isCreate ) {
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = UserInfo.getOrganizationId() + dateString + Integer.valueOf(math.rint(math.random()*1000000));
        Profile pr = [select id from profile where name = : p];

        User u = new User( 
                        alias = 'standt', email = uniqueName + '@test' + UserInfo.getOrganizationId() + '.com', 
                        emailencodingkey = 'UTF-8', country = 'US', firstName = 'firstname', lastname = 'lastname', 
                        languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pr.Id, 
                        timezonesidkey = 'America/Los_Angeles', username = uniqueName + '@test' + UserInfo.getOrganizationId() + '.com'
        );

        if(isCreate) 
            insert u;
            
        return u;
    }

    public static Task getTask(String parentId, Boolean isCreate){
       
        Task t = new Task(
            Subject = 'Call' ,
            Status = 'Open',
            WhatId = parentId,
            Priority='Normal'
        );
        
        if (isCreate) {
            insert t;
        }
        
        return t;
    }
}