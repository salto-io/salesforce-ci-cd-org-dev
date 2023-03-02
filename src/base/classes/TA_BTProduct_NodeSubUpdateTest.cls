@istest
public with sharing class TA_BTProduct_NodeSubUpdateTest {
    static final String ASSET = 'asset';
    static final String STAGE = 'stage';
    static final String ACCOUNT_OVERRIDE = 'override';

    static BT_Product__c getProduct(Map<String, Object> params) {
        return  (BT_Product__c) fflib_ApexMocksUtils.setReadOnlyFields(
            new BT_Product__c(
                Name = (string)params.get(ASSET),
                Account__c = fflib_IDGenerator.generate(Account.SObjecttype),
                Billing_Frequency__c = 'Monthly',
                Quantity__c = 1.0,
                Tokens_Staked__c = 5,
                Opportunity__r = new Opportunity(
                    Id = fflib_IDGenerator.generate(Opportunity.SObjecttype),
                    Name = params.get('asset') + ' Deal',
                    StageName = (string) params.get(STAGE),
                    CloseDate = System.today().addDays(30),
                    Amount_Override__c = (boolean) params.get(ACCOUNT_OVERRIDE)
                )
            ), 
            BT_Product__c.class,
            new Map<SObjectField, Object> {
                BT_Product__c.Sub_Total_Formula__c  => 10
            }
        );
    }

    static List<BT_Product__c> copy(List<BT_Product__c> source) {
        List<BT_Product__c> target = new List<BT_Product__c>();

        for (BT_Product__c product : source) {
            BT_Product__c element = product.clone();
            target.add(element);
        }

        return target;
    }

    @isTest
    static void verify() {

        // We're only setting up the fields and relationships 
        // we need for the unit test

        BT_Product__c dotLineItem = getProduct(new Map<String, Object> {
            ASSET => 'DOT',
            STAGE => 'Prospecting',
            ACCOUNT_OVERRIDE => true
        });

        BT_Product__c ethLineItem = getProduct(new Map<String, Object> {
            ASSET => 'ETH',
            STAGE => 'Prospecting',
            ACCOUNT_OVERRIDE => false
        });


        BT_Product__c xtzLineItem = getProduct(new Map<String, Object> {
            ASSET => 'XTZ',
            STAGE => 'Closed Won',
            ACCOUNT_OVERRIDE => true
        });
        
        List<BT_Product__c> products = new List<BT_Product__c> {
            dotLineItem, ethLineItem, xtzLineItem
        };

        TA_BTProduct_NodeSubUpdate action = new TA_BTProduct_NodeSubUpdate();
        action.beforeInsert(products);

        System.assertEquals(
            10, dotLineItem.Sub_Total__c, 
            'Product with greater than 0 subtotal not updated'
        );
        System.assertEquals(
            null, ethLineItem.Sub_Total__c, 
            'Product with account override not set updated'
        );
        System.assertEquals(
            null, xtzLineItem.Sub_Total__c, 
            'Totals for closed won opportunities should not be updated'
        );

        List<BT_Product__c> newProducts = copy(products);

        BT_Product__c newDotLineItem = (BT_Product__c) fflib_ApexMocksUtils.setReadOnlyFields(
            newProducts[0], BT_Product__c.class,
            new Map<SObjectField, Object> {
                BT_Product__c.Sub_Total_Formula__c  => 0
            }
        );

        BT_Product__c newEthLineItem = newProducts[1];
        newEthLineItem.Opportunity__r.Amount_Override__c = true;
        
        BT_Product__c newXtzLineItem = newProducts[2];
        newXtzLineItem.Opportunity__r.StageName = 'Prospecting';

        action.beforeUpdate(newProducts, products);

        System.assertEquals(
            10, newDotLineItem.Sub_Total__c, 
            'It should still be 10 because the formula value is 0'
        );
        System.assertEquals(
            10, newEthLineItem.Sub_Total__c, 
            'Should update now that Account Override is set to true'
        );
        System.assertEquals(
            10, newXtzLineItem.Sub_Total__c, 
            'Stage is back to prospecting (not a valid transition) by should be 10 now'
        );

    }
}