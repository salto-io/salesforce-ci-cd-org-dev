public class AccountController {

    public static List<Account> insertaccounts(List<Account> accinsert)
    {
        insert accinsert;
        return accinsert;
    }
    
    public static Account insertsingleaccount(Account accinsert)
    {
        insert accinsert;
        return accinsert;
    }
    
    public static List<Account> fetchaccount ()
    {
        List<Account> acc= [Select name,phone from Account];
        return acc;
                 
    }
    
    public static void printaccount ()
    {
        List<Account> acc=fetchaccount();
        
         for(Account a:acc)
        {
            system.debug('Account name -- ' +a.name+ 'Account Phone - ' +a.phone );
            
        }
    }
    
    public static Integer getaccountsize()
    {
        List<Account> a=fetchaccount();
        return a.size();
    }
    
}