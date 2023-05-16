global class GDM_HttpCalloutMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();

        //Google Distance Matrix API call
        if(req.getEndpoint().contains('https://maps.googleapis.com/maps/api/distancematrix/json')){
            // Optionally, only send a mock response for a specific endpoint and method.
            System.assertEquals('GET', req.getMethod());

            // Fill the fake response with dummy data
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"destination_addresses" : [ "New York, NY, USA" ],"origin_addresses" : [ "Washington, DC, USA" ],"rows" : [{"elements" : [{"distance" : {"text" : "362 km","value" : 361959},"duration" : {"text" : "3 hours 53 mins","value" : 13973},"status" : "OK"}]}],"status" : "OK"}');
            res.setStatusCode(200);
        }
        return res;
    }
}