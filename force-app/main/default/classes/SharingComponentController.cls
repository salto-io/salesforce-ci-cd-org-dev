public with sharing class SharingComponentController {

    /**
     *  Constructor.
     *  This is a lightning component controller it should never be instantiated
     */
    private SharingComponentController() {

    }

    /**
     * Checks if the user can edit the record
     *
     * @param recordId the Id of the record we are checking
     */
    private static boolean hasEdit(final Id recordId) {
        try {
            String query = 'SELECT OwnerId FROM ';
            query += objectTypeFromId(recordId) + ' WHERE Id = \'';
            query += String.escapeSingleQuotes(String.valueOf(recordId)) + '\'';

            SObject o = Database.query(query);

            if (o.get('OwnerId') == UserInfo.getUserId()) {
                return true;
            }

            //if user has modify all data allow them to take action
            List<PermissionSetAssignment> modifiers = [SELECT AssigneeId
                                                       FROM PermissionSetAssignment
                                                       WHERE PermissionSet.PermissionsModifyAllData = true
                                                       AND AssigneeId = :UserInfo.getUserId()];
            if (!modifiers.isEmpty()) {
                return true;
            }
        } catch (System.QueryException e) {
            return false;
        }
        return false;
    }

    /**
     * Deletes share records
     *
     * @param userOrGroupId Id of the user or group the share refers to
     * @param recordId the Id of the record the share refers to
     */
    @AuraEnabled
    public static void deleteShare(final Id userOrGroupId, final Id recordId) {
        //check if you can delete share records
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);
        if (!describe.isDeletable() || !describe.isAccessible()) {
            throw new AuraHandledException('You don\'t have the proper permissions for this action');
        }

        String query = buildQuery(recordId);
        query += ' and UserOrGroupId =\''+ userOrGroupId +'\'';

        delete Database.query(query);
    }

    /**
     * Upserts permissions
     *
     * @param userOrGroupId the user or group to share to
     * @param recordId the record being shared
     * @param level the level of access to be granted
     */
    @AuraEnabled
    public static void upsertShare(final Id userOrGroupId, final Id recordId, String level){
        System.assert(userOrGroupId != null);
        System.assert(recordId != null);
        System.assert(String.isNotBlank(level));


        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);
        level = String.escapeSingleQuotes(level);

        if (!hasEdit(recordId)) {
            throw new AuraHandledException('Only the record owner or administrators can modify permissions');
        }

        String query = buildQuery(recordId);
        query = query + ' and UserOrGroupId = \'' + String.escapeSingleQuotes(String.valueOf(userOrGroupId)) + '\'';

        List<SObject> existing = Database.query(query);

        final String sobj = objectTypeFromId(recordId);
        final String accessLevelField = getAccessLevelField(sobj);
        if (!existing.isEmpty()) {
            existing[0].put(accessLevelField, level);
            update existing;
        } else {
            //dynamically finds the share of the record
            Schema.SObjectType newObj = Schema.getGlobalDescribe().get(getSharingTableName(sobj));
            SObject share = newObj.newSObject();

            try {
                if (sobj == 'Account') {
                    share.put('CaseAccessLevel', level);
                    share.put('OpportunityAccessLevel', level);
                }
                share.put(accessLevelField, level);
                share.put(getLookupField(sobj), recordId);
                share.put('UserOrGroupId', userOrGroupId);
            } catch (SObjectException ex) {
                throw new AuraHandledException(ex.getMessage());
            }

            insert share;
        }
    }

    @TestVisible
    private static String getReturning(String objectType){
        //just a precaution
        objectType = String.escapeSingleQuotes(objectType);

        if (!User.Id.getDescribe().isAccessible() ||
                !User.Name.getDescribe().isAccessible() ||
                !Group.Id.getDescribe().isAccessible() ||
                !Group.Name.getDescribe().isAccessible())
        {
            throw new AuraHandledException('You do not have the required permissions for this action');
        }

        //filter out user types that don't have sharing!
        if (objectType == 'User') {
            return objectType + '(Id, Name, UserType WHERE UserType IN (\'Standard\', \'PowerCustomerSuccess\', ' +
                                '\'PowerPartner\'))';
        }
        if (objectType == 'Group') {
            return objectType + '(Id, Name, Type WHERE Type = \'Regular\')';
        } else {
            return objectType + '(Id, Name)';
        }
    }

    private static String objectTypeFromId(final Id recordId){
        Schema.SObjectType token = recordId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        return dr.getName();
    }

    /**
     * Gets all the current shares for the record given
     *
     * @param recordId The record who's shares we want
     */
    @AuraEnabled
    public static String getCurrentShares(final Id recordId) {
        if (!hasEdit(recordId)){
            throw new AuraHandledException('Only the record owner or administrators can access permissions');
        }

        List<SObject> results = Database.query(buildQuery(recordId));
        List<ShareWrapper> output = new List<ShareWrapper>();

        Set<Id> groupAndUserIDs = new Set<Id>();

        for (SObject so : results) {
            ShareWrapper sh = new ShareWrapper();
            sh.RowCause = String.valueOf(so.get('RowCause'));
            sh.AccessLevel = String.valueOf(so.get(getAccessLevelField(objectTypeFromId(recordId))));
            sh.UserOrGroupId = (Id)so.get('UserOrGroupId');
            groupAndUserIDs.add(sh.UserOrGroupId);
            output.add(sh);
        }

        Map<Id, User> userMap = new Map<Id, User>([SELECT Name FROM User WHERE Id IN :groupAndUserIDs]);
        Map<Id, Group> groupMap = new Map<Id, group>([SELECT Name FROM Group WHERE Id IN :groupAndUserIDs]);

        for (ShareWrapper sh : output) {
            if (userMap.get(sh.UserOrGroupId) != null) {
                sh.UserOrGroupType = 'User';
                sh.UserOrGroupName = userMap.get(sh.UserOrGroupId).Name;
            } else if (groupMap.get(sh.UserOrGroupID) != null){
                sh.UserOrGroupType = 'Group';
                sh.UserOrGroupName = groupMap.get(sh.UserOrGroupId).Name;
            }
        }

        /*
         * This is an ugly work around because the <aura:attribute/> tag does not handle
         * static nested inner classes well.
         */
        return JSON.serialize(output);
    }

    @TestVisible
    private static String buildQuery(final Id recordId) {
        String sobj = objectTypeFromId(recordId);
        Schema.DescribeSObjectResult describe = getSharingDescribe(recordId);

        final String accessLevelField = getAccessLevelField(sobj);
        final String lookupField = getLookupField(sobj);
        if (!describe.isAccessible() ||
                !describe.fields.getMap().get('Id').getDescribe().isAccessible() ||
                !describe.fields.getMap().get('RowCause').getDescribe().isAccessible() ||
                !describe.fields.getMap().get('UserOrGroupId').getDescribe().isAccessible() ||
                !describe.fields.getMap().get(accessLevelField).getDescribe().isAccessible() ||
                !describe.fields.getMap().get(lookupField).getDescribe().isAccessible())
        {
            throw new AuraHandledException('You don\'t have the required permissions for this action');
        }

        String query = 'SELECT Id, RowCause, UserOrGroupId, ' + accessLevelField;
        query += ' FROM ' + getSharingTableName(sobj) + ' WHERE ' + lookupField + ' = \'';
        query += String.escapeSingleQuotes(String.valueOf(recordId)) + '\'';
        return query;
    }

    /**
     * Wrapper class to display the current shares
     */
    private class ShareWrapper {
        private String UserOrGroupName;
        private String UserOrGroupType;
        private Id UserOrGroupId;
        private String AccessLevel;
        private String RowCause;

        private ShareWrapper() {

        }
    }

    @TestVisible
    private static boolean isStandard(final String sobj) {
        return !sobj.contains('__c');
    }

    @TestVisible
    private static String getLookupField(final String sobj) {
        if (isStandard(sobj)) {
            return sobj + 'Id';
        } else {
            return 'ParentId';
        }
    }

    @TestVisible
    private static String getAccessLevelField(final String sobj) {
        if (isStandard(sobj)){
            return sobj + 'AccessLevel';
        } else {
            return 'AccessLevel';
        }
    }

    @TestVisible
    private static String getSharingTableName(final String sobj) {
        if (isStandard(sobj)) {
            return sobj+'Share';
        } else {
            return sobj.replace('__c','__Share');
        }
    }

    @TestVisible
    private static Schema.DescribeSObjectResult getSharingDescribe(final Id recordId) {
        try {
            String sharingName = getSharingTableName(objectTypeFromId(recordId));
            return Schema.getGlobalDescribe().get(sharingName).getDescribe();
        } catch (Exception e) {
            throw new AuraHandledException('There is no sharing table for that object. ' +
                    'Are you SURE you changed the sharing setting to PRIVATE or READ?');
        }
    }
}