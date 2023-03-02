public without sharing class TA_BTProduct_CheckStandardProduct implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    
    private class userException extends Exception {}
    @TestVisible
    private PriceBook2 standardPriceBook = [SELECT Id FROM PriceBook2 WHERE Name = 'Standard Price Book' AND IsStandard = true AND IsActive = true LIMIT 1];
    @TestVisible
    private Product2 standardSalesProduct = [SELECT Id FROM Product2 WHERE Name = 'Standard Sale' AND IsActive = true LIMIT 1];
    @TestVisible
    private boolean recordUpdateFlag = true;

    public void AfterInsert(List<BT_Product__c> newList) {
        execute(newList);
    }

    public void AfterUpdate(List<BT_Product__c> newList, List<BT_Product__c> oldList) {
        if (recordUpdateFlag) {
            execute(newList);
        }
    }
    
    private void execute(List<BT_Product__c> newList) {
        Set<Id> recordsWithProduct = new Set<Id>();
        Set<Id> recordsWithNoPriceBook = new Set<Id>();
        Set<Id> recordsWithNoProduct = new Set<Id>();
        
        //qualify
		for (BT_Product__c bt : newList) {
            if (bt.Has_Standard_Product__c) {
                recordsWithProduct.add(bt.Id);
            } else if (bt.Opportunity__c != null && bt.Opportunity__r.PriceBook2Id == null){
                recordsWithNoPriceBook.add(bt.Id);
            } else {
                recordsWithNoProduct.add(bt.Id);
            }
        }

        if(!recordsWithProduct.isEmpty()){
            updateRelatedOpportunityProduct(recordsWithProduct);
        }
        if(!recordsWithNoPriceBook.isEmpty()){
            setPriceBookOnOpportunity(recordsWithNoPriceBook);
            createOpportunityProducts(recordsWithNoPriceBook);
            updateBTProductRecords(recordsWithNoPriceBook);
        }
        if(!recordsWithNoProduct.isEmpty()){
            createOpportunityProducts(recordsWithNoProduct);
            updateBTProductRecords(recordsWithNoProduct);
        }
    }
    
    private void updateRelatedOpportunityProduct(Set<Id> recordIds) {
        List<BT_Product__c> records = [SELECT Id, 
                                       Availability_Commitment__c, 
                                       Billing_Frequency__c, 
                                       Node__r.Node_Family__c, 
                                       Quantity__c, 
                                       Participatory_Fee__c, 
                                       Opportunity__r.CloseDate, 
                                       Node_Price__c, 
                                       Sub_Total__c, 
                                       (SELECT Availability_Commitment__c , 
                                        BT_Product__c, 
                                        Billing_Frequency__c, 
                                        Had_BT_Product__c, 
                                        Hosted_Service__c, 
                                        Node_Count__c, 
                                        Participatory_Fee__c, 
                                        Quantity, 
                                        ServiceDate, 
                                        Subscription_Fee__c, 
                                        UnitPrice 
                                        FROM Opportunity_Product__r) 
                                       FROM BT_Product__c 
                                       WHERE Id IN :recordIds];
        
        List<OpportunityLineItem> opportunityProductsToUpdate = new List<OpportunityLineItem>();
        
        if (!records.isEmpty()) {
            for (BT_Product__c r : records) {
                for (OpportunityLineItem oli : r.Opportunity_Product__r) {
                    oli.Availability_Commitment__c = r.Availability_Commitment__c;
                    oli.BT_Product__c = r.Id;
                    oli.Billing_Frequency__c = r.Billing_Frequency__c;
                    oli.Had_BT_Product__c = true;
                    oli.Hosted_Service__c = r.Node__r.Node_Family__c == 'Participation' ? 'Network Participation' : 'Enterprise Node';
                    oli.Node_Count__c = r.Quantity__c;
                    oli.Participatory_Fee__c = r.Participatory_Fee__c;
                    oli.Quantity = 1;
                    oli.ServiceDate = r.Opportunity__r.CloseDate;
                    oli.Subscription_Fee__c = r.Node_Price__c;
                    oli.UnitPrice = r.Sub_Total__c;
                    
                    opportunityProductsToUpdate.add(oli);
                }
            }
        }
        if (!opportunityProductsToUpdate.isEmpty()) {
            updateOpportunityLineItems(opportunityProductsToUpdate);
        }
    }
    
    private void setPriceBookOnOpportunity (Set<Id> recordIds) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Set<Id> opportunityIds = new Set<Id>();
        List<BT_Product__c> btRecords = [SELECT Id, Opportunity__c FROM BT_Product__c WHERE Id IN :recordIds];
        if (!btRecords.isEmpty()) {
            for (BT_Product__c r : btRecords) {
            	opportunityIds.add(r.Opportunity__c);
        	}
        }
        if (!opportunityIds.isEmpty()) {
            for (Opportunity o : [SELECT PriceBook2Id FROM Opportunity WHERE Id IN :opportunityIds]) {
                o.PriceBook2Id = standardPriceBook.Id;
                opportunitiesToUpdate.add(o);
            }
        }
        if (!opportunitiesToUpdate.isEmpty()) {
            updateOpportunities(opportunitiesToUpdate);
        }
    }
    
    private void createOpportunityProducts (Set<Id> recordIds) {
        List<BT_Product__c> records = [SELECT Opportunity__c,
                                       Id, 
                                       Availability_Commitment__c, 
                                       Billing_Frequency__c, 
                                       Node__r.Node_Family__c, 
                                       Quantity__c, 
                                       Participatory_Fee__c,
                                       Node__r.Protocol__r.Name,
                                       Node_Price__c, 
                                       Sub_Total__c
                                       FROM BT_Product__c 
                                       WHERE Id IN :recordIds];
        
        if (!records.isEmpty()) {
            List<OpportunityLineItem> opportunityProductsToInsert = new List<OpportunityLineItem>();
            for (BT_Product__c r : records) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = r.Opportunity__c;
                oli.Availability_Commitment__c = r.Availability_Commitment__c;
                oli.BT_Product__c = r.Id;
                oli.Billing_Frequency__c = r.Billing_Frequency__c;
                oli.Had_BT_Product__c = true;
                oli.Hosted_Service__c = r.Node__r.Node_Family__c == 'Participation' ? 'Network Participation' : 'Enterprise Node';
                oli.Node_Count__c = r.Quantity__c;
                oli.Participatory_Fee__c = r.Participatory_Fee__c;
                oli.Product2Id = standardSalesProduct.Id;
                oli.Protocol__c = r.Node__r.Protocol__r.Name;
                oli.Quantity = 1;
                oli.Subscription_Fee__c = r.Node_Price__c;
                oli.UnitPrice = r.Sub_Total__c;
                
                opportunityProductsToInsert.add(oli);
            }
            if (!opportunityProductsToInsert.isEmpty()) {
            	insertOpportunityLineItems(opportunityProductsToInsert);
        	}
        }
    }
    
    private void updateBTProductRecords (Set<Id> recordIds) {
        List<BT_Product__c> recordsToUpdate = new List<BT_Product__c>();
        for (BT_Product__c r : [SELECT Id, Has_Standard_Product__c FROM BT_Product__c WHERE Id IN :recordIds]) {
            r.Has_Standard_Product__c = true;
            recordsToUpdate.add(r);
        }
        if (!recordsToUpdate.isEmpty()) {
            recordUpdateFlag = false;
            updateBTProducts(recordsToUpdate);
        }
    }
    
    private void updateOpportunityLineItems(List<OpportunityLineItem> recordsToUpdate) {
        try {
            update recordsToUpdate;
        } catch(DMLException ex) {
            recordsToUpdate[0].addError(new userException(ex.getMessage()));
        }
    }
    
    private void insertOpportunityLineItems(List<OpportunityLineItem> recordsToInsert) {
        try {
            insert recordsToInsert;
        } catch(DMLException ex) {
            recordsToInsert[0].addError(new userException(ex.getMessage()));
        }
    }
    
    private void updateOpportunities(List<Opportunity> recordsToUpdate) {
        try {
            update recordsToUpdate;
        } catch(DMLException ex) {
            recordsToUpdate[0].addError(new userException(ex.getMessage()));
        }
    }
    
    private void updateBTProducts(List<BT_Product__c> recordsToUpdate) {
        try {
            update recordsToUpdate;
        } catch(DMLException ex) {
            recordsToUpdate[0].addError(new userException(ex.getMessage()));
        }
    }
}