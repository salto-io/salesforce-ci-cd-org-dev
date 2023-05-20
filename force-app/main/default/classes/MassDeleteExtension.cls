// Extension to delete all of the selected objects
public with sharing class MassDeleteExtension {

    ApexPages.StandardSetController setCon;
    public String error { get; set; }
    public PageReference originalUrl { get; set; }

    public MassDeleteExtension(ApexPages.StandardSetController controller) {
        setCon = controller;
    }

    public String getMySelectedSize() {
        return setCon.getSelected().size() + '';
    }
    
    public PageReference deleteRecords(){
        originalUrl = setCon.cancel();
        delete setCon.getSelected();
        return originalUrl;
    }

}