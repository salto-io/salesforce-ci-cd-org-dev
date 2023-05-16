/*
 * @who		: Jorge Valdes <jorge.valdes@empaua.com>
 * @when	: 10 Jan 2019
 * @what	: Controller class for Google Distance Matrix API integration
 */
public class GDM_Controller {

    private static final String KEY = 'AIzaSyD1H--in4WHyn7Yw2ayWenz8rp7lQrGxr8';

    /* Lightning Component Button Action */
	@AuraEnabled
    public static GDM_Wrapper calculateDistanceGoogle(String oaStreet, 
                                                        String oaCity, 
                                                        String oaState, 
                                                        String oaPostalCode, 
                                                        String oaCountry, 
                                                        String daStreet,
                                                        String daCity,
                                                        String daState,
                                                        String daPostalCode,
                                                        String daCountry) {
        // Check both addresses are not empty
        String originAdd_encoded = GDM_Helper.encodeAddressStr(oaStreet, oaCity, oaState, oaPostalCode, oaCountry);
        System.debug('+++ originAdd_encoded: ' + originAdd_encoded);

        String destinationAdd_encoded = GDM_Helper.encodeAddressStr(daStreet, daCity, daState, daPostalCode, daCountry);
        System.debug('+++ destinationAdd_encoded: ' + destinationAdd_encoded);

        // Call to Google Distance Matrix API
        String jsonResults = callGDM_API(originAdd_encoded, destinationAdd_encoded);
        System.debug('+++ jsonResults: ' + jsonResults);

        // Parse response into Apex Obj
        GDM_JSON apiResponse = GDM_JSON.parse(jsonResults);

        // Parse response into Wrapper Class and return it
        return GDM_Helper.createWrapperFromJSON(apiResponse).get(0);
    }
    

    public static List<GDM_Wrapper> calculateDistanceMultipleAddressGoogle(List<Address> lstOrigin, List<Address> lstDestination) {
        String strAddress_encoded;
        List<String> lstOriginStr = new List<String>();
        List<String> lstDestinationStr = new List<String>();

        // Check addresses are not empty
        if (!lstOrigin.isEmpty() && !lstDestination.isEmpty()) {
            for (Address iOriginAdd : lstOrigin) {
                strAddress_encoded = GDM_Helper.encodeAddressObj(iOriginAdd);
                lstOriginStr.add(strAddress_encoded);
            }

            for (Address iDestinationAdd : lstDestination) {
                strAddress_encoded = GDM_Helper.encodeAddressObj(iDestinationAdd);
                lstDestinationStr.add(strAddress_encoded);
            }
            
        }

        // Call to Google Distance Matrix API
        String jsonResults = callGDM_API(String.join(lstOriginStr,'|'), String.join(lstDestinationStr,'|'));
        System.debug('+++ jsonResults: ' + jsonResults);

        // Parse response into Apex Obj
        GDM_JSON apiResponse = GDM_JSON.parse(jsonResults);

        // Parse response into Wrapper Class and return it
        return GDM_Helper.createWrapperFromJSON(apiResponse);
	}


	public static String callGDM_API(String origins, String destinations) {
		
		HttpRequest req = new HttpRequest();
		Http http = new Http();
		
		req.setMethod('GET');
		
		String url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
			+ '?origins=' + origins
			+ '&destinations=' + destinations
			+ '&mode=driving'
			+ '&sensor=false'
			+ '&language=en'
			+ '&units=metric'
            + '&key=' + KEY;
			
        System.debug('+++ EndPoint: ' + url);
		req.setEndPoint(url);
		
		HTTPResponse resp = http.send(req);
		
		String jsonResults = resp.getBody();
		return jsonResults;
    }
    

    public class GDM_Wrapper {
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String durationStr {get;set;}
        @AuraEnabled public String distanceStr {get;set;}
        @AuraEnabled public Integer durationInt {get;set;}
        @AuraEnabled public Integer distanceInt {get;set;}
    }
}