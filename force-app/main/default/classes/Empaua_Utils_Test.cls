/*
 * @who		: Jorge Valdes <jorge.valdes@empaua.com>
 * @when	: 10 Jan 2019
 * @what	: Contains test methods for Empaua_Utils class
 */

@isTest
private class Empaua_Utils_Test {

	@isTest static void test_splitString_method() {
		String textToSplit = 'value1;value2;value3';
		List<String> listWithText = new List<String>();
		listWithText.add(textToSplit);

		Test.startTest();
		List<List<String>> splitedList = Empaua_Utils.splitString(listWithText);
		System.assertEquals('value1',splitedList.get(0).get(0));
		Test.stopTest();
	}


}