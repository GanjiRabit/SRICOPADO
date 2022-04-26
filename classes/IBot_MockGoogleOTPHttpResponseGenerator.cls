@isTest
global with sharing class IBot_MockGoogleOTPHttpResponseGenerator  implements HttpCalloutMock {
    global String response = 'true';
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assert(req.getEndpoint().contains('http://api.authy.com/protected/json/verify/'));
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":"'+response+'"}');
        res.setStatusCode(200);
        return res;
    }

}