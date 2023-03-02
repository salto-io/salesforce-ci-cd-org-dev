@isTest
public with sharing class UserIntegrationTest {
    @isTest
    public static void testAdminCreation() {
        User userRecord = buildUser('John', 'Johnson', SystemAdminsAllowed.TEST_ADMIN_USERNAME);
        userRecord.ProfileId = getProfileId('System Administrator');
        insert userRecord;
    }

    private static User buildUser(String firstName, String lastName, String userName) {
        User userRecord = new User();
        userRecord.FirstName = firstName;
        userRecord.LastName = lastName;
        userRecord.email = firstName + lastName + '@coinbase.com';
        userRecord.UserName = userName;
        userRecord.Alias = firstName.subString(0, 2) + 'test';
        userRecord.TimeZoneSidKey = 'America/Los_Angeles';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.EmailEncodingKey = 'ISO-8859-1';
        userRecord.LanguageLocaleKey = 'en_US';
        return userRecord;
    }

    private static Id getProfileId(String profileName) {
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name = :profileName];
        return profileRecord.Id;
    }
}