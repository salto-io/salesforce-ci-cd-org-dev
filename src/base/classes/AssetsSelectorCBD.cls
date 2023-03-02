public inherited sharing class AssetsSelectorCBD extends ApplicationSObjectSelector implements IAssetsSelector {
    public static IAssetsSelector newInstance() {
        return (IAssetsSelector) Application.Selector.newInstance(Asset.SObjectType);
    }

    public Schema.sObjectType getSObjectType() {
        return Asset.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Asset.Id,
            Asset.Name,
            Asset.Status,
            Asset.Quantity,
            Asset.Bill__c,
            Asset.CS_Owner__c
        };
    }

    @TestVisible
    private List<Schema.SObjectField> getAdditionalSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }

    public List<Asset> selectById(Set<Id> idSet) {
        return (List<Asset>) selectSObjectsById(idSet == null ? new Set<Id>() : idSet);
    }

    public List<Account> selectByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory queryFactory = newQueryFactory()
            .setCondition('AccountId IN: accountIds ');
        return (List<Account>) Database.query(queryFactory.toSOQL());
    }
}