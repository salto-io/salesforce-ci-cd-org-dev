public class Company {
    public string Name{get;set;}
    Public list<EmployeeInfo> emp{get;set;}
public VOid show()
    {
   Name = 'SpaceX';
        emp = new list<EmployeeInfo>();
        EmployeeInfo emp1 = new EMployeeInfo();  
        emp1.Firstname = 'Sandeep';
        emp1.lastname = 'Ratakonda';
        emp1.age = 25;
        emp1.EmployeeID = '10BH1A0481';
        emp1.email = 'sandeepdeepu@hotmail.com';
        emp1.dob = date.newInstance(1992, 12, 09);
        emp1.MobileNo = '9553550987';
        system.debug('===> employee'+emp1);
        EmployeeInfo emp2 = new EMployeeInfo();
        emp2.age = 26;
        emp2.EmployeeID = '10bh1a0470';
        emp2.Firstname = 'Ravi Chandra';
        emp2.lastname = 'Chevula';
        emp2.email = 'sandeepdeepu@hotmail.com';
        emp2.dob = date.newInstance(1992, 12, 09);
        emp2.MobileNo = '9553550987';
        emp.add(emp2);
        system.debug('==>emp1'+emp2);
    }
}