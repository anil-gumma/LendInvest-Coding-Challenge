/*

Description: HTTPCalloutMock Test Class: POC-2354
Created Date: 23/10/2022
Created By:   Anil Gumma

*/
@isTest
global class TestMockClass_Twilio implements HttpCalloutMock {
    private Integer statusCode;
    public TestMockClass_Twilio (Integer statusCode){
        this.statusCode = statusCode;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(this.statusCode);
        return res;
    }
}