@isTest
public with sharing class TA_User_ValidateSystemAdminTest {
    @isTest
    private static void createInvalidAdmin() {
        List<User> newList = new List<User>();
        User userRecord = buildUser('Jack', 'Jackson', 'jackjackson@coinbase.com');
        userRecord.ProfileId = getProfileId('System Administrator');
        newList.add(userRecord);

        TA_User_ValidateSystemAdmin triggerObject = new TA_User_ValidateSystemAdmin();

        Test.startTest();
        triggerObject.BeforeInsert(newList);
        Test.stopTest();

        User validatedUser = newList[0];
        system.assert(validatedUser.getErrors().size() > 0);
    }

    @isTest
    private static void changeAdminUserProfile() {
        List<User> originalList = new List<User>();
        List<User> newList = new List<User>();
        User originalUser = buildUser('Jack', 'Jackson', SystemAdminsAllowed.TEST_ADMIN_USERNAME);
        User newUser = new User();

        originalUser.ProfileId = getProfileId('System Administrator');
        originalUser.Id = fflib_IDGenerator.generate(User.SObjectType);
        originalList.add(originalUser);
        newUser = originalUser.clone(true);
        newUser.ProfileId = fflib_IDGenerator.generate(Profile.SObjectType);
        newList.add(newUser);

        TA_User_ValidateSystemAdmin triggerObject = new TA_User_ValidateSystemAdmin();

        Test.startTest();
        triggerObject.BeforeUpdate(newList, originalList);
        Test.stopTest();

        User validatedUser = newList[0];
        system.assert(validatedUser.getErrors().size() > 0);
    }

    //Id = fflib_IDGenerator.generate(User.SObjectType),

    private static User buildUser(String firstName, String lastName, String userName) {
        User userRecord = new User();
        userRecord.FirstName = firstName;
        userRecord.LastName = lastName;
        userRecord.isActive = true;
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