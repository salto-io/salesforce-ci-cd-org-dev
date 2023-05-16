@IsTest
public class GDM_JSON_Test {
    static testMethod void testParse() {
		String json = '{'+
		'   \"destination_addresses\": ['+
		'      \"New York, NY, USA\"'+
		'   ],'+
		'   \"origin_addresses\": ['+
		'      \"Washington, DC, USA\"'+
		'   ],'+
		'   \"rows\": ['+
		'      {'+
		'         \"elements\": ['+
		'            {'+
		'               \"distance\": {'+
		'                  \"text\": \"362 km\",'+
		'                  \"value\": 361959'+
		'               },'+
		'               \"duration\": {'+
		'                  \"text\": \"3 hours 53 mins\",'+
		'                  \"value\": 13973'+
		'               },'+
		'               \"status\": \"OK\"'+
		'            }'+
		'         ]'+
		'      }'+
		'   ],'+
		'   \"status\": \"OK\"'+
		'}';
		GDM_JSON obj = GDM_JSON.parse(json);
		System.assert(obj != null);
	}
}