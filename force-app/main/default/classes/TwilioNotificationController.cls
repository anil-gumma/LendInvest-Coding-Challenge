/*

Description: Send the message via Twilio Service : POC-2354
Created Date: 23/10/2022
Created By:   Anil Gumma

*/
public with sharing class TwilioNotificationController {
    
      /* purpose      : Send SMS to COE if the Account is moved to GOLD. since it called from Trigger Made Future 
      * parameters    : accountId, Body of SMS
      * return value  : NA
      */
    @future(callout=true)
    public static void sendSmsFromTrigger(Id accountId, String messageBody){
        SendSMS(accountId, MessageBody); 
    }
    
    
      /* purpose      : Send SMS to COE if the Account is moved to GOLD. it is used to call from Future and LWC
      * parameters    : accountId, Body of SMS
      * return value  : String
      */

   @AuraEnabled
    public static String SendSMS(Id accountId, String messageBody){
        // Get all data from Meta data, since the data may change in Future
        Twilio_Config__mdt tlinfo =  [select AccountSID__c, AuthToken__c,Version_Control__c, CEO_To_Number__c, End_point_url__c,
                                           From_Twilio_Number__c from Twilio_Config__mdt limit 1];
        
        HttpRequest RestRequest = createTwilioHTTPRequest(tlinfo);
        RestRequest.setBody(RestRequest.getBody()+'&Body='+MessageBody);
        
        Http http = new Http();
        HTTPResponse RestResponse = http.send(RestRequest);
        
        if(RestResponse.getStatusCode()==201){
           // system.debug('We Have Sent Message Successfully ');
            Account act = new Account();
            act.Is_SMS_Sent__c = true;
            act.Id             = accountId;
            Database.update(act);
            return 'Success';
        }else{
           // system.debug('Error => '+RestResponse.getBody());
            Error_Log__c  er = new Error_Log__c ();
            er.Status_Code__c     = String.valueOf(RestResponse.getStatusCode());
            er.Name             = 'Twilio Failure';
            er.Error_Reason__c  = RestResponse.getBody();
            er.sObjectID__c = accountId;
            Database.insert(er);
            return 'Failure';
        }
    }
    
     /* purpose       : Prepare and Return HttpRequest
      * parameters    : Twilio_Config__mdt
      * return value  : HttpRequest
      */
    public static HttpRequest createTwilioHTTPRequest(Twilio_Config__mdt reqValues){
        HttpRequest RestRequest = new HttpRequest();
        RestRequest.setEndpoint(reqValues.End_point_url__c+reqValues.AccountSID__c+'/Messages.json');
        RestRequest.setMethod('POST');
        RestRequest.setHeader('X-Twilio-Client', 'salesforce-' + reqValues.Version_Control__c);
        RestRequest.setHeader('User-Agent', 'twilio-salesforce/'+reqValues.Version_Control__c);
        RestRequest.setHeader('Accept', 'application/json');
        RestRequest.setHeader('Accept-Charset', 'utf-8');
        RestRequest.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(reqValues.AccountSID__c+':' +reqValues.AuthToken__c)));
        RestRequest.setBody('To='+EncodingUtil.urlEncode(reqValues.CEO_To_Number__c,'UTF-8')+'&From='+EncodingUtil.urlEncode(reqValues.From_Twilio_Number__c,'UTF-8'));
        return RestRequest;
        
    }
        
    @AuraEnabled(cacheable=true)
    public static Account returnAccount(String recordId){
        return [Select Phone, Customer_Classification__c from Account Where Id =: recordId];
    }
}