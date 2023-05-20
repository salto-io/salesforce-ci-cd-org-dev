@istest
public class Information_test {
    public static testmethod void Information(){
        Information info = new Information();
        info.emps.firstname='Sandeep';
        info.emps.lastname='Ratakonda';
        info.emps.age=43;
		info.create();
        info.Createnew();
        info.save();
    }
}