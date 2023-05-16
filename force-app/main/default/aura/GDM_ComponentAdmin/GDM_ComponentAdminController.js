({
    "calculateDistance" : function(cmp) {
        // Getting addresses
        var origing_address = cmp.find("origin_address");
        var destination_address = cmp.find("destination_address");
        
        // Checking Addresses Validity
        var addOriginIsValid = origing_address.checkValidity();
        var addDestinationIsValid = destination_address.checkValidity();

        // If both addresses are valid, proceed with the distance calculation
        if(addOriginIsValid && addDestinationIsValid) {

            var temp_add_1 = "New York, NY, USA";
            var temp_add_2 = "Washington, DC, USA";

            // create a one-time use instance of the calculateDistanceGoogle action in the server-side controller
            var action = cmp.get("c.calculateDistanceGoogle");
            action.setParams({ 
                oaStreet: origing_address.get("v.street"),
                oaCity: origing_address.get("v.city"),
                oaState: origing_address.get("v.province"),
                oaPostalCode: origing_address.get("v.postalCode"),
                oaCountry: origing_address.get("v.country"), 
                daStreet: destination_address.get("v.street"),
                daCity: destination_address.get("v.city"),
                daState: destination_address.get("v.province"),
                daPostalCode: destination_address.get("v.postalCode"),
                daCountry: destination_address.get("v.country")
            });

            // create a callback that is executed after the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // Print the values returned from the server
                    cmp.set("v.distanceWrapper", response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    console.log("Incomplete");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                    errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });

            $A.enqueueAction(action);
        }else{
            alert("Addresses are not valid, please check again.")
        }
    },
})