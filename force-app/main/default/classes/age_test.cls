@IsTest
public class age_test {
    public static testmethod void age(){
     age a = new age();
        a.dob = date.newInstance(1992, 12, 09);
        a.n = date.newInstance(2017, 10, 10);
        a.method(); 
    }
}