@istest
public class contactinfo_test {
    public static testmethod void contactinfo(){
        contactinfo cinfo = new contactinfo();
        cinfo.save();
        cinfo.cancel();
        cinfo.save_new();
    }
}