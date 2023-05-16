public with sharing class GDM_Helper {

	public static final String STATUS_OK = 'OK';
    
    public static String encodeAddressObj(Address addressToEncode) {
		String encodedAddress = EncodingUtil.urlEncode(
			+ addressToEncode.getStreet() + ' '
			+ addressToEncode.getCity() + ', '
			+ addressToEncode.getState() + ' '
			+ addressToEncode.getPostalCode() + ' '
			+ addressToEncode.getCountry(),
			'UTF-8');
		return encodedAddress;
	}

    public static String encodeAddressStr(String street, String city, String state, String postalCode, String country) {
        String addressToEncode = '';
        if(!String.isBlank(street)){
            addressToEncode+= street + ', ';
        }
        if(!String.isBlank(city)){
            addressToEncode+= city + ', ';
        }
        if(!String.isBlank(state)){
            addressToEncode+= state + ' ';
        }
        if(!String.isBlank(postalCode)){
            addressToEncode+= postalCode + ' ';
        }
        if(!String.isBlank(country)){
            addressToEncode+= country;
        }
        System.debug('+++ addressToEncode: ' + addressToEncode);
		String encodedAddress = EncodingUtil.urlEncode(addressToEncode, 'UTF-8');
        System.debug('+++ encodedAddress: ' + encodedAddress);
		return encodedAddress;
	}

	
	public static List<GDM_Controller.GDM_Wrapper> createWrapperFromJSON(GDM_JSON responseObj) {
		GDM_Controller.GDM_Wrapper wrapper = new GDM_Controller.GDM_Wrapper();
		List<GDM_Controller.GDM_Wrapper> lstWrapper = new List<GDM_Controller.GDM_Wrapper>();

		if(responseObj.status == STATUS_OK ){
			for (GDM_JSON.Rows iRow : responseObj.rows) {
				wrapper = new GDM_Controller.GDM_Wrapper();
				for (GDM_JSON.Elements iElement : iRow.elements) {
					wrapper.distanceStr = iElement.distance.text;
					wrapper.distanceInt = iElement.distance.value;
					wrapper.durationStr = iElement.duration.text;
					wrapper.durationInt = iElement.duration.value;
					wrapper.status = responseObj.status;
				}
				lstWrapper.add(wrapper);
			}
		}     
        return lstWrapper;
	}
}