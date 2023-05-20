public class info 
{
public list<student> stu;
    public integer rollnum;
    public integer startno;
    public void data()
    {
        stu =new list<student>();
        student obj1=new student();
        obj1.Name='vinay';
        obj1.mobilenum='9666963777';
        obj1.age=22;
        stu.add(obj1);
         student obj=new student();
        obj.age=23;
        obj.mobilenum='7732014514';
        obj.Name='sriram';
        stu.add(obj);
         student obj2=new student();
        obj2.Name='sandeep';
        obj2.age=23;
        obj2.mobilenum='3694568926';
        stu.add(obj2);
         student obj3=new student();
        obj3.Name='Ravi';
        obj3.mobilenum='45612398752';
        obj3.age=25;
        stu.add(obj3);
         student obj4=new student();
  obj4.Name='chai';
  obj4.age=24;
  obj4.mobilenum='4569875236';
  stu.add(obj4);
  system.debug('info'+stu); 
        student obj5 =new student();
        obj5.age=24;
        obj5.mobilenum='4563698547';
        obj5.Name='jayanth';
        stu.add(2,obj5);  
    system.debug('list'+stu);
        list<student>asdf;
        asdf=stu.clone();
        system.debug('second list'+asdf);
        if(stu.isEmpty())
        {
            system.debug('empty');
        }
        else
        {
            system.debug('list is not empty');
            integer m=stu.size();
        }
    }
    public void datawithnum()
    {
      info str=new info();
        str.rollnum=startno;
        for(student std:stu)
        {
            std.rollnum=startno++;
            system.debug('student data'+std);
        }
    }
}