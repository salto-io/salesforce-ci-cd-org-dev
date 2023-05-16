/*
 * @who		: Jorge Valdes <jorge.valdes@empaua.com>
 * @when	: 10 Jan 2019
 * @what	: Class with useful methods
 */

global class Empaua_Utils {

 /*
	* @method      : splitString
	* @description : Divide a String into substrings
	* @return      : List<List<String>> - List with a List with all substring obtained from the String
	* @params      : inputTextList - List with the Text to be splitted
	*/
	@InvocableMethod (label='Split Text')
	public static List<List<String>> splitString(List<String> inputTextList) {
		List<String> outputTextList = new List<String>();
    List<List<String>> outputTextListResult = new List<List<String>>();
		String regExp = ';';

		// Checks if the text IS NOT white space, empty or null
		if(inputTextList != null && !inputTextList.isEmpty() && !String.isBlank(inputTextList.get(0))){
			// Split the String by the regular expression
			outputTextList = inputTextList.get(0).split(regExp);
		}
    outputTextListResult.add(outputTextList);
		return outputTextListResult;
	}
}