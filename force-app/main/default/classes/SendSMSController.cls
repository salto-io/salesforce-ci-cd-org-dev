public with sharing class SendSMSController {

    @AuraEnabled
    public static String sendSMS(String audience, String message){
        
        return 'success';
    }
}