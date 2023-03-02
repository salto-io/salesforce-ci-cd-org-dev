trigger BTProductTrigger on BT_Product__c(
    after insert,
    after update
) {
    new MetadataTriggerHandler().run();
}