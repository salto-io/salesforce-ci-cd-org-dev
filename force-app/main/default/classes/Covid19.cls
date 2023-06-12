public class Covid19 {

    public Integer recoveredInArea=0;
    public static Integer recoveredcountry=0;
    
    //added comment to test changes from main org
    //more deletion
    //tmbulr girls geazy
    //him&I
//ajbvshuqsvyu
    //some demop
    //asnaubs
//checking fr full without class name
    ///asguiageyuawgdyuvgd
   /* public Covid19()
    {
        system.debug('blank construtor is called');
    }
    */
    public Covid19(Integer recoveredInArea)
    {
        
        system.debug('construtor is called');
        if(recoveredInArea<0)
        {
            recoveredInArea=0;
        }
        else{
        this.recoveredInArea=recoveredInArea;
        recoveredcountry+=recoveredInArea;
        }
    }
    public  void treatpatient()
    {
        recoveredInArea++;
        recoveredcountry++;
        
    }
    
    public Integer gettreated()
    {
        return recoveredInArea;
    }
  
}