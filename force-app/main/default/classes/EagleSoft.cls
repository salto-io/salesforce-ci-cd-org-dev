public class EagleSoft {
    public list<EmployeeInfo> data{get;set;}
   
    Public EagleSoft()
    {
        data = new list<EmployeeInfo>();
        EmployeeInfo emp = new EMployeeInfo();
        emp.Firstname = 'Sandeep';
        emp.lastname = 'Ratakonda';
        emp.dob = date.newinstance(1992,12,09);
        emp.age = 24;
        emp.EmployeeID = 'A1';
        emp.MobileNo = '+91 955 255 0987';
        emp.email = 'sandeepdeepu@hotmail';
        data.add(emp);
        EmployeeInfo emp1 = new EMployeeInfo();
        emp1.Firstname = 'Ravi Chandra';
        emp.lastname = 'chevula';
        emp.dob = date.newinstance(1991,12,09);
        emp1.age = 25;
        emp1.EmployeeID = 'A2';
        emp1.MobileNo = '+1 714 724 4794';
        emp.email = 'chandra.ravi84@gmail.com';
        data.add(emp1);
        EmployeeInfo emp2 = new EMployeeInfo();
        emp2.Firstname = 'Vinay';
        emp.lastname = 'jujjavarapu';
        emp.dob = date.newinstance(1993,12,09);
        emp2.age = 23;
        emp2.EmployeeID = 'A3';
        emp2.MobileNo = '+91 9959623296';
        emp.email = 'vinay.sriram@yahoo.com';
        data.add(emp2);
        EmployeeInfo emp3 = new EMployeeInfo();
        emp3.Firstname = 'Vishnu';
        emp.lastname = 'Mandadi';
        emp.dob = date.newinstance(1992,12,09);
        emp3.age = 24;
        emp3.EmployeeID = 'A4';
        emp3.MobileNo = '+91 9652047118';
        emp.email = 'avatareva@gmail.com';
        data.add(emp3);
         EmployeeInfo emp4 = new EMployeeInfo();
        emp4.Firstname = 'Vikas';
        emp.lastname = 'Potu';
        emp.dob = date.newinstance(1990,12,09);
        emp4.age = 26;
        emp4.EmployeeID = 'A5';
        emp4.MobileNo = '+91 9876543210';
        emp.email = 'Vikas.potu@rediff.com';
        data.add(emp4);
       // system.debug('EagelSoft Employee Data'+data);
    }
    public void save(){
        
        EmployeeInfo emp = new EMployeeInfo();
        EmployeeInfo emp1 = new EMployeeInfo();
        EmployeeInfo emp2 = new EMployeeInfo();
        EmployeeInfo emp3 = new EMployeeInfo();
        EmployeeInfo emp4 = new EMployeeInfo();
        
        emp.Firstname = 'Sandeep';
        emp.lastname = 'Ratakonda';
        emp.dob = date.newinstance(1992,12,09);
        emp.age = 24;
        emp.EmployeeID = 'A1';
        emp.MobileNo = '+91 955 255 0987';
        emp.email = 'sandeepdeepu@hotmail';
        
        
        emp1.Firstname = 'Ravi Chandra';
        emp.lastname = 'chevula';
        emp.dob = date.newinstance(1991,12,09);
        emp1.age = 25;
        emp1.EmployeeID = 'A2';
        emp1.MobileNo = '+1 714 724 4794';
        emp.email = 'chandra.ravi84@gmail.com';
                
        emp2.Firstname = 'Vinay';
        emp.lastname = 'jujjavarapu';
        emp.dob = date.newinstance(1993,12,09);
        emp2.age = 23;
        emp2.EmployeeID = 'A3';
        emp2.MobileNo = '+91 9959623296';
        emp.email = 'vinay.sriram@yahoo.com';
        
        
        emp3.Firstname = 'Vishnu';
        emp.lastname = 'Mandadi';
        emp.dob = date.newinstance(1992,12,09);
        emp3.age = 24;
        emp3.EmployeeID = 'A4';
        emp3.MobileNo = '+91 9652047118';
        emp.email = 'avatareva@gmail.com';
        
         
        emp4.Firstname = 'Vikas';
        emp.lastname = 'Potu';
        emp.dob = date.newinstance(1990,12,09);
        emp4.age = 26;
        emp4.EmployeeID = 'A5';
        emp4.MobileNo = '+91 9876543210';
        emp.email = 'Vikas.potu@rediff.com';
        
        data.add(emp);
        data.add(emp1);
		data.add(emp2);
        data.add(emp3);
        data.add(emp4);
    }
    
}