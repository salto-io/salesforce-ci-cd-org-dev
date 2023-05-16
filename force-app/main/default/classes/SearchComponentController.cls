public with sharing class SearchComponentController{
	
    @AuraEnabled(cacheable = true)
	public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value){
		List<SObJectResult> sObjectResultList = new List<SObJectResult>();

		if (String.isNotEmpty(value))
			for (sObject so : Database.Query('SELECT Id,' + fieldName + ' FROM ' + ObjectName + ' WHERE ' + fieldName + ' LIKE \'%' + value + '%\'')){
				String fieldvalue = (String)so.get(fieldName);
			sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
		}

		return sObjectResultList;
	}

	public class SObJectResult{
		@AuraEnabled
		public String recName;
		@AuraEnabled
		public Id recId;
		public SObJectResult(String recNameTemp, Id recIdTemp){
			recName = recNameTemp;
			recId = recIdTemp;
		}
	}
}