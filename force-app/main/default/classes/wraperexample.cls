public class wraperexample {
    public list<info> abc;
    public list<student>asdf;
    public list<wclass>stud;
    public wraperexample()
    {   
       abc=new list<info>();
        info obj= new info();  
        obj.data();
         asdf=obj.stu;
        system.debug('****'+asdf);
        stud =new list<wclass>();
        for(student em:asdf)       
        {
            wclass fc=new wclass();
            fc.qwer =em;    
            if(em.age >18)
            {
                fc.status='major';
            }
            else
            {
                fc.status='minor';
            }
            stud.add(fc);
        }
        system.debug(+stud);
    }
    public class wclass{
        public student qwer;
        public string status;
    }
}