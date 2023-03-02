/**
 * @description       : 
 * @author            : Lavanya Tangati
 * @group             : 
 * @last modified on  : 01-05-2023
 * @last modified by  : Lavanya Tangati
**/
public class TA_Account_HandleCountryCodeAndRegion implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    public void BeforeInsert(List<Account> newList) {
        handleCountryCodesAndRegion(newList);
    }

    public void BeforeUpdate(List<Account> newList, List<Account> oldList) {
        Map<Id, Account> oldMap = new Map<Id, Account>(oldList);
        handleCountryCodesAndRegion(newList, oldMap);
    }

    public static void handleCountryCodesAndRegion(List<Account> newAccounts) {
        for (Account account : newAccounts) {
            if (String.isNotEmpty(account.Countries_of_Incorporation__c)) {
                CountryCodeCalculator.setCountryCodesAndRegion(account);
            }
        }
    }

    public static void handleCountryCodesAndRegion(
        List<Account> newAccounts,
        Map<Id, Account> oldAccounts
    ) {
        for (Account account : newAccounts) {
            if (String.isEmpty(account.Countries_of_Incorporation__c)) {
                account.Country_Codes__c = null;
                account.Region__c = null;
            } else {
                Account oldAccount = oldAccounts.get(account.Id);

                if (
                    account.Countries_of_Incorporation__c !=
                    oldAccount.Countries_of_Incorporation__c
                ) {
                    CountryCodeCalculator.setCountryCodesAndRegion(account);
                }
            }
        }
    }
}