/**
 * @description       : A solution that utilizes the CoinMarketCap API to update the protocol prices in Salesforce.  
 * This is a GET call that returns back the current prices for the protocols. 
 * Once Salesforce receives the response back from the CoinMarketCap API, the apex code will update the prices on the related protocols.
 * https://docs.google.com/document/d/1K4QR7JtpvxlL1tbhxLICwnr-ba2jvICDDN2Q2WWLMK0/edit#heading=h.q2ejpi7m18rn
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Lavanya Tangati
**/
public class CoinMarketCapAPIIntegration {
    @testvisible static Map<String, Protocol__c> mapFromExternalIdToProtocol =  new Map<String, Protocol__c>();
    @testvisible static Map<String, Protocol__c> mapFromSymbolToProtocol =  new Map<String, Protocol__c>();
    static Map<Id, Protocol__c> updateProtocols =  new Map<Id,Protocol__c>();
    static List<Integration_Logs__c> iLogs = new List<Integration_Logs__c>();

    @future(callout=true)
    public static void doGetCalloutToCoinMarketCapAPI(){
        for(Protocol__c prot : [SELECT Price__c, CoinMarketCap_External_Id__c, Symbol__c 
                                FROM Protocol__c 
                                WHERE Symbol__c != null]){

            if(!String.ISBLANK(prot.CoinMarketCap_External_Id__c)){
                mapFromExternalIdToProtocol.put(prot.CoinMarketCap_External_Id__c, prot);
            }else{
                mapFromSymbolToProtocol.put(prot.Symbol__c.toUpperCase(), prot);
            }
        }

        if(!Test.isRunningTest()){
            //first retrieve the missing external ids through callout
            retrieveExternalIds();
            // next retrieve the prices
            retrieveProtocolPrices();
        }

        //insert Integrations logs
        if(!iLogs.isEmpty()){
            insert iLogs;
        }
    }

    @testvisible
    private static void retrieveExternalIds(){
        if(!mapFromSymbolToProtocol.isEmpty()){
            List<String> coinMarketCapSymbols = new List<String>(mapFromSymbolToProtocol.keySet());

            String endpoint = 'callout:CoinMarketCap_Api/v1/cryptocurrency/map';
            endpoint += '?symbol='+String.join(coinMarketCapSymbols, ',');

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(endpoint);
            req.setHeader('X-CMC_PRO_API_KEY', '{!$Credential.Password}');
            HttpResponse res = new Http().send(req); //{"status":{"timestamp":"2022-12-19T05:00:44.964Z","error_code":0,"error_message":null,"elapsed":21,"credit_count":1,"notice":null},"data":[{"id":2,"name":"Litecoin","symbol":"LTC","slug":"litecoin","rank":15,"displayTV":1,"is_active":1,"first_historical_data":"2013-04-28T18:47:22.000Z","last_historical_data":"2022-12-19T04:59:00.000Z","platform":null}]}
            if(res != null){
                Map<String, Object> jsonBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                Map<String, String> datMapFromSymbolToId = new Map<String, String>();
                if(jsonBody.containsKey('data')){
                    for(Object dataObj :  (List<Object>)jsonBody.get('data')){
                        Map<String, Object> data = (Map<String, Object>)dataObj;
                        String symbol = String.valueOf(data.get('symbol'));
                        String cryptoId = String.valueOf(data.get('id'));
                        if(!datMapFromSymbolToId.containsKey(symbol)){// this is because there is possibility of having multiple symbols with different ids(taking the first one into consderation). Example: HASH
                            datMapFromSymbolToId.put(symbol, cryptoId);
                        }
                    }
                    for(String symbol : datMapFromSymbolToId.keySet()){
                        if(mapFromSymbolToProtocol.containsKey(symbol)){
                            mapFromExternalIdToProtocol.put(datMapFromSymbolToId.get(symbol), mapFromSymbolToProtocol.get(symbol));
                        }
                    }
                    
                }else{
                    checkForErrorResponses(jsonBody);
                }
                createIntegrationLog(req, res);
            }
        }
    }

