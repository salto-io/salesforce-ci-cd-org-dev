public class studinfo {
    public EmployeeInfo sin{get;set;}
    public Address add{get;set;}
    public additionalinfo adinfo{get;set;}
    public studinfo(){
        sin = new EmployeeInfo();
        add = new Address();
        adinfo = new additionalinfo();
    }
    public void Save(){ system.debug('====>'+sin +'====>'+add +'====>'+adinfo);    }
    public void Edit(){ system.debug('====>'+sin +'====>'+add +'====>'+adinfo);    }
    public void Del(){  system.debug('====>'+sin +'====>'+add +'====>'+adinfo);   }
}