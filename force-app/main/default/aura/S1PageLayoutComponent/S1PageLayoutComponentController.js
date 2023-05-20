({
    doInit: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var url = "/apex/S1PageLayout?id=" + component.get('v.recordId');
        try {
            urlEvent.setParams({
                "url": url
            });

            urlEvent.fire();
        } catch(e) {
            alert('Error is accessing key fields ', e);
        }

    }
})