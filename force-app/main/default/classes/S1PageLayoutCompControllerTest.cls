@isTest
private class S1PageLayoutCompControllerTest {
	
	@isTest static void test_method_one() {
		S1PageLayoutCompController sc = new S1PageLayoutCompController();
		Account acc = new Account(name='test account');
        insert acc;
		sc.setRecordId(acc.id);
		Id tempId = sc.getRecordId();
		List<Schema.FieldSetMember> fsList = sc.getFields();
		SObject obj = sc.getObj();

		System.assert(acc.id!=null);
		//System.assert(fsList!=null);
	}
	
	
}