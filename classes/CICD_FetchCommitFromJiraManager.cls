global with sharing class CICD_FetchCommitFromJiraManager extends CICD_AuraResponseTemplate {
    
  
    //to get Commits from Bitbucket related to Jira issue # and return to UI
    @AuraEnabled
    global static string fetchCommitsFromBitbucekt( string userStoryId ){

       string responseToReturn;
          
        try{

            copado__User_Story__c userStory = [select id, CICD_JiraIssueId__c,CICD_JiraIssueKey__c from copado__User_Story__c where id = : userStoryId];

           // string endPoint = 'callout:CICD_BitbucketConnector/rest/jira/1.0/issues/' + userStory.CICD_JiraIssueKey__c + '/commits?maxChanges=50000';
           string endPoint = 'callout:Devops_JiraConnector/dev-status/latest/issue/detail?issueId=' + userStory.CICD_JiraIssueId__c  + '&applicationType=bitbucket&dataType=repository';

             Map<string,object>  response = CICD_Utils.doRestCallout(endPoint, new Map<string,string>() , 'GET', null );

            responseToReturn =  returnAuraResponse( (Boolean) response.get('isSuccess') , response);

        }catch(Exception Ex){

            responseToReturn = returnAuraResponse( false , Ex.getMessage() );

        }

        return responseToReturn;
       
    }

    //to fetch committed files list from bitcuket based on commitid
    @AuraEnabled
    global static string getFilesFromCommit( string commitId ,string projectCode, string repoCode , string startPageAt ){


            startPageAt = startPageAt == null ? '0' : startPageAt;
           
            //string endPoint = 'callout:CICD_BitbucketConnector/rest/api/latest/projects/' + projectCode  + '/repos/' +  repoCode + '/commits/' + commitId + '/changes?limit=1000&withComments=false&start=' + startPageAt;
            string endPoint = 'callout:CICD_BitbucketConnector/' +  repoCode.toLowerCase() + '/diffstat/' + commitId ;

             Map<string,object>  response = CICD_Utils.doRestCallout(endPoint, new Map<string,string>() , 'GET', null );

             return returnAuraResponse( (Boolean) response.get('isSuccess') , response);
       
    }

    // can be used to send a querystring from UI to get dynamic results 
    @auraEnabled
    global static string query(string queryString){

        string responseToReturn;

        try{
            
            responseToReturn =  returnAuraResponse( true , Database.query(queryString) );

        }catch(Exception ex){

            responseToReturn =  returnAuraResponse( false , ex.getMessage());

        }

        return responseToReturn;

    }

    @AuraEnabled
    global static string commitToDeploymentPipeline( string body , string userStoryId , string commitMessage){
        string responseToReturn;
        try{
            string apiKey = Label.CICD_CopadoAPIKey;
            copado__User_Story__c userStory = [select id,Name,copado__User_Story_Title__c  from copado__User_Story__c where id=:userStoryId ];
           commitMessage =  userStory.Name + ': ' + userStory.copado__User_Story_Title__c;
            string endPoint = 'https://app-api.copa.do/json/v1/webhook/commitFiles/' + userStoryId +
                           '?api_key=' +apiKey+ '&commitMessage=' + EncodingUtil.urlEncode( commitMessage, 'UTF-8') ;
   

             Map<string,object>  response = CICD_Utils.doRestCallout(endPoint, getCopadoHeaders() , 'POST', body );
            
             responseToReturn =  returnAuraResponse( (Boolean) response.get('isSuccess') , response);

        }catch(Exception Ex){
            responseToReturn =  returnAuraResponse( false , ex.getMessage());
        }

      return responseToReturn;
        
    }

    private static Map<string,string> getCopadoHeaders(){
                  
        Map<string,string> headerInfo = new Map<string,string>();            
        headerInfo.put('Content-Type','application/json');
        
        return headerInfo;
    }

    @AuraEnabled
    global static string getCopadoJobStatus( string copadoJobId){
        
        string apiKey = Label.CICD_CopadoAPIKey;
        string endPoint = 'https://app-api.copa.do/json/v1/webhook/jobStatus/' + copadoJobId + '?api_key=' + apiKey;

        Map<string,object>  response = CICD_Utils.doRestCallout(endPoint, getCopadoHeaders()  , 'GET', null);
 
        return returnAuraResponse( (Boolean) response.get('isSuccess') , response);

        
    }

    
}