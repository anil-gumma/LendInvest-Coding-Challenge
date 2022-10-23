import { LightningElement , api, wire} from 'lwc';
import SendSMS from '@salesforce/apex/TwilioNotificationController.SendSMS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import returnAccount from '@salesforce/apex/TwilioNotificationController.returnAccount';
import { getRecord } from 'lightning/uiRecordApi';
import CUSTOMER_CLASSIFICATION from '@salesforce/schema/Account.Customer_Classification__c'

export default class Twilio_SMS extends LightningElement {

    body;
    @api recordId;
    account;

    // @wire(getRecord, { recordId: `$recordId`, fields:['Customer_classification__c', 'Phone']})
    //  account

    connectedCallback(){
        returnAccount({recordId:this.recordId})
        .then(result => {
            if(result){
                this.account = result;
            }
        })
    }

     get show(){
        return  this.account && this.account.Customer_classification__c === 'GOLD' ? true : false;
     }

    handleClick(){
        console.log('accoyn => '+JSON.stringify(this.account))
        SendSMS({accountId:this.recordId, messageBody:this.body})
        .then(result => {
            if(result == 'Success'){
                this.showToastEventHandler('success', 'Message Sent Successfully!!');
                this.body = '';
            }else if(result == 'Failure'){
                this.showToastEventHandler('warning', 'Please Update Account Number to +447404732584 because this is verified Number');
            }
        }).catch(error => {
            console.log('error => '+JSON.stringify(error) )
            console.log('error => '+error);

            this.showToastEventHandler('error', 'Failed to Send Message');
        })
    }

    handleChange(event){
        this.body = event.target.value;
    }

    showToastEventHandler(variant, message){
        this.dispatchEvent(new ShowToastEvent({
            variant,
            message
        }))
    }
}