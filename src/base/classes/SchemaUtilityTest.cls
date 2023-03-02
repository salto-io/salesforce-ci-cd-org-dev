@isTest
public with sharing class SchemaUtilityTest {
	
	@isTest
	public static void testObjectReturn (){
		List<SchemaUtility.ObjectDefinition> objectDefinitions = SchemaUtility.buildObjectDefinitions();
		system.assert(objectDefinitions.size() > 0, 'No object definitions returned');
	}

	@isTest
	public static void testFieldDefinitions(){
		List<SchemaUtility.FieldDefinition> fieldDefinitions = SchemaUtility.buildFieldDefinitions('Account');
		system.assert(fieldDefinitions.size() > 0, 'No field definitions returned');
	}

	@isTest
	public static void testReturnFromPage(){
		String returnStr = SchemaUtility.getSchemaInformation(false, 'Asset');
		system.assert(returnStr.length() > 0, 'Problem with getSchemaInformation method');
	}


}