    @testvisible
    private static void retrieveProtocolPrices(){
        List<String> coinMarketCapIds = new List<String>(mapFromExternalIdToProtocol.keySet());
        String startTime = System.now().addMonths(-1).formatGMT('yyyy-MM-dd HH:mm:ss.SSS ').replaceFirst(' ', 'T').replaceFirst(' ', 'Z');

        String endpoint = 'callout:CoinMarketCap_Api/v2/cryptocurrency/quotes/historical';
        endpoint += '?id='+String.join(coinMarketCapIds, ',');
        endpoint += '&aux=price&skip_invalid=true&interval=30d&time_start='+startTime;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('X-CMC_PRO_API_KEY', '{!$Credential.Password}');
        HttpResponse res = new Http().send(req); //{"status":{"timestamp":"2022-12-19T04:57:54.443Z","error_code":0,"error_message":null,"elapsed":127,"credit_count":1,"notice":null},"data":{"1":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":16735.66407573372}}}],"id":1,"name":"Bitcoin","symbol":"BTC"},"2":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":62.83395075792374}}}],"id":2,"name":"Litecoin","symbol":"LTC"},"52":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.3427769892539342}}}],"id":52,"name":"XRP","symbol":"XRP"},"74":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.07777475509500398}}}],"id":74,"name":"Dogecoin","symbol":"DOGE"},"883":{"quotes":[],"id":883,"name":"Positron","symbol":"TRON"},"993":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.0016735664075733718}}}],"id":993,"name":"BowsCoin","symbol":"BSC"},"1027":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":1183.9870599072844}}}],"id":1027,"name":"Ethereum","symbol":"ETH"},"1168":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":19.29666993644716}}}],"id":1168,"name":"Decred","symbol":"DCR"},"1321":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":15.779853963583808}}}],"id":1321,"name":"Ethereum Classic","symbol":"ETC"},"1437":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":44.405643967896125}}}],"id":1437,"name":"Zcash","symbol":"ZEC"},"1596":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.027616721122711265}}}],"id":1596,"name":"Edgeless","symbol":"EDG"},"1765":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.8876291478420981}}}],"id":1765,"name":"EOS","symbol":"EOS"},"1831":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":101.09765439124583}}}],"id":1831,"name":"Bitcoin Cash","symbol":"BCH"},"2010":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.2657154738838423}}}],"id":2010,"name":"Cardano","symbol":"ADA"},"2011":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.8227591403617324}}}],"id":2011,"name":"Tezos","symbol":"XTZ"},"2566":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.16155788718166725}}}],"id":2566,"name":"Ontology","symbol":"ONT"},"3602":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":44.451587123302005}}}],"id":3602,"name":"Bitcoin SV","symbol":"BSV"},"3635":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.05645210978485823}}}],"id":3635,"name":"Cronos","symbol":"CRO"},"3640":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":5.645338205443344}}}],"id":3640,"name":"Livepeer","symbol":"LPT"},"3794":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":8.812551208825159}}}],"id":3794,"name":"Cosmos","symbol":"ATOM"},"3890":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.8062049199909428}}}],"id":3890,"name":"Polygon","symbol":"MATIC"},"4030":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.18724254224897335}}}],"id":4030,"name":"Algorand","symbol":"ALGO"},"4558":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.7528782041267345}}}],"id":4558,"name":"Flow","symbol":"FLOW"},"4761":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.08988138565101335}}}],"id":4761,"name":"NuCypher","symbol":"NU"},"5034":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":25.26862106627529}}}],"id":5034,"name":"Kusama","symbol":"KSM"},"5426":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":12.312887479589595}}}],"id":5426,"name":"Solana","symbol":"SOL"},"5566":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.0758096777937305}}}],"id":5566,"name":"Keep Network","symbol":"KEEP"},"5567":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":0.5204550305002832}}}],"id":5567,"name":"Celo","symbol":"CELO"},"5805":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":11.886265000533047}}}],"id":5805,"name":"Avalanche","symbol":"AVAX"},"6535":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":1.3352139602042656}}}],"id":6535,"name":"NEAR Protocol","symbol":"NEAR"},"6636":{"quotes":[{"timestamp":"2022-12-19T04:54:00.000Z","quote":{"USD":{"price":4.633326531922397}}}],"id":6636,"name":"Polkadot","symbol":"DOT"},"6756":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.12372607630208311}}}],"id":6756,"name":"Acala Token","symbol":"ACA"},"6836":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.3443868709732584}}}],"id":6836,"name":"Moonbeam","symbol":"GLMR"},"7653":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.03823840963925802}}}],"id":7653,"name":"Oasis Network","symbol":"ROSE"},"8200":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.028449277487824463}}}],"id":8200,"name":"Shapeshift FOX Token","symbol":"FOX"},"8506":{"quotes":[{"timestamp":"2022-12-19T04:52:00.000Z","quote":{"USD":{"price":0.0013770244809078295}}}],"id":8506,"name":"HASH Token","symbol":"HASH"},"9285":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":6.799610598102753}}}],"id":9285,"name":"Moonriver","symbol":"MOVR"},"12220":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.764099218349257}}}],"id":12220,"name":"Osmosis","symbol":"OSMO"},"12932":{"quotes":[{"timestamp":"2022-12-19T04:52:00.000Z","quote":{"USD":{"price":2.9946723481e-10}}}],"id":12932,"name":"Little Bunny Rocket","symbol":"LBR"},"17751":{"quotes":[{"timestamp":"2022-12-19T04:53:00.000Z","quote":{"USD":{"price":0.015538088366480001}}}],"id":17751,"name":"Threshold","symbol":"T"},"17799":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":0.49353111600836264}}}],"id":17799,"name":"Axelar","symbol":"AXL"},"19899":{"quotes":[{"timestamp":"2022-12-19T04:51:00.000Z","quote":{"USD":{"price":0.3229719416133348}}}],"id":19899,"name":"Evmos","symbol":"EVMOS"},"20314":{"quotes":[{"timestamp":"2022-12-19T04:50:00.000Z","quote":{"USD":{"price":1.3161059784602125}}}],"id":20314,"name":"Terra","symbol":"LUNA"}}}

        
        if(res != null){
            Map<String, Object> jsonBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object> data =  (Map<String, Object>)jsonBody.get('data');

            for(String protId : mapFromExternalIdToProtocol.keySet()){
                if(data.containsKey(protId)){
                    String dataObj = JSON.serialize(data.get(protId));
                    QuotePrices quotePrice = (QuotePrices)JSON.deserialize(dataObj, QuotePrices.class);
        
                    Protocol__c prot = mapFromExternalIdToProtocol.get(protId);
                    if(String.ISBLANK( prot.CoinMarketCap_External_Id__c)){
                        prot.CoinMarketCap_External_Id__c = protId;
                    }
                    if(quotePrice != null && !quotePrice.quotes.isEmpty()){
                        prot.Price__c = Decimal.valueOf(quotePrice.quotes[0].quote.USD.price);
                    }
                    updateProtocols.put(prot.Id, prot);
                }
            }
            createIntegrationLog(req, res);
        }

        try{
            update updateProtocols.values();
        }
        catch(Exception ex){
            // System.debug('Exception:'+ex);
        }
    }

