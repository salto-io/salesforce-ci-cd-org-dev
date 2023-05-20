({
    //Function to handle the LookupChooseEvent. Sets the chosen record Id and Name
    handleLookupChooseEvent : function (component,event,helper) {
        component.set("v.chosenRecordId", event.getParam("recordId"));
        component.set("v.chosenRecordLabel",event.getParam("recordLabel"));
        helper.toggleLookupList(component,
            false,
            'slds-combobox-lookup',
            'slds-is-open');
    },

    //Function for finding the records as for given search input
    searchRecords : function (component,event,helper) {
        var searchText = component.find("searchinput").get("v.value");

        if(searchText){
            helper.searchSOSLHelper(component,searchText);
        }else{
            helper.searchSOQLHelper(component);
        }
    },

    //function to hide the list on onblur event.
    hideList :function (component,event,helper) {
        //Using timeout and $A.getCallback() to avoid conflict between LookupChooseEvent and onblur
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    helper.toggleLookupList(component,
                        false,
                        'slds-combobox-lookup',
                        'slds-is-open'
                    );
                }
            }), 200
        );
    }
})