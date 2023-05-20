({
	getImportantContacts: function(cmp){
        var action = cmp.get("c.getContactsForToday");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.debug(response.getReturnValue().length);
                cmp.set("v.important_contacts", response.getReturnValue());
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