    private static void checkForErrorResponses(Map<String, Object> jsonBody){
        List<String> invalidSymbols =  new List<String>();
        Map<String, Object> status =  (Map<String, Object>)jsonBody.get('status');
        if(status.containsKey('error_message') ){
            String error_message = String.valueOf(status.get('error_message')); 
            if(error_message.contains('Invalid values for \"symbol\":') || error_message.contains('Invalid value for \"symbol\":') || Test.isRunningTest()){
                invalidSymbols = error_message.split(':')[1].replace('\"','').trim().split(','); //ex: "error_message": "Invalid values for \"symbol\": \"BS,ET6\"",
                for(String invalid_symbol : invalidSymbols){
                    if(mapFromSymbolToProtocol.containsKey(invalid_symbol)){
                        Protocol__c prot = mapFromSymbolToProtocol.get(invalid_symbol);
                        prot.Error_Message_CoinMarketCapAPi__c = 'Invalid value for symbol: '+invalid_symbol;
                        updateProtocols.put(prot.Id, prot);

                        //remove invalid symbols from the list
                        mapFromSymbolToProtocol.remove(invalid_symbol);
                    }
                }
                //after removing unvalid symbols, once again call the retrieveExternalIds methods 
                retrieveExternalIds();
            }
            else{
                //add error log TBA
                // System.debug('error_message: '+error_message);
            }
        }
    }

    public static void createIntegrationLog(HttpRequest req, HttpResponse res){
        Integration_Logs__c il = new Integration_Logs__c();
        il.Request__c = req.getEndpoint();
        il.Request_Method__c = req.getMethod();
        il.Response__c = res.getBody();
        il.Response_Code__c = String.valueOf(res.getStatusCode());
        il.Integration_Type__c = 'CoinMarketCap';
        il.API_Type__c = 'REST';
        iLogs.add(il);
    }

    public class QuotePrices{
        public Quotes[] quotes;
    }

    public class Quotes{
        public Quote quote;
    }

    public class Quote{
        public CurrencyType USD;
    }

    public class CurrencyType{
        public String price;
    }

}