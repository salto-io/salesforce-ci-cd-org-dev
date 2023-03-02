// Update Opportunity Node Subtotal
public with sharing class TA_BTProduct_NodeSubUpdate 
    implements TriggerAction.BeforeUpdate, TriggerAction.BeforeInsert 
{

    boolean hasSubtotal(BT_Product__c product) {
        return (
            product.Sub_Total_Formula__c > 0 &&
            product.Opportunity__r.Amount_Override__c == true &&
            product.Opportunity__r.StageName != 'Closed Won'
        );
    }

    void updateSubtotal(List<BT_Product__c> products) {
        for (BT_Product__c product : products) {
            if (hasSubTotal(product)) {
                product.Sub_Total__c = product.Sub_Total_Formula__c;
            }
        }
    }

    public void beforeUpdate(List<BT_Product__c> products, List<BT_Product__c> old) {
        updateSubtotal(products);
    }
    
    public void beforeInsert(List<BT_Product__c> products) {
        updateSubtotal(products);
    }
}