public with sharing class CICD_Controller {
    
    @auraEnabled
    public static Boolean hasPermissions() {
        return FeatureManagement.checkPermission('CICD_ReleaseManager');
    }    
    
    @auraEnabled
    public static List<copado__Release__c> getReleaseById(String releaseid) {
        List<copado__Release__c> release = [SELECT
			Id, 
            Name, 
            copado__Planned_Date__c
            FROM
			copado__Release__c
			WHERE Id = :releaseid
			];		 
			return release;
    }  

    @auraEnabled
    public static List<copado__User_Story__c> getCopadoStories(String releaseId, String sourceOrg) {
        
        if(sourceOrg == '' || sourceOrg == null){
            sourceOrg = 'INT';
        }

        List<copado__User_Story__c> filteredStories = new List<copado__User_Story__c>();

        List<copado__User_Story__c> stories = [SELECT
			Id, 
            Name, 
			copado__User_Story_Title__c, 
            copado__Environment__r.CICD_EnvironmentType__c,
            copado__Last_Promotion_Date__c, 
            copado__Status__c, 
            copado__Developer__r.Name, 
            copado__Project__r.Name, 
            CICD_PreDeploymentManualTasks__c, 
            CICD_PostDeploymentManualTasks__c, 
            CICD_PostDeploymentManualTasksComplete__c, 
            CICD_AcceptableCodeCoverage__c,
            CICD_WorkflowStatus__c
			FROM
			copado__User_Story__c
			WHERE copado__Release__c = :releaseId
			];		 

        
        for(copado__User_Story__c story : stories){
            if(story.copado__Environment__r.CICD_EnvironmentType__c == sourceOrg){
                filteredStories.add(story);
            }
        }
        
    
		return filteredStories;
    }

    @auraEnabled
    public static void upsertStories(String versionName, String versionId) {
  
        List<String> JiraIds = new List<String>();     
        List<String> releaseIds = new List<String>();
        Map<String, String> JiraSfUSMap = new Map<String, String>();
        List<AppLog__c> appLogs = new List<AppLog__c>();       

        CICD_BatchJob.syncStoriesFromJira(versionId , versionName , JiraIds , JiraSfUSMap , appLogs , releaseIds);
        performPostSyncOperations( JiraIds , JiraSfUSMap , JSON.serialize(appLogs) , releaseIds);
 
    }

    @future(callout = true)
    private static void performPostSyncOperations( List<string> JiraIds, Map<string , string >JiraSfUSMap , string appLogJson , List<string> releaseIds){
        CICD_BatchJob.performPostSyncOperations( JiraIds , JiraSfUSMap , (List<AppLog__c>) JSON.deserialize(appLogJson, List<AppLog__c>.Class) , releaseIds);
    }

    @AuraEnabled
    public static Map<string,object> deployPromotion(String promoId, String checkOnly, String releaseName, String sourceOrg, String testLevel){

        Map<string,object> response;

        Map<string,string> headerInfo = new Map<string,string>();
        headerInfo.put('Content-Type','application/json');

        String deployName = '';

        if(releaseName != null){           
            deployName += releaseName;           
        }

        if(sourceOrg != null){
             deployName += ' from: ' + sourceOrg;
        }

        String deployValidateText = checkOnly == 'true' ? 'Validation' : 'Deployment'; 
      
        deployName += ' ' + deployValidateText; 

        String apiKey = Label.CICD_CopadoAPIKey;
        String url = 'https://copado.herokuapp.com/json/v1/webhook/promotions/'+promoId+'/process?'; 
        url += 'checkOnly='+checkOnly+'&api_key='+apiKey+'&testLevel='+testLevel;
        url += '&deploymentName='+EncodingUtil.urlEncode(deployName, 'UTF-8');                
        
        try {
            
            response =  CICD_Utils.doRestCallout(url , headerInfo, 'POST', null );
            
            if(response.get('statusCode') == 200){      
                response.put('promotionId', promoId);
            }else{
                response.put('error', response);
            }


        }catch(Exception ex){
            system.debug('>> CICD --- ERROR DEPLOYING PROMOTION << ' + ex.getMessage() + ' >> ' + ex.getTypeName());            
        }
        
        

        return response;

    }

    @AuraEnabled
    public static String getLatestDeployment(String promoId){
        
        String deployId; 

        try {

            List<copado__Deployment__c> deployObj = [
                SELECT Id, Name
                FROM copado__Deployment__c 
                WHERE copado__Promotion__c =: promoId
                ORDER BY CreatedDate DESC];

            if(deployObj.size() > 0){
                deployId = deployObj[0].Id;
            }

        }catch(Exception ex){
            system.debug('>> CICD --- ERROR GETTING LATEST DEPLOYMENT << ' + ex.getMessage() + ' >> ' + ex.getTypeName());            
        }      
 
        return deployId;

    }


    @AuraEnabled
    public static String promoteStories(String stories, String releaseId, String sourceOrg){

        String Id;

        List<String> storyIds = (List<String>) JSON.deserialize(stories, List<String>.class); 

        List<copado__Environment__c> env = [SELECT Id, Name FROM copado__Environment__c WHERE CICD_EnvironmentType__c =: sourceOrg];

        if(env.size() > 0){
            
            // Creating Promoted User story record
            copado__Promotion__c newPromotion = new copado__Promotion__c();
            newPromotion.copado__Release__c = releaseId;
            newPromotion.copado__Source_Environment__c = env[0].Id;

            List<copado__Org__c> orgCred = [SELECT Id FROM copado__Org__c WHERE Name =: env[0].Name];

            if(orgCred.size() > 0){
                newPromotion.copado__Source_Org_Credential__c = orgCred[0].Id;
            }

            if(Test.isRunningTest()){
                
                /**THIS IS TO OVERCOME COPADO LIMITS CREATION OF PROMOTION IN TEST... */
                copado__Deployment_Flow__c  deploymentFlow = [select id from copado__Deployment_Flow__c where Name=:Label.CICD_DeploymentFlowNameForTestClass limit 1];
                
                copado__Project__c projectRecord = (copado__Project__c) CICD_TestFactory.createSObject(new copado__Project__c(
                    copado__Deployment_Flow__c = deploymentFlow.id
                ));
                insert projectRecord; 
              

                copado__Org__c orgCredential =  [select id,copado__Environment__c from copado__Org__c where copado__userName__c LIKE :Label.CICD_CredentialsForTestClass limit 1];

                newPromotion.copado__Project__c = projectRecord.id; 
                newPromotion.copado__Back_Promotion__c = false;
                newPromotion.copado__Source_Environment__c = orgCredential.copado__Environment__c;
                newPromotion.copado__Source_Org_Credential__c = orgCredential.id;               
                newPromotion.copado__Status__c = 'CICD_PromotionTriggerTest';


            }    

          
            try{
                
                insert newPromotion; 

                if(newPromotion.Id != null){

                    List<copado__Promoted_User_Story__c> promUSJunc = new List<copado__Promoted_User_Story__c>();

                    for(String si : storyIds){
                        copado__Promoted_User_Story__c promUs = new copado__Promoted_User_Story__c();
                        promUs.copado__Promotion__c = newPromotion.Id; 
                        promUs.copado__User_Story__c = si;	
                        promUSJunc.add(promUs);
                    }                

                    insert promUSJunc; 

                    Id = newPromotion.Id; 

                }


            }catch(Exception ex){
                system.debug('>> CICD --- ERROR PROMOTING STORIES << ' + ex.getMessage() + ' >> ' + ex.getTypeName());            
            }     
        
        
        }

        return Id;
    
    }

    @AuraEnabled
    public static String markPostDeploysComplete(String stories){
        
        String ret; 

        List<String> storyIds = (List<String>) JSON.deserialize(stories, List<String>.class); 

        List<copado__User_Story__c> storyList = [SELECT
			Id, 
            Name, 
            CICD_PostDeploymentManualTasksComplete__c
			FROM
			copado__User_Story__c
			WHERE Id IN :storyIds
			];		   
      
        try {

            for( copado__User_Story__c story : storyList){
                story.CICD_PostDeploymentManualTasksComplete__c = true;
            }   

            update storyList;      

            ret = 'success';

        }catch(Exception ex){
            system.debug('>> CICD --- ERROR UPDATING STORIES << ' + ex.getMessage() + ' >> ' + ex.getTypeName());            
        }   


        return ret;   

    }

    @AuraEnabled
    public static String checkStoryChanges(String stories){
        
        List<String> storyIds = (List<String>) JSON.deserialize(stories, List<String>.class); 

        String json = ''; 
        
        List<String> envIds = new List<String>(); 

        List<copado__User_Story__c> storyList = [SELECT
			copado__Environment__c            
			FROM
			copado__User_Story__c
			WHERE Id IN :storyIds
			];		   

        for(copado__User_Story__c story : storyList ){
            envIds.add(story.copado__Environment__c);
        }

        if(envIds.size() > 0){
            json = System.JSON.serialize(envIds);
        }

        return json;

    }
    



}