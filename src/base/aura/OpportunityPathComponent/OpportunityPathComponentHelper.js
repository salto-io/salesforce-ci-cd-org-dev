({
    getCoreSalesOpportunityHelper: function (cmp) {
        cmp.set("v.loading", true);
        var action = cmp.get("c.getCoreSalesOpportunity");
        action.setParams({ accountId: cmp.get("v.recordId") });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.coreSalesOpportunity", result.opp);
                cmp.set("v.coreSalesRecordTypeId", result.coreSalesRecordTypeId);
                var noOppExist = $A.util.isUndefinedOrNull(result.opp);
                if (noOppExist === true) {
                    cmp.set("v.noCoreSalesOppExist", true);
                } else {
                    cmp.set("v.noCoreSalesOppExist", false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            cmp.set("v.loading", false);
        });
        $A.enqueueAction(action);
    },
    navigateToOpportunityDetailHelper: function (cmp, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: cmp.get("v.coreSalesOpportunity.Id"),
            slideDevName: "detail"
        });
        navEvt.fire();
    },
    createNewCoreSalesOpportunityHelper: function (cmp, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            entityApiName: "Opportunity",
            recordTypeId: cmp.get("v.coreSalesRecordTypeId"),
            defaultFieldValues: {
                AccountId: cmp.get("v.recordId"),
                Name: cmp.get("v.accountRecord.Name")
            }
        });
        createRecordEvent.fire();
    },
    refreshView: function (component, event, helper) {
        var action = cmp.get("c.myController");
        action.setCallback(cmp, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:refreshView").fire();
            } else {
                //do something
            }
        });
        $A.enqueueAction(action);
    }
});