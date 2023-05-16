({
	handleUploadFinished: function (component, event, helper) {
        // This will contain the List of File uploaded data and status
        var files = event.getParam("files");
        var documentId = files[0].documentId;
        helper.processFile(component, documentId);
    },

    processFileTest: function (component, event, helper) {
        var documentId = '0691t00000cq81DAAQ';
        helper.processFile(component, documentId);
    }
})