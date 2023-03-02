/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
@isTest
class CoinMarketCapAPIIntegrationTest {

    @isTest
    static void validateRetrieveExternalIdsAndPrices(){
        Protocol__c prot1 = new Protocol__c();
        prot1.Name = 'Bitcoin';
        prot1.Symbol__c = 'BTC';
        prot1.CoinMarketCap_External_Id__c = '1';
        insert prot1;

        Protocol__c prot2 = new Protocol__c();
        prot2.Name = 'LitCoin';
        prot2.Symbol__c = 'LTC';
        insert prot2;

        
        Test.startTest();
            CoinMarketCapAPIIntegration.mapFromExternalIdToProtocol.put('BTC', prot1);
            CoinMarketCapAPIIntegration.mapFromSymbolToProtocol.put('LTC', prot2);
            CoinMarketCapAPIIntegration.doGetCalloutToCoinMarketCapAPI();

            Test.setMock(HttpCalloutMock.class, new CoinMarketCapAPIMock(200, 'GET_IDS'));
            CoinMarketCapAPIIntegration.retrieveExternalIds();

            Test.setMock(HttpCalloutMock.class, new CoinMarketCapAPIMock(200, 'GET_PRICES'));
            CoinMarketCapAPIIntegration.retrieveProtocolPrices();

        Test.stopTest();

        for(Protocol__c prot : [SELECT Id, CoinMarketCap_External_Id__c, Price__c, Symbol__c FROM Protocol__c WHERE Symbol__c = 'LTC']){
            System.assert(prot.Price__c != null);
            if(prot.Symbol__c == 'LTC'){
                System.assertEquals(prot.CoinMarketCap_External_Id__c, '2');
            }
        }
    }

    @isTest
    static void validateErrorResponses(){
        Protocol__c prot1 = new Protocol__c();
        prot1.Name = 'Invalid Protocol';
        prot1.Symbol__c = 'INVALID';
        insert prot1;

        Test.startTest();
            CoinMarketCapAPIIntegration.mapFromSymbolToProtocol.put('INVALID', prot1);
            
            Test.setMock(HttpCalloutMock.class, new CoinMarketCapAPIMock(400, 'CHECK_INVALID_SYMBOLS'));
            CoinMarketCapAPIIntegration.retrieveExternalIds();

            Test.setMock(HttpCalloutMock.class, new CoinMarketCapAPIMock(200, 'GET_PRICES'));
            CoinMarketCapAPIIntegration.retrieveProtocolPrices();
        Test.stopTest();

        Protocol__c prot = [SELECT Id, Error_Message_CoinMarketCapAPi__c, Price__c, Symbol__c FROM Protocol__c];
        System.assertEquals(prot.Error_Message_CoinMarketCapAPi__c, 'Invalid value for symbol: INVALID');
    }

    @isTest
    static void validateScheduler(){
        ScheduleCoinMarketCapAPI monitor = new ScheduleCoinMarketCapAPI();
        
        Test.startTest();
            System.schedule('Test_CoinMarketCapAPI', '0 0 * * * ?', monitor);
        Test.stopTest();
    }

    public class CoinMarketCapAPIMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseType;

        public CoinMarketCapAPIMock(Integer statusCode,String responseType) {
            this.statusCode = statusCode;
			this.responseType = responseType;
		}

        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(this.responseType == 'GET_IDS' && this.statusCode == 200){
                System.assertEquals(req.getEndpoint(), ('callout:CoinMarketCap_Api/v1/cryptocurrency/map?symbol=LTC'));
                res.setStatusCode(200);
                res.setBody('{"status":{"timestamp":"2022-12-19T05:00:44.964Z","error_code":0,"error_message":null,"elapsed":21,"credit_count":1,"notice":null},"data":[{"id":2,"name":"Litecoin","symbol":"LTC","slug":"litecoin","rank":15,"displayTV":1,"is_active":1,"first_historical_data":"2013-04-28T18:47:22.000Z","last_historical_data":"2022-12-19T04:59:00.000Z","platform":null}]}');
            }
            if(this.responseType == 'GET_PRICES' && this.statusCode == 200){
                res.setBody('{"status":{"timestamp":"2022-12-19T04:57:54.443Z","error_code":0,"error_message":null,"elapsed":127,"credit_count":1,"notice":null},"data":{"1":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":16735.66407573372}}}],"id":1,"name":"Bitcoin","symbol":"BTC"},"2":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":62.83395075792374}}}],"id":2,"name":"Litecoin","symbol":"LTC"}}}');
            }
            if(this.responseType == 'CHECK_INVALID_SYMBOLS' && this.statusCode == 400){
                res.setBody('{"status":{"timestamp":"2022-12-19T06:29:59.627Z","error_code":400,"error_message":"Invalid value for symbol: INVALID","elapsed":0,"credit_count":0,"notice":null}}');
            }
            
            return res;
        }
    }
}