/******************************************************************************************************************************
* @description    : Handler class migrated from "Onboarding Case Creation" PB to TAF framework, when oppy flipped to closed won 
					and met other criteria, system send custom notifcation or post a chatter feed on a record 
* @JIRA           : SFCC-1238
* @author         : Saurabh Sood
* @created        : 02/14/2023
* @test class     : TA_Opportunity_OnboardingCaseHandlerTest

* Modification Log :
* -----------------------------------------------------------------------------------------------------------------
* Developer                   Date(MM/DD/YYYY)       Description
******************************************************************************************************************************/
public without sharing class TA_Opportunity_OnboardingCaseHandler implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    @testVisible private static final String CLOSED_WON_STAGE = 'Closed Won';
    @testVisible private static final String NO_VALUE = 'No';
    @testVisible private static final String DELEGATION_PRODUCT_TYPE = 'Delegation';
    @testVisible private static final Map<Id, Schema.RecordTypeInfo> OPPY_RECORDTYPE_MAP = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
    @testVisible private static final Id WALLET_OPPY_RECORDTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        												.get('Wallet_Opportunity').getRecordTypeId();
        												
    
    @testVisible private static final Date TODAY_DATE = System.today();
    
    /* get queueId with DeveloperName = Onboarding_Queue */
    @testVisible private static Id onboardingQueueId {
        get {
            if(onboardingQueueId == NULL) {
                onboardingQueueId = [SELECT Id FROM Group WHERE DeveloperName = 'Onboarding_Queue' AND Type = 'Queue'].Id;
            }
            return onboardingQueueId;
        }
        set{}
        
    }
    
    /* get customNotificationId with DeveloperName = Onboarding_Notification */
    @testVisible private static Id onboardingNotificationId {
        get {
            if(onboardingNotificationId == NULL) {
                onboardingNotificationId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName='Onboarding_Notification'].Id;
            }
            return onboardingNotificationId;
        }
        set{}
        
    }
    
    /**
    * Before insert trigger event
    * @param newList   New Opportunity records on insert event
    */
    public void beforeInsert(List<Opportunity> newList) {
        onboardingHandler(newList);
    }
    
    /**
    * Before update trigger event 
    * @param newList   New Opportunity records on update event
    * @param oldList   Old Opportunity records on update event
    */
    public void beforeUpdate(List<Opportunity> newlist, List<Opportunity> oldList) {
        beforeUpdatehandler(newlist, new Map<Id, Opportunity>(oldList));
    }
    
  	/**
    * If an opportunity stage, date overrides, previously-required, onboarding_required
    * or product type changes, send a list to the onboarding handler.  
    * @param newList   New Opportunity records on update event
    * @param oldMap    Old Opportunity map on update event
    */
    private static void beforeUpdatehandler(List<Opportunity> newlist, Map<Id, Opportunity> oldMap) {
        List<Opportunity> updatedList = new List<Opportunity>();
        for(Opportunity oppy: newList) {
            Opportunity oldRecord = oldMap.get(oppy.Id);
            
            if(oppy.StageName != oldRecord.StageName || 
               oppy.Date_Override__c != oldRecord.Date_Override__c || 
               oppy.Previously_Closed__c != oldRecord.Previously_Closed__c ||
               oppy.Onboarding_Required__c != oldRecord.Onboarding_Required__c ||
               oppy.Product_Type__c != oldRecord.Product_Type__c) 
            {
            	updatedList.add(oppy);    
            }
        }
		onboardingHandler(updatedList);        
    }
    
    /**
    * If Opportunity Stage is Closed Won and Previously Closed is False, then check other criteria
    * such as Onboarding_Required or Product_Type or Date_Override. If any of these criteria is met,
    * it will send a custom notification or post a chatter message. 
    * @param newList   New Opportunity records or filtered records from beforeUpdatehandler
    */
    private static void onboardingHandler(List<Opportunity> newList) {
        List<ConnectApi.BatchInput> batchFeeds = new List<ConnectApi.BatchInput>();
        Set<Id> oppyIds = new Set<Id>();
        String delegationText = 'Delegation customer closed.';
        String onboardingText = 'Opportunity Closed Won. No onboarding required.';
        
        for(Opportunity oppy: newList) {
            if(oppy.StageName != 'Closed Won' || oppy.Previously_Closed__c != FALSE) {
               	continue;
            }
            if(oppy.Onboarding_Required__c == NO_VALUE) {
                   delegationText = setFeedMessage(delegationText, oppy);
                   batchFeeds.add(setChatterFeed(oppy.Id, delegationText));
               }
            else if(oppy.Product_Type__c == DELEGATION_PRODUCT_TYPE) {
                  onboardingText = setFeedMessage(onboardingText, oppy);
                  batchFeeds.add(setChatterFeed(oppy.Id, onboardingText));
               }
            else if(oppy.RecordTypeId != WALLET_OPPY_RECORDTYPE_ID && oppy.Date_Override__c == FALSE) {    
                   oppy.CloseDate = TODAY_DATE; 
                   oppyIds.add(oppy.Id);
            }
        }
        if(oppyIds.size() > 0) {
            sendCustomOnboardingNotifications(oppyIds);
        }
        if(batchFeeds.size() > 0 && !Test.isRunningTest()) {
             ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchFeeds);
        }   
    }

    /**
    * Update initial feed text with opportunity record dynamically
    * @param initialText   Stored message in delegationText or onboardingText variable
    * @param oppy    	   Opportunity record	
    */
    private static String setFeedMessage(String initialText, Opportunity oppy) {
        return initialText +='\n Amount: '+ oppy.Amount +'\n Pipeline: '+ OPPY_RECORDTYPE_MAP.get(oppy.RecordTypeId).getName();    
    }
    
    /**
    * Filtered Opportunity Ids to send a custom notification to each record
    * @param oppyIds   Set of filtered opportunity ids	
    */
    @testVisible
	private static void sendCustomOnboardingNotifications(Set<Id> oppyIds) {
        List<Opportunity> opportunities = [SELECT Id, Name, Account.Name FROM Opportunity WHERE Id IN: oppyIds];
        for(Opportunity oppy : opportunities) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(oppy.Account.Name + ' has a new onboarding!');
            notification.setBody('Check the onboarding pipeline for the '+ oppy.Account.Name 
                                 + ' onboarding related to the  '+ oppy.Name + ' opportunity');
            notification.setNotificationTypeId(onboardingNotificationId);
            notification.setTargetId(oppy.Id);
            notification.send(new Set<String>{onboardingQueueId});
        } 
    }
    
    /**
    * Opportunity Id and feed text to create a instance of post a message on a record
    * @param oppyId   		Opportunity Id
    * @param feedMessage  	updated feed text message to set a post feed body\
    * @return 				returns instance of post message 
    */
    private static ConnectApi.BatchInput setChatterFeed(Id oppyId, String feedMessage) {
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = oppyId;
        
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = feedMessage;

        body.messageSegments.add(textSegment);
        input.body = body;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
        return batchInput;
    }

}