public class Fitness {
 
    public Decimal BMI(Decimal weight,Decimal height)
    {
        Decimal BMI;
       // Decimal square= height*height;
        BMI=weight/(height*height);
        
        return BMI;
    }
    
     public Decimal caculatepace(Decimal km,Decimal min)
    {
        Decimal total;
        decimal hr=min/60;
        total=km/hr;
        
        
        return total;
    }
    
    
}