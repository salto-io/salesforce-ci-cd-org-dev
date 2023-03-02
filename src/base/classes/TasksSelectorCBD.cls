public inherited sharing class TasksSelectorCBD extends ApplicationSObjectSelector implements ITasksSelector {
    public static ITasksSelector newInstance() {
        return (ITasksSelector) Application.Selector.newInstance(Task.SObjectType);
    }

    public Schema.sObjectType getSObjectType() {
        return Task.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Task.Id,
            Task.Status,
            Task.WhoId,
            Task.WhatId,
            Task.Subject,
            Task.ActivityDate,
            Task.ReminderDateTime,
            Task.OwnerId
        };
    }

    @TestVisible
    private List<Schema.SObjectField> getAdditionalSObjectFieldList() {
        return new List<Schema.SObjectField>{};
    }

    public List<Task> selectById(Set<Id> idSet) {
        return (List<Task>) selectSObjectsById(idSet == null ? new Set<Id>() : idSet);
    }

    public List<Task> selectById(Set<Id> idSet, Set<String> additionalFields) {
        fflib_QueryFactory queryFactory = newQueryFactory()
            .setCondition('Id IN: idSet')
            .selectFields(additionalFields);
        return (List<Task>) Database.query(queryFactory.toSOQL());
    }
}