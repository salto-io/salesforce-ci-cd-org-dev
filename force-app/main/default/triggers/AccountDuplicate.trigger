trigger AccountDuplicate on Account (before insert)
{

    Set<String> setName = new Set<String>();
    For(Account acc : trigger.new)
    {
        setName.add(acc.name);
    }
    
    if(setName.size() > 0 )
    {
        List<Account> lstAccount = [select name ,id from account where name in :setName ];
        
        Map<String ,Account> mapNameWiseAccount = new Map<String,Account>();
        For(Account acc: lstAccount)
        {
            mapNameWiseAccount.put(acc.name ,acc);
        }
        
        For(Account acc : trigger.new)
        {
            if(mapNameWiseAccount.containsKey(acc.name))
            {
                acc.Name.addError('Name already Exist ');
            }
        }
        
    }
}