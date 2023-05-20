@IsTest
public class address_test {
    public static testmethod void Address(){
      Address adres = new Address();
        adres.street = 'DeerPark Dr.';
            adres.state = 'California';
            adres.city = 'Fullerton';
            adres.country = 'U.S.A';
            adres.Landmark = 'Cal State Fullerton';
        adres.ZIPcode = 92831;
        adres.PlotNo = 1311;
    }
}