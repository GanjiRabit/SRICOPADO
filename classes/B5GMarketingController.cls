public without sharing class B5GMarketingController {
    public string flyerName {get;set;}
    public string imageName {get;set;}
    public string flyerId {get;set;}
    public string redirectURL {get;set;}
    public boolean isValidFlyer;
    public  string additionalInfo {get;set;}
    public string miniImageUrl {get;set;}
    public static string siteDesc {get;set;}
       public static string siteTitle {get;set;}
    public B5GMarketingController(){
        isValidFlyer = false;
        
        try{
            
            flyerName = ApexPages.currentPage().getParameters().get('flyer');  
            Site mySite = [select Id from Site where Name = 'Marketing'];
            SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id limit 1];
            
            for(MarketingFlyer__c flyer : [select id,Name,FlyerImageName__c,RedirectUrl__c,Key__c,MiniImageResourceUrl__c,Description__c,Title__c from MarketingFlyer__c where Name =:flyerName and Active__c=:true]){
                flyerId = flyer.Key__c;
                imageName = mySiteDetail.SecureURL + '/resource/' + flyer.FlyerImageName__c;
                redirectURL = flyer.RedirectUrl__c;
                isValidFlyer = true;
                miniImageUrl = flyer.MiniImageResourceUrl__c;
                siteDesc = flyer.Description__c;
                siteTitle = flyer.Title__c;
            }
            
            getIPAddress();
        }catch(Exception Ex){
            isValidFlyer = false;
        }
        
    }
    @RemoteAction 
    public static string saveForm( string formData){
        Map<string,object> response = new Map<string,object>();
        try{
            Map<string,object> formInfo = ( Map<string,object>) JSON.deserializeUntyped(formData);                                 
            if(isValidToken( ((string) formInfo.get('token')))){
             MarketingFlyer__c flyer = (new MarketingFlyer__c( Key__c =   (string) formInfo.get('key') ));
                
                MarketingFlyerLead__c leadInfo = new MarketingFlyerLead__c();
                leadInfo.MarketingFlyer__r = flyer ;
                leadInfo.Name__c =  (string) formInfo.get('name');
                leadInfo.Company__c =  (string) formInfo.get('businessName');
                leadInfo.Email__c =  (string) formInfo.get('email');
                leadInfo.Phone__c =  (string) formInfo.get('phone');
                leadInfo.Query__c =  (string) formInfo.get('query');                
                leadInfo.Role__c =  (string) formInfo.get('role');       
                leadInfo.Country__c =  (string) formInfo.get('country');
                leadInfo.AdditionalDetails__c =  (string) formInfo.get('additionalInfo');          
                upsert leadInfo;
                
                response.put('isSuccess' , true);    
            }else{
                response.put('isSuccess' , false);
                response.put('error' , 'Invalid Token');
            }
            
        }catch(Exception Ex) {
            response.put('isSuccess' , false);
            response.put('error' , Ex.getMessage());
        }
        
        return JSON.serialize(response);
    }
    
    public static boolean isValidToken( string token ){
        boolean isValid = false;
        try{
            Map<string,string> headerInfo = new Map<string,string>();
            headerInfo.put('content-type', 'application/x-www-form-urlencoded');
            headerInfo.put('accept' , 'application/json');
            
            Map<string,string> bodyParams = new Map<string,string>();            
            bodyParams.put('secret' , '6LfzQ-UUAAAAAOxx3o-QTT_sptBkn1hpbYFRLUOj');
            bodyParams.put('response' , token);
            string body = ' ';
            for(string key :bodyParams.keySet()){
                body += '&' + key + '=' + Encodingutil.urlEncode( bodyParams.get(key), 'UTF-8');
            } 
            
            Map<string,object> response = CICD_Utils.doRestCallout('https://www.google.com/recaptcha/api/siteverify', headerInfo, 'POST', body);    
            system.debug(' response ?? ' + response);
            
            if((boolean) response.get('isSuccess')){
                Map<string,object> message = (Map<string,object>) JSON.deserializeUntyped( ( (string) response.get('message') ) );
                isValid = (boolean) message.get('success');
            } 
        }catch(Exception Ex){
            
        }
        
        
        return isValid;
    }
    
    public void getIPAddress(){
        string ipAddress;
        // True-Client-IP has the value when the request is coming via the caching integration.
        ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ipAddress == '' || ipAddress == null) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } 
        
        // get IP address when no caching (sandbox, dev, secure urls)        
        if (ipAddress == '' || ipAddress == null) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }
                
        additionalInfo = 'IP Address ' + ipAddress;
    }
    
    public pageReference validatePromo(){
        if(!isValidFlyer){
            final PageReference target = new
                PageReference( '/Marketing/NotFound');
            target.setRedirect(true);            
            target.setRedirectCode(404);
            return target;
            
        }
        
        return null;
    }
}