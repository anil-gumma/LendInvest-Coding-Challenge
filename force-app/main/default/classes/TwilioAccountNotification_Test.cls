/*

Description:  Test Class for Twilio Message Service : POC-2354
Created Date: 23/10/2022
Created By:   Anil Gumma

*/
@isTest
public class TwilioAccountNotification_Test {
    Public static testmethod void testTwilioMessage(){
        Account acc = new Account();
        acc.name = 'TestAccount';
        acc.Phone = '7812313783';
        insert acc;
        
        // Insert the opportunity data
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.Amount = 321433;
        opp.StageName ='Closed Won';
        opp.CloseDate = system.Today();
        opp.AccountId = acc.Id;
        insert opp;
        
        // Error Log Data
        Error_Log__c  err = new Error_Log__c ();
        err.Name = 'Integration Error';
        err.Status_Code__c = 'test1';
        insert err;
        
        // With the status code as Success
        If (acc.Id != null){
            Test.setMock(HttpCalloutMock.class, new TestMockClass_Twilio (201));
            Account act = new Account();
            act.Is_SMS_Sent__c = true;
            act.Id             = acc.Id;
            Database.update(act);
        }
        
        // With the status code as Error
        Test.setMock(HttpCalloutMock.class, new TestMockClass_Twilio (404));
    }
}