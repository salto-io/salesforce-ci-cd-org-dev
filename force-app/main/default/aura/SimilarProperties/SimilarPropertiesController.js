({
    doInit : function(component, event, helper) {
        var action = component.get("c.findProperties");
        action.setParams({
            recordId: component.get("v.recordId"),
            priceRange: "100000"
        });
        action.setCallback(this, function(response){
            var similarProperties = response.getReturnValue();
            component.set("v.similarProperties", similarProperties);
        });
        $A.enqueueAction(action);
    }
})