({
    search: function(component, event, helper) {
    	const input = event.getSource();
    	const searchVal = input.get("v.value");

        if (searchVal.length > 2) {
            input.set("v.isLoading", true);
            const search = component.get("c.getRecords");
            search.setParams({
                types: component.get("v.objectTypes"),
                searchVal: searchVal
            });
            search.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS" && component.isValid()) {
                    component.set("v.results", response.getReturnValue());
                    input.set("v.isLoading", false);
                }
            });
            $A.enqueueAction(search);
        } else {
            component.set("v.results", []);
            input.set("v.isLoading", false);
        }
    },

    clear: function(component, event, helper) {
        component.set("v.selectedRecord", null);
        component.set("v.results", []);
    },

    select: function(component, event, helper) {
        const index = event.target.getAttribute("data-index");
        const results = component.get("v.results");
        component.set("v.selectedRecord", results[index]);
    }
})