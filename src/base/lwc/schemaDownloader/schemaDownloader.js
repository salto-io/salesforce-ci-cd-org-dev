import { LightningElement, track, api } from "lwc";
import callSchemaUtility from "@salesforce/apex/SchemaUtility.getSchemaInformation";

export default class SchemaDownloader extends LightningElement {
    //This would be populated via a combination of JS and Apex logic
    @track recordData = "none";

    //Dynamically populated. Associated with the object you wish to get information for.
    @track fileName = "Account_Schema.csv";

    //Will contain information on data format, in this case text plain
    @track text;
    objectInfo = [];
    @track value;
    @track displayComponent;
	@track displayError;

    connectedCallback() {
        callSchemaUtility({ objectName: "", isObjectListCall: true })
            .then((result) => {
                this.displayComponent = true;
                this.objectInfo = JSON.parse(result);
                this.objectInfo.sort(function (a, b) {
                    a = a.label.toLowerCase();
                    b = b.label.toLowerCase();
                    return a < b ? -1 : a > b ? 1 : 0;
                });
            })
            .catch((error) => {
                console.log(error);
                this.displayComponent = false;
            });
    }

    handleObjectSelection(event) {
        callSchemaUtility({ objectName: event.detail.value, isObjectListCall: false })
            .then((result) => {
                this.recordData = result;
                this.text = `data:text/plain,${encodeURIComponent(`${this.recordData}`)}`;
                this.fileName = "Schema_" + event.detail.value + ".csv";
            })
            .catch((error) => {
                console.log(error);
            });
    }

    handleClick() {}
}