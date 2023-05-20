public class GSsolutions {
    public list<EMPinfo> EMP{get;set;}
    public GSsolutions()
    {
        EMP = new list<EMPinfo>();
        
        EMPinfo info = new EMPinfo();
        info.Firstname = 'Sandeep';
        info.lastname = 'Ratakonda';
        info.age = 24;
        info.EmployeeID = 'A125B1';
        EMP.add(info);
        
        EMPinfo info1 = new EMPinfo();
        info.Firstname = 'Ravi Chandra';
        info.lastname = 'Chevula';
        info.age = 23;
        info.EmployeeID = 'A125B2';
        EMP.add(info1);
        
        EMPinfo info2 = new EMPinfo();
        info.Firstname = 'Vinay';
        info.lastname = 'Jujjavarapu';
        info.age = 22;
        info.EmployeeID = 'A125B3';
        EMP.add(info2);
        
        EMPinfo info3 = new EMPinfo();
        info.Firstname = 'Vishnu';
        info.lastname = 'Mandadi';
        info.age = 23;
        info.EmployeeID = 'A125B4';
        EMP.add(info3);
        
        EMPinfo info4 = new EMPinfo();
        info.Firstname = 'Ritesh';
        info.lastname = 'Potu';
        info.age = 25;
        info.EmployeeID = 'A125B5';
        EMP.add(info4);
    }
    public void Save()
    {
        EMPinfo info = new EMPinfo();
        EMPinfo info1 = new EMPinfo();
        EMPinfo info2 = new EMPinfo();
        EMPinfo info3 = new EMPinfo();
        
        info.Firstname = 'Sandeep';
        info.lastname = 'Ratakonda';
        info.age = 24;
        info.EmployeeID = 'A125B1';
        EMP.add(info);
        
        info.Firstname = 'Ravi Chandra';
        info.lastname = 'Chevula';
        info.age = 23;
        info.EmployeeID = 'A125B2';
        EMP.add(info1);
        
        info.Firstname = 'Vinay';
        info.lastname = 'Jujjavarapu';
        info.age = 22;
        info.EmployeeID = 'A125B3';
        EMP.add(info2);
        
        info.Firstname = 'Vishnu';
        info.lastname = 'Mandadi';
        info.age = 23;
        info.EmployeeID = 'A125B4';
        EMP.add(info3);
        
        EMPinfo info4 = new EMPinfo();
        info.Firstname = 'Ritesh';
        info.lastname = 'Potu';
        info.age = 25;
        info.EmployeeID = 'A125B5';
        EMP.add(info4);
    }
}