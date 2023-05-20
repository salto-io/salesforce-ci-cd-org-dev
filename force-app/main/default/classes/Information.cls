public class Information {
    public Employee emps{get;set;}
    public list<Employee> em{get;set;}
    public boolean Createrecord{get;set;}
    public boolean InputDisplay{get;set;}
    public boolean outputdisplay{get;set;}
    public boolean savedetails{get;set;}
    public Information(){
       
        Createrecord = true;
        InputDisplay = false;
        outputdisplay = false;
        savedetails = false;
    }
    public void Createnew(){
        InputDisplay = true;
        Createrecord = false;
    }
    public void create(){
        InputDisplay = false;
        outputdisplay = true;
    }
    public void save(){
        
    }
}