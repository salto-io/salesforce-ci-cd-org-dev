({
    getProtocolRecord : function(component) {
        var action = component.get("c.getProtocolRecord"); 
        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i].Name,
                        value: result[i].Id
                    });
                }
                component.set("v.protocolList", plValues);
            }
        });
        
        $A.enqueueAction(action);
    },
    getSelectedProtocol : function(component) {
        var action = component.get("c.getSelectedProtocol");
        
        action.setParams({ 
            leadId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push(result[i].Protocol__c);
                }
                component.set("v.selectedPrtocolList", plValues);
            }
        });
        
        $A.enqueueAction(action);
    }
})