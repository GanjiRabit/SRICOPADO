global with sharing class GetWebProduct {
 
    @InvocableMethod
    public static List<Results> GetWebProduct(List<Requests> requests)
       {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = requests[0].endpoint;
            String submittedId = requests[0].submittedId;
            request.setEndpoint(endpoint + submittedId );
            request.setMethod('GET');
            HttpResponse response = http.send(request);
           
            Results curResult = new Results();
            String responseJSON = response.getBody();
           
            WebProduct curProduct = WebProduct.parse(responseJSON);        
            curResult.WebProduct = curProduct;
           
            List<Results> resultsList = new List<Results>();
            resultsList.add(curResult);
            return resultsList;
       }
    
    global class Requests {
        @InvocableVariable
        global String submittedId;
        
        @InvocableVariable
        global String endpoint;       
    }
    
    global class Results {
        @InvocableVariable
        global WebProduct WebProduct;
    }

}