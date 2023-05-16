@isTest
private class AnimalLocatorTest {
    @isTest 
    static void getAnimalNameById_Test() {
        Integer chickenId = 1;
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String actualName = AnimalLocator.getAnimalNameById(chickenId);
        String expectedName = 'chicken';
        System.assertEquals(expectedName, actualName);
    }
}