public class Helloworld
{
  /*private String morning ='good morning world';

    private String evening ='good evening world';/*
    
    
 /* public void morning()
  {
  system.debug(morning);
  
  }
    
     public void afternoon()
  {
  system.debug(afternoon);
  
  }
    
     public void evening()
  {
  system.debug(evening);
  
  }
    */
    public String afternoon ='good afternoon  world';
    
    public void method(String message)

    {
        system.debug(message);
        
    }
    
    //returns a day name based on number
    public string getday(Integer n)
    {
        String day='';
         
        
        switch on n{
      when 0  {
            day='Sunday';
        }
            when 1  {
            day='Monday';
        }
            when 2  {
            day='Tuesday';
        }
            when 3  {
            day='Wednesday';
        }
            when 4  {
            day='Thursday';
        }
            when 5  {
            day='Friday';
        }
            when 6  {
            day='Saturday';
        }
            when else
            {
                system.debug('invalid string');
            }
    }
 
  return day;
}
    
    public string getday(String name)
    {
         {
        String day='';
         
        
        switch on name{
      when 'Sun'  {
            day='Sunday';
        }
            when 'Mon'  {
            day='Monday';
        }
            when 'Tue'  {
            day='Tuesday';
        }
            when 'Wed'  {
            day='Wednesday';
        }
            when 'Thur'  {
            day='Thursday';
        }
            when 'fri'  {
            day='Friday';
        }
            when 'sat'  {
            day='Saturday';
        }
            when else
            {
                system.debug('invalid name');
            }
    }
 
  return day;
    }
}
}