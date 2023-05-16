import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendSMS from '@salesforce/apex/SendSMSController.sendSMS';

export default class SendSMS extends LightningElement {
    audience;
    message;
    result = "";
    error = "";

    get audienceOptions() {
        return [
            { label: 'Entire Company', value: 'Entire Company' },
            { label: 'Crisis Management Team', value: 'Crisis Management Team' },
        ];
    }

    handleAudienceChange(event) {
        this.audience = event.detail.value;
    }

    handleMessageChange(event) {
        this.message = event.detail.value;
    }

    handleSendSMS() {
        sendSMS({audience: this.audience, message: this.message})
            .then((result) => {
                if(result === 'success'){
                    this.showToast('Success', 'The sms has been successfully sent.', 'success');
                } else {
                    this.showToast('Error', 'An unknown error happened, please contact your Salesforce admin.', 'error');
                }
            })
            .catch((error) => {
                this.showToast('Error', error, 'error');
            });
        
    }

    showToast(toastTitle, toastMessage, toastVariant) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
        });
        this.dispatchEvent(event);
    }
}