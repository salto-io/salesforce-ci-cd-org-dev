({
    doInit: function (cmp, event, helper) {
        helper.getCoreSalesOpportunityHelper(cmp);
    },
    navigateToOpportunityDetail: function (cmp, event, helper) {
        helper.navigateToOpportunityDetailHelper(cmp);
    },
    createNewCoreSalesOpportunity: function (cmp, event, helper) {
        helper.createNewCoreSalesOpportunityHelper(cmp);
    },
    refreshView: function (cmp, event, helper) {
        helper.getCoreSalesOpportunityHelper(cmp);
    }
});