@isTest
private class ParkLocatorTest {
    @isTest static void testCallout() { 
        String[] parksInUSA = new String[0];
        parksInUSA.add('Six Flags');
        parksInUSA.add('Disneyland');
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ParkServiceMock());
        // Call the method that invokes a callout
        String country = 'USA';
        String[] result = ParkLocator.country(country);
        // Verify that a fake result is returned
        System.assertEquals(parksInUSA, result); 
    }
}