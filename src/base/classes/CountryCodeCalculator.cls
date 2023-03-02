// This class intakes a list of semi-colon delimited country names and return their respective ISO Codes and Regions
public with sharing class CountryCodeCalculator {
    private static Map<String, CountryAndCode__mdt> countryMap {
        get {
            if (countryMap == null) {
                countryMap = new Map<String, CountryAndCode__mdt>();
                
                for (CountryAndCode__mdt countryMdt : CountryAndCode__mdt.getAll().values()) {
                    countryMap.put(countryMdt.Country__c, countryMdt);
                }
            }
            
            return countryMap;
        }
        set;
    }

	@InvocableMethod(label='Calculate Country Codes')
	public static List<String> calculateISOCodesForFlow(List<String> delimitedCountryNamesList) {
		List<String> countryCodesList = new List<String>();
        
		for(String delimitedCountryNames : delimitedCountryNamesList) {
            List<String> countryNames = delimitedCountryNames.split(';');
            
			countryCodesList.add(getCountryCodes(countryNames));
		}
        
		return countryCodesList;
	}

    @testVisible
    private static String getCountryCodes(List<String> countryNames) {
		List<String> countryCodes = new List<String>();

		for(String countryName : countryNames) {
            String countryCode = countryMap.get(countryName)?.CountryCode__c;
			
            if (String.isNotEmpty(countryCode)) {
                countryCodes.add(countryCode);
            }
		}
        
		return String.join(countryCodes, ';');
    }
    
    @testVisible
    private static String getRegion(List<String> countryNames) {
        Set<String> regions = new Set<String>();
        
        for(String countryName : countryNames) {
            String countryRegion = countryMap.get(countryName)?.Region__c;
            
            if (String.isNotEmpty(countryRegion)) {
                regions.add(countryRegion); 
            }
        }
        
        if (regions.size() > 1) {
            return 'Global';
        } else if (regions.size() == 1) {
             return regions.iterator().next();
        } else {
            return null;
        }
    }
    
    // SObject (Lead, Account, Opportunity) need to have Countries_of_Incorporation__c, Country_Codes__c, Region__c fields
    public static void setCountryCodesAndRegion(SObject record) {
        List<String> countryNames = ((String) record.get('Countries_of_Incorporation__c')).split(';');

        record.put('Country_Codes__c', getCountryCodes(countryNames));
        record.put('Region__c', getRegion(countryNames));
    }
}