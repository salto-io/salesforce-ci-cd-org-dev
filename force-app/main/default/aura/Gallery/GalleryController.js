({
    onInit: function(component) {
		component.set("v.pictures", []); 
    },
    
    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        
        "use strict";
        
		event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';

        var files = event.dataTransfer.files;
        
        for (var i=0; i<files.length; i++) {
            let file = files[i];
            if (!file.type.match(/(image.*)/)) {
                continue;
            }
            let reader = new FileReader();
            reader.onloadend = function() {
                var dataURL = reader.result;
		        var pictures = component.get("v.pictures");
                pictures.push(dataURL);
                component.set("v.pictures", pictures);
                //helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
            };
            reader.readAsDataURL(file);
        }
        
	}
    
})