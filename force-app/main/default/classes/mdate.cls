public class mdate {
public date todaydate;
    public void method()
    {
        date newmdate = todaydate.addMonths(9);
        system.debug('New date'+newmdate);
        newmdate = todaydate.adddays(9);
        system.debug('new date'+newmdate);
        integer M = todaydate.day();
        system.debug('Day '+M);
         M = todaydate.dayOfYear();
        system.debug('Day of the Year: '+m);
    }
}