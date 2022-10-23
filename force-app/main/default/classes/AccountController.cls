/*

Description: Populate the customer classification and send the message to customer when the status is matched. JIRA : POC-2354
Created Date: 23/10/2022
Created By:   Anil Gumma

*/
public with sharing class AccountController {

   // update customer Classification based on Total Customer Spend 
    public static void updateCustomerClassification(List<Account> newAccountLst , Map<Id, Account> oldAccMap){
        String body;
        for(Account act : newAccountLst){
            if(act.Total_Customer_Spend__c  != oldAccMap.get(act.Id).Total_Customer_Spend__c){
                act.Customer_classification__c = returnClassification(act.Total_Customer_Spend__c);
                if(act.Customer_classification__c == Constants.GOLD && act.Is_SMS_Sent__c == false){
                    body = System.label.TwilioAccountNotification.replaceAll('AccountName', act.Name) ;
                    TwilioNotificationController.sendSmsFromTrigger(act.Id, body);
                }
            }
        }
    }
    
    // Method to return the status value based on amount range
    public static String returnClassification(Decimal value){
        return value < Constants.TEN_THOUSAND || value == null ? '' : value >= Constants.TEN_THOUSAND && value < Constants.TEN_FIVE_THOUSAND ? Constants.BRONZE : value >= Constants.TEN_FIVE_THOUSAND && value < Constants.FIFTY_THOUSAND ? Constants.SILVER : Constants.GOLD;
    }
}