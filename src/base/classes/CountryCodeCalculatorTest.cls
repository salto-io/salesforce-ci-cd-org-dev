@isTest
private class CountryCodeCalculatorTest {
    @isTest
    static void testValidCountryCode() {
        List<String> listOfCountryNames = new List<String>{ 'France;Canada', 'United States;Japan;Germany' };

        List<String> listOfCountryCodes = CountryCodeCalculator.calculateISOCodesForFlow(listOfCountryNames);
        
        String countryCodes = listOfCountryCodes[0];
        System.assert(countryCodes.contains('FR'), 'CountryCodes should include France');
        System.assert(countryCodes.contains('CA'), 'CountryCodes should include Canada');
        
        countryCodes = listOfCountryCodes[1];
        System.assert(countryCodes.contains('US'), 'CountryCodes should include United States');
        System.assert(countryCodes.contains('JP'), 'CountryCodes should include Japan');
        System.assert(countryCodes.contains('DE'), 'CountryCodes should include Germany');
    }

    @isTest
    static void testInvalidCountryCode() {
        List<String> listOfCountryNames = new List<String>{ 'BAD_VALUE_TEST;BAD_VALUE_TEST2' };

        List<String> listOfCountryCodes = CountryCodeCalculator.calculateISOCodesForFlow(listOfCountryNames);
       
        String countryCodes = listOfCountryCodes[0];
        System.assert(String.isBlank(countryCodes), 'CountryCodes should be blank for invalid values');
    }
    
    @isTest
    static void testRegionValue() {
        List<String> countryNamesCrossRegion = new List<String>{ 'France', 'Canada' };
        List<String> countryNamesAmer = new List<String>{ 'United States', 'Canada', 'Brazil' };
        List<String> countryNamesApac = new List<String>{ 'Japan', 'China', 'Korea, Republic of' };
        List<String> countryNamesInvalid = new List<String> { '', null, 'Bad Value' };
            
        String region = CountryCodeCalculator.getRegion(countryNamesCrossRegion);
        System.assertEquals('Global', region, 'Region should be Global for cross-region country names');
        
        region = CountryCodeCalculator.getRegion(countryNamesAmer);
        System.assertEquals('AMER', region, 'Region should be AMER for AMER country names');
        
        region = CountryCodeCalculator.getRegion(countryNamesApac);
        System.assertEquals('APAC', region, 'Region should be APAC for APAC country names');
        
        region = CountryCodeCalculator.getRegion(countryNamesInvalid);
        System.assertEquals(null, region, 'Region should be null for unmatched country names');
    }
}