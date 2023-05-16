public class AnimalLocator {
    
    public static String getAnimalNameById(Integer animalId) {
        String animalName;
        HttpResponse response = doGetAnimalById(animalId);
        if(response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> animal = (Map<String, Object>) result.get('animal');
            animalName = (String) animal.get('name');
        }
        return animalName;
    } 
    
    public static HttpResponse doGetAnimalById(Integer animalId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/' + animalId);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('results: ' + results);
            Map<String, Object> animal = (Map<String, Object>) results.get('animal');
            System.debug('animal: ' + animal);
            System.debug('Received the following animal:');
            System.debug((String) animal.get('name'));
        }
        return response;
    }   
}