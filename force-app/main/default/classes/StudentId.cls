public class StudentId {
    public string name{get;set;}
    public string StudentID{get;set;}
    public integer MobileNo{get;set;}
    public boolean input{get;set;}
    public boolean output{get;set;}
public StudentId(){
	input = true;
output=false;    
}
public void save()
{
	input = false;
	output = true;    
	system.debug('=====>'+name+'====>'+StudentID+'===>'+MobileNo);
}
}