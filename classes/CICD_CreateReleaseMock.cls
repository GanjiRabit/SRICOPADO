@isTest
global class CICD_CreateReleaseMock implements HttpCalloutMock{
    
    global CICD_CreateReleaseMock(integer statusCode){
        this.statusCode = statusCode;
    } 
   global  integer statusCode;
    
   global HTTPResponse respond(HTTPRequest req) {
      
        string returnMessage = '{"description": "An excellent version","projectId": 10000 , "id" : "1005" ,"project" : { "key" : 2500 } }';
        if( req.getEndpoint().contains('jql') ) returnMessage = ' {"issues" : [{ "id" : 100  } , { "id" : 225 , "project" : { "key" : 2500 } } ]} ';
        if( req.getEndpoint().contains('transitions') ) returnMessage = ' {"transitions" : [{ "id" : "1" , "name" : "In Progress"  } ] } ';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(returnMessage);
        res.setStatusCode(statusCode);
        return res;
    }
}