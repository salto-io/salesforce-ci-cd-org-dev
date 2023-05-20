public class CountryCodeHelper {
    public static string getCountryCode(String country) {
        Country_Code__mdt countryCode = Country_Code__mdt.getInstance(country);
        return countryCode.Country_Code__c;
    }
}