/*
 * @who		: Jorge Valdes <jorge.valdes@empaua.com>
 * @when	: 10 Jan 2019
 * @what	: Controller class for Google Geocoding API integration
 */
public class GGeo_Controller {

    /* private static final String KEY = 'AIzaSyD1H--in4WHyn7Yw2ayWenz8rp7lQrGxr8';

    public static String callGoogleGeocodingAPI(String origins, String destinations) {
		
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
    
    @AuraEnabled
    static public LocationWrapper getLocation(string inputAddress){
        //GmapAPI.newAccmethod('Madrid');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String address = inputAddress;
        address = EncodingUtil.urlEncode(address, 'UTF-8');
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false'+'&key=AIzaSyA29KQ0nksya2proY4UcTYeiI5B3_kEcEE');
        req.setMethod('GET');
        req.setTimeout(5000);
        try{
            // callout
            HttpResponse res = h.send(req);
            // parse coordinates from response
            System.debug(res.getBody());
            JSONParser parser = JSON.createParser(res.getBody());
            System.debug(parser);
            double lat = null;   
            double lon = null;
            while (parser.nextToken() != null ) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                    && (parser.getText() == 'location')){
                        parser.nextToken(); // object start
                        while (parser.nextToken() != JSONToken.END_OBJECT){
                            String txt = parser.getText();
                            parser.nextToken();
                            if (txt == 'lat'){  
                                lat = parser.getDoubleValue();          
                            }else if (txt == 'lng')
                                lon = parser.getDoubleValue();
                            if(lat!= null && lon != null) {
                                break;
                            }
                        }
                    }
                if(lat!= null && lon != null) {
                    break;
                }
            }
            // update coordinates if we get back
            system.debug(lat+' '+lon);
            return new LocationWrapper(lat,lon); 
        }
        catch (Exception e) {
            system.debug(e);
            return new LocationWrapper(0,0);
        }
    }
    public class LocationWrapper{
        @AuraEnabled
        public double lat{get;set;}
        @AuraEnabled
        public double lon{get;set;}
        LocationWrapper(double ilat,double iLong){
            lat = ilat;
            lon = iLong;
        }
    }
    @AuraEnabled(cacheable=true)
    static public  list<LocationWrapper2> addressAutocompleteCall(string inputAddress){
        system.debug(inputAddress);
        if(inputAddress.length() >= 8) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            String address = inputAddress;
            address = EncodingUtil.urlEncode(address, 'UTF-8');
            req.setEndpoint('https://maps.googleapis.com/maps/api/place/textsearch/json?query='+address+ '&key=AIzaSyA29KQ0nksya2proY4UcTYeiI5B3_kEcEE');
            req.setMethod('GET');
            req.setTimeout(5000);
            try{
                HttpResponse res = h.send(req);
                System.debug(res.getBody());
                GmapAPI.AutocompleteCallResponse responseStruct =  (GmapAPI.AutocompleteCallResponse)system.JSON.deserialize(res.getBody(), GmapAPI.AutocompleteCallResponse.class);
                system.debug(responseStruct.results.size());
                list<LocationWrapper2> resturnLLW = new list<LocationWrapper2>();
                if (responseStruct.status == 'OK' ) {
                    for (Results lResult : responseStruct.Results ){
                        resturnLLW.add(new LocationWrapper2(lResult.geometry.location.lat ,lResult.geometry.location.lng, lResult.formatted_address ));
                    }
                }
                return  resturnLLW; 
            }catch (Exception e) {
                system.debug(e);
                return null;
            }
        }
        return null;
    }
    public class LocationWrapper2{
        @AuraEnabled
        public string steet{get;set;} 
        @AuraEnabled
        public double lat{get;set;}
        @AuraEnabled
        public double lng{get;set;}
        LocationWrapper2(double ilat,double iLong, string iStreet){
            lat = ilat;
            lng = iLong;
            steet = iStreet;
        }
    }
    private class AutocompleteCallResponse {
        public List<Html_attributions> html_attributions;
        public String next_page_token;
        public List<Results> results;
        public String status;
    }
    private class Opening_hours {
        public Boolean open_now;
    }
    private class Viewport {
        public Location northeast;
        public Location southwest;
    }
    private class Html_attributions {
    }
    private class Location {
        public Double lat;
        public Double lng;
    }
    private class Geometry {
        public Location location;
        public Viewport viewport;
    }
    private class Plus_code {
        public String compound_code;
        public String global_code;
    }
    private class Photos {
        public Integer height;
        public List<String> html_attributions;
        public String photo_reference;
        public Integer width;
    }
    private class Results {
        public String business_status;
        public String formatted_address;
        public Geometry geometry;
        public String icon;
        public String id;
        public String name;
        public Opening_hours opening_hours;
        public String place_id;
        public Plus_code plus_code;
        public string rating;
        public String reference;
        public List<String> types;
        public string user_ratings_total;
        public List<Photos> photos;
        public Integer price_level;
    } */
}