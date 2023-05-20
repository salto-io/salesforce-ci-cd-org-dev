({
    showHide : function(component) {
        var editForm = component.find("editForm");
        $A.util.toggleClass(editForm, "slds-hide");
        var viewForm = component.find("viewForm");
        $A.util.toggleClass(viewForm, "slds-hide");
    }
})