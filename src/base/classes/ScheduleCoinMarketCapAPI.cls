/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
public class ScheduleCoinMarketCapAPI implements Schedulable {
    public void execute(SchedulableContext sc) {
        CoinMarketCapAPIIntegration.doGetCalloutToCoinMarketCapAPI();
    }
}