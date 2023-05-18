@isTest
public class FitnessTest {
 @isTest
    public static void BMI()
    {
        Fitness bmi=new Fitness();
       
        
        Decimal cal= 90/(1.7*1.7);
        Decimal cal1=bmi.BMI(90,1.7);
        System.assertEquals(cal, cal1, 'check value does not match');

       
        
    }
    @isTest
     public static void caculatepacetest()
    {
        Fitness pace=new Fitness();
        
        
        Decimal n= (100/80);
        Decimal n1=pace.caculatepace(100,80);
        System.assertEquals(n, n1, 'check value does not match');
        
    }
}