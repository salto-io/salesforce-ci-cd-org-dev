/**
 * @description       : TAF trigger on the Opportunity sobject
 * @author            : Lavanya Tangati
 * @group             :
 * @last modified on  : 12-13-2022
 * @last modified by  : Peter Ogilvie 
 */
trigger OpportunityTrigger on Opportunity(before insert, after insert, before update, after update) {
     new MetadataTriggerHandler().run();
 }