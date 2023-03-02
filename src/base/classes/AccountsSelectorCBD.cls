public inherited sharing class AccountsSelectorCBD extends ApplicationSObjectSelector implements IAccountsSelector {
    public static IAccountsSelector newInstance() {
        return (IAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
    }

    public Schema.sObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account.Id,
            Account.Name,
            Account.RecordTypeId,
            Account.Customer_Tier__c,
            Account.Country_Codes__c,
            Account.Number_Of_Assets__c,
            Account.Billing_Contact__c,
            Account.Region__c,
            Account.CS_Account_Status__c,
            Account.Organization_ID__c,
            Account.CS_Owner__c
        };
    }

    @TestVisible
    private List<Schema.SObjectField> getAdditionalSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }

    public List<Account> selectById(Set<Id> idSet) {
        return (List<Account>) selectSObjectsById(idSet == null ? new Set<Id>() : idSet);
    }

    public List<Account> selectByIdWithLimit(Set<Id> idSet, Integer queryLimit) {
        fflib_QueryFactory queryFactory = newQueryFactory()
            .setCondition('Id IN: idSet')
            .setLimit(queryLimit);
        return (List<Account>) Database.query(queryFactory.toSOQL());
    }

    public List<Account> selectByRecordTypeId(Set<Id> recordTypeIds) {
        fflib_QueryFactory queryFactory = newQueryFactory()
            .setCondition('RecordTypeId IN: recordTypeIds');
        return (List<Account>) Database.query(queryFactory.toSOQL());
    }

    public List<Account> selectByIdWithAssets(Set<Id> idSet, Set<String> assetFields) {
        fflib_QueryFactory queryFactory = newQueryFactory().setCondition('Id IN: idSet');
        queryFactory.subSelectQuery('Assets').selectFields(assetFields);
        return (List<Account>) Database.query(queryFactory.toSOQL());
    }

    public List<Account> selectByIdWithAccountContactRelations(
        Set<Id> idSet,
        Set<String> accountContactFields
    ) {
        fflib_QueryFactory queryFactory = newQueryFactory().setCondition('Id IN: idSet');
        queryFactory.subSelectQuery('AccountContactRelations').selectFields(accountContactFields);
        return (List<Account>) Database.query(queryFactory.toSOQL());
    }

    public String testing() {
        Set<String> assetFields = new Set<String>{ 'Id', 'Name' };
        Set<String> accountFields = new Set<String>{ 'CreatedById' };
        fflib_QueryFactory queryFactory = newQueryFactory()
            .setCondition('Id IN: idSet')
            .selectFields(accountFields);
        queryFactory.subSelectQuery('Assets').selectFields(assetFields);
        return queryFactory.toSOQL();
    }
}