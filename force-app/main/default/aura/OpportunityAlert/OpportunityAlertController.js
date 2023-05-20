({
    getOpps: function(cmp){
		var action = cmp.get("c.getOpportunities");
        action.setParams({
            daysSinceLastModified: cmp.get("v.daysSinceLastModified"),
            oppStage: cmp.get("v.oppStage"),
            hasTasks: cmp.get("v.hasTasks")
        });
        action.setCallback(this, function(response){
            console.debug(response);
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.opportunities", response.getReturnValue());
            } else {
                console.debug(response.error[0].message);
            }
        });
	 $A.enqueueAction(action);
    },
    
    gotoRecord : function(c,e,h) {
        var id;
        var element = e.srcElement; 
        while(element.parentNode) {
            if(element.id != "") {
                id = element.id;
                break;
            }
            element = element.parentNode;
        }
        if(id == null) { return; }
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": id,
            "slideDevName": 'detail'
        });
        sObjectEvent.fire();
    }
})