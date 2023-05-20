({
    //Function to toggle the record list drop-down
    toggleLookupList : function (component, ariaexpanded, classadd, classremove) {
        component.find("lookupdiv").set("v.aria-expanded", true);
        $A.util.addClass(component.find("lookupdiv"), classadd);
        $A.util.removeClass(component.find("lookupdiv"), classremove);
    },

    //function to call SOSL apex method.
    searchSOSLHelper : function (component,searchText) {
        //validate the input length. Must be greater then 3.
        //This check also manages the SOSL exception. Search text must be greater then 2.
        if(searchText && searchText.length > 3){
            //show the loading icon for search input field
            component.find("searchinput").set("v.isLoading", true);

            //server side callout. returns the list of record in JSON string
            var action = component.get("c.search");
            action.setParams({
                "objectAPIName": component.get("v.objectAPIName"),
                "searchText": searchText,
                "whereClause" : component.get("v.filter"),
                "extrafields":component.get("v.subHeadingFieldsAPI")
            });

            action.setCallback(this, function(a){
                var state = a.getState();

                if(component.isValid() && state === "SUCCESS") {
                    //parsing JSON return to Object[]
                    var result = [].concat.apply([], JSON.parse(a.getReturnValue()));
                    component.set("v.matchingRecords", result);
                    console.log( component.get("v.matchingRecords"));

                    //Visible the list if record list has values
                    if(a.getReturnValue() && a.getReturnValue().length > 0){
                        this.toggleLookupList(component,
                            true,
                            'slds-is-open',
                            'slds-combobox-lookup');

                        //hide the loading icon for search input field
                        component.find("searchinput").set("v.isLoading", false);
                    }else{
                        this.toggleLookupList(component, false,
                            'slds-combobox-lookup',
                            'slds-is-open');
                    }
                }else if(state === "ERROR") {
                    console.log('error in searchRecords');
                }
            });
            $A.enqueueAction(action);
        }else{
            //hide the drop down list if input length less then 3
            this.toggleLookupList(component,
                false,
                'slds-combobox-lookup',
                'slds-is-open'
            );
        }
    },

    //function to call SOQL apex method.
    searchSOQLHelper : function (component) {
        component.find("searchinput").set("v.isLoading", true);
        //var searchText = component.find("searchinput").get("v.value");

        var action = component.get("c.getRecentlyViewed");
        action.setParams({
            "objectAPIName": component.get("v.objectAPIName"),
            "whereClause" : component.get("v.filter"),
            "extrafields":component.get("v.subHeadingFieldsAPI")
        });

        //console.log(searchText);

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set("v.matchingRecords", response.getReturnValue());
                    console.log( component.get("v.matchingRecords"));
                    if(response.getReturnValue().length>0){
                        this.toggleLookupList(component,
                            true,
                            'slds-is-open',
                            'slds-combobox-lookup');
                    }
                    component.find("searchinput").set("v.isLoading", false);
                }
            } else {
                console.log('Error in loadRecentlyViewed: ' + state);
            }
        });
        $A.enqueueAction(action);
    }
})