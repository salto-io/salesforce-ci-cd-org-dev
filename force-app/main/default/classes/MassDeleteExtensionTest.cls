// Tests for MassDeleteExtension
@isTest
private class MassDeleteExtensionTest {
    static testMethod void testDeleteRecords() {

        List<Lead> leads = new List<Lead>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leads);
        MassDeleteExtension extension = new MassDeleteExtension(sc);

        System.assertNotEquals(null, extension.deleteRecords());
    }

    static testMethod void testSelectedSize() {
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(LastName='test'));

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leads);
        sc.setSelected(leads);
        MassDeleteExtension extension = new MassDeleteExtension(sc);

        System.assertEquals('1', extension.getMySelectedSize());
    }
}