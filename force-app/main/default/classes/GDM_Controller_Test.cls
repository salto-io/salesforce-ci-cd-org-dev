@isTest
public class GDM_Controller_Test {

    @isTest static void testAPICallout() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GDM_HttpCalloutMock());

        // This method will get a fake response from the class that implements HttpCalloutMock
        GDM_Controller.GDM_Wrapper testWrapper = GDM_Controller.calculateDistanceGoogle('Carrer de Serrano 2', 
                                                                                        'Barcelona',
                                                                                        'Barcelona',
                                                                                        '08031', 
                                                                                        'España', 
                                                                                        'Calle de Manuel Ferrero 13', 
                                                                                        'Madrid', 
                                                                                        'Madrid', 
                                                                                        '28036', 
                                                                                        'España'
                                                                                        );
        System.assertEquals('362 km', testWrapper.distanceStr);
    }
}