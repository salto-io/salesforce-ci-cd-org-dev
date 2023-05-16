public class ParkLocator {

    public static String[] country(String country) {
        ParkService.ParksImplPort service = new ParkService.ParksImplPort();
        return service.byCountry(country);
    } 
}