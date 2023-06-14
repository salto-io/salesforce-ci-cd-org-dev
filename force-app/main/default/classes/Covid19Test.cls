@isTest
public class Covid19Test {
	@isTest
    public static void treatpatienttest()
    {
        //create instance of the class
        Covid19 jaipur=new Covid19(10);
        
        //check if count is 10 or not
       Integer treated = jaipur.gettreated();
       System.assertEquals(10, treated, 'check value does not match');
        
        Covid19 hyd=new Covid19(112);
        
        //check if count is 10 or not
       Integer treatedhyd = hyd.gettreated();
       System.assertEquals(112, treatedhyd, 'check value does not match');
        
        
         System.assertEquals(122, Covid19.recoveredcountry, 'check value does not match');
        jaipur.treatpatient();
        treated = jaipur.gettreated();
        system.assert(treated==11, 'treated count does not match');
        system.assert(Covid19.recoveredcountry==123, 'treated count does not match');
        
    }
    @isTest
    public static void treatpatienttestnegative()
    {
        //create instance of the class
        Covid19 jaipur=new Covid19(-10);
        
        //check if count is 10 or not
       Integer treated = jaipur.gettreated();
       System.assertEquals(0, treated, 'check value does not match');
    }
}