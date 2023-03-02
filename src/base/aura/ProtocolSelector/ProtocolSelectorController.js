({
    doInit : function(component, event, helper) {
        helper.getSelectedProtocol(component); 
        helper.getProtocolRecord(component); 
    },
    handleProtocolChange : function(component, event, helper) {
        var selectedValues = event.getParam("value");
        component.set("v.selectedPrtocolList", selectedValues);
    },
    cancelPopup : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    submitProtocol : function(component, event, helper) {
        var selectedValues = component.get("v.selectedPrtocolList");
        console.log('Selectd Values - ' + selectedValues);
        
        var action = component.get("c.updateProtocol");
        action.setParams({ 
            protocolIds : selectedValues,
            leadId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Protocol records are added to this lead"
                });
                toastEvent.fire();
                
                
                
                
                $A.get('e.force:refreshView').fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})