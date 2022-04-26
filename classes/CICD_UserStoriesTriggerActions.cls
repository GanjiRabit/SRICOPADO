public with sharing class CICD_UserStoriesTriggerActions {


    public static void defaultUsCredentials(List<copado__User_Story__c> userStoryRecords){
        //will be called from before triggers, so no additional DML required
        Map<string,user> ownerData = getUserDataBasedOnId( getOwnerIds(userStoryRecords) );
        Map<string,CICD_JiraProjectNSFEnvironmentMapping__mdt> projectSettings = getProjectSettings(); // get project settings
        List<string>credentialNames = getCredentialNames( projectSettings.values() ); // get names of the credentials
        Map<string,copado__Org__c> credentialRecordMap = getCredentialRecords(credentialNames , ownerData.values() ); // get credential records which also contains environment details
        Map<id,copado__Project__c> projectRecords =  getProjectRecords( getProjectIds(userStoryRecords) ); // get the project records for jira project keys        
        
        copado__Org__c orgCredential;

        for(copado__User_Story__c userStory : userStoryRecords){
            orgCredential = getOrgCredential( userStory.copado__Project__c , projectRecords , credentialRecordMap , projectSettings , ownerData.get(userStory.OwnerId)  );
            userStory.copado__Environment__c = orgCredential.copado__Environment__c;
            userStory.copado__Org_Credential__c = orgCredential.Id;
        }


    }

    public static void resetPostDeploymentCheck(Map<Id,copado__User_Story__c> newMap , Map<Id,copado__User_Story__c> oldMap){
        //will be called from before triggers to reset manual steps checkbox when an environment has been changed

        for(copado__User_Story__c userStory : newMap.values() ){

            if( userStory.copado__Environment__c != oldMap.get(userStory.Id).copado__Environment__c ) userStory.CICD_PostDeploymentManualTasksComplete__c = false;
        }

    }

    public static set<string> getOwnerIds(List<copado__User_Story__c>userStories){
        set<String>ownerIds = new set<string>();
        for(copado__User_Story__c userStory : userStories){
            ownerIds.add(userStory.ownerId);
        }

        return ownerIds;
    }

    public static void populateOwner(List<copado__User_Story__c> userStories){
        set<string> emailIds = new set<string>();
        Map<string,user> emailUserMap = new Map<String,user>();

        for( copado__User_Story__c story : userStories ){
            if( story.CICD_PrimaryDeveloperEmail__c != null) emailIds.add(story.CICD_PrimaryDeveloperEmail__c);
        }

        if(emailIds.size() > 0) emailUserMap = getUserData(emailIds);

         for( copado__User_Story__c story : userStories ){
            if( story.CICD_PrimaryDeveloperEmail__c != null && emailUserMap.get(story.CICD_PrimaryDeveloperEmail__c) != null) story.ownerId = emailUserMap.get(story.CICD_PrimaryDeveloperEmail__c).Id; 
        }
        
    }

    public static Map<string,User> getUserData(set<string> emailIds){

        Map<string,user> emailUserMap = new Map<string,user>();
        for(User userRecord: [select id,email,userName from user where email In: emailIds and isActive= true and profile.name like 'Parsons Employee%' order by Username]){
            emailUserMap.put( userRecord.email , userRecord);
        }

        return emailUserMap;
    }

    public static Map<string,User> getUserDataBasedOnId(set<String> ownerIds){
         Map<string,user> userIdMap = new Map<string,user>();
        for(User userRecord: [select id,email,userName,firstName,LastName from user where id  In: ownerIds]){
            userIdMap.put( userRecord.Id , userRecord);
        }

        return userIdMap;
    }

    public static void udpateWorkflowStatus(Map<id,copado__User_Story__c> newMap, Map<id,copado__User_Story__c> oldMap){
        //will be called before update
        //check for change in environment or post Deployment Steps and calculate the status accordingly
        List<copado__User_Story__c> userStoriesForStatusCalc = new  List<copado__User_Story__c>();
        set<id> environmentIds = new set<id>();
        for( copado__User_Story__c userStory : newMap.values() ){

            if( userStory.copado__Environment__c != null && (userStory.copado__Environment__c != oldMap.get(userStory.Id).copado__Environment__c || 
                userStory.CICD_PostDeploymentManualTasksComplete__c && ! oldMap.get(userStory.Id).CICD_PostDeploymentManualTasksComplete__c ||
                userStory.CICD_LastDeploymentStatus__c == 'Completed with errors') ){
                        userStoriesForStatusCalc.add(userStory);
                        environmentIds.add(userStory.copado__Environment__c);
                }
        }


        if(environmentIds.size() > 0 ) calculateWorkflowStatus( userStoriesForStatusCalc , environmentIds);
    }
    
    
    public static void updateServiceNow(Map<id,copado__User_Story__c> newMap, Map<id,copado__User_Story__c> oldMap){
        Map<string,object> message;
      
        for(copado__User_Story__c userStory : newMap.values()){
            if(userStory.CICD_JiraIssueId__c != null){
                
                message = new Map<String,object>();
				message.put( 'short_description' , userStory.copado__User_Story_Title__c);
                message.put( 'description' , userStory.Description__c);
                message.put( 'u_copado_url' , 'https://b5gpartner.lightning.force.com/' + userStory.Id);
                            //    message.put( 'state' , userStory.Snow_Stage__c );

                                  

                sendMessageToSnow(userStory.CICD_JiraIssueId__c  , JSON.serialize(message));
              
                
            }
        }
    }
    
    @future(callout = true)
    public static void sendMessageToSnow(string id , string message){
          string baseEndpoint = 'callout:ServiceNow_Connect/incident/';
        Map<String,string> headerInfo = new Map<string,string>{'Content-Type' => 'application/json'};
              CICD_Utils.doRestCallout( baseEndpoint + id, headerInfo  , 'PUT'  , message);
            
    }
    public static void updateJira(Map<id,copado__User_Story__c> newMap, Map<id,copado__User_Story__c> oldMap){
        Map<string , List<string> > fieldsToTrack = new Map<string,List<string>>(); // variation based fields those needs to be tracked
        List<String> fieldsToQuery = new List<string>(); // list of fields across all variations those needs to be queried
        string field;
        set<id> usersStoriesToSync = new set<id>(); // list of user stories that needs field sync other than status
        set<id> userStoriesToTransition = new set<id>(); // list o fuser stories those need to have status field in jira updated
        Map<string , string > variationFieldMapping = new  Map<string , string >(); // mapping between salesforce & jira field per variation
        string variationKey , syncVariationKey; 

        for(CICD_JiraSyncConfiguration__mdt setting : [select id,DeveloperName,CICD_ParentObject__c,CICD_SfFieldApiName__c,CICD_JiraIssueFieldName__c,CICD_SyncVariationKey__c from CICD_JiraSyncConfiguration__mdt where CICD_SfObjectApiName__c='copado__User_Story__c' and CICD_SyncToJira__c = true]){
                 field = setting.CICD_SfFieldApiName__c;
                 field = field.contains('__r') ? field.substring( 0 , field.indexOf('.')).replace('__r' , '__c') : field;
                 syncVariationKey = setting.CICD_SyncVariationKey__c == null ? 'blank' : setting.CICD_SyncVariationKey__c;
            
                 if( fieldsToTrack.keyset().contains( syncVariationKey ) ){
                     fieldsToTrack.get(  syncVariationKey ).add( field );
                 }else{
                     fieldsToTrack.put( syncVariationKey , new List<string> { field } );
                 }

                fieldsToQuery.add(setting.CICD_SfFieldApiName__c);
                variationFieldMapping.put( (syncVariationKey + field).trim() ,  setting.CICD_JiraIssueFieldName__c );
                
         }//end of sync configuration loop

         for(CICD_JiraSyncVariation__mdt setting : [select CICD_SfFieldApiName__c ,CICD_JiraIssueFieldName__c from CICD_JiraSyncVariation__mdt where CICD_SfObjectApiName__c = 'copado__User_Story__c']){                 
                fieldsToQuery.add(setting.CICD_SfFieldApiName__c);
                variationKey = setting.CICD_SfFieldApiName__c;
         }

        system.debug('>>> variationFieldMapping ' + variationFieldMapping);
        system.debug('>>> fieldsToTrack ' + fieldsToTrack);
         set<id> userStoryIds = newMap.keyset();
        
        //for the user stories based on variation check if the field has been changed
        for( copado__User_Story__c record : Database.query( preapareUserStoryQuery( fieldsToQuery ) )  ){                      
            //process record only if it is synced to jira
            if( record.CICD_JiraIssueId__c != null ){
                string variation = variationKey == null ? 'blank' : (string) CICD_Utils.getSobjectValue( record ,  variationKey);
                for( string fieldToTrack : fieldsToTrack.get( variation ) ){
                 if(  record.get(fieldToTrack) != oldMap.get(record.id).get(fieldToTrack) ){                      
                     if( variationFieldMapping.get( (variation + fieldToTrack).trim() ).startsWith('status.') ){                         
                         userStoriesToTransition.add( record.id );
                     }else{
                         usersStoriesToSync.add(record.id);
                     }//end of  
                  }// end of check if value changed on record
                }// end of fieldToTrack for loop
            }//end of jira key null check            
        }//end of record loop

        if( usersStoriesToSync.size() > 0 ) syncUserStoriesToJira( usersStoriesToSync , fieldsToQuery , false );
        if( userStoriesToTransition.size() > 0 ) syncUserStoriesToJira( userStoriesToTransition , fieldsToQuery , true );
    }


    @future(callout = true)
    public static void syncUserStoriesToJira(set<id> userStoryIds , List<string> fieldsToQuery , boolean isTransition){

        try{

             Map<string,string> headerInfo = new Map<String,string>();
            headerInfo.put('Content-Type','application/json');

            Map<string,map<string,object>>userStoryResponse = new Map<string,map<string,object>>();
            
            string baseUrl = 'callout:Devops_JiraConnector/api/2/issue/' ;            
            string endPoint , methodType = 'PUT'; 
             /*No bulkified endpoing available so performing a callout inside for loop */

            for(copado__User_Story__c userStory : Database.query( preapareUserStoryQuery(fieldsToQuery) ) ){
                
                endpoint = baseUrl + userStory.CICD_JiraIssueId__c;
                endpoint = isTransition ? endpoint + '/transitions' : endpoint;
                methodType = isTransition ? 'POST' : methodType; 
                userStoryResponse.put( userStory.Id , CICD_Utils.doRestCallout( endPoint  , headerInfo , methodType , CICD_Utils.prepareJiraUserStoryRequest(userStory , isTransition)  ) );
            }

            CICD_Utils.parseResponseAndLogErrors(userStoryResponse);
 
            System.debug( '>>> userStoryResponse ' + userStoryResponse);

        }catch(Exception ex){
            system.debug( '>> Error syncing to jira >> ' + Ex.getMessage());
        }
    }


    private static string preapareUserStoryQuery(List<string> fieldsToQuery){

            fieldsToQuery.add('Id');
            fieldsToQuery.add('CICD_JiraIssueId__c');
            fieldsToQuery.add('Name');
            
           

            //adding to set and back to list again to remove duplicates
            set<string> fieldSet = new set<string>();
            fieldSet.addAll(fieldsToQuery);
            fieldsToQuery = new List<string>();
            fieldsToQuery.addAll(fieldSet);

            string query = 'select '  + String.join(fieldsToQuery, ',') + ' from copado__User_Story__c where id In : userStoryIds';

            return query;
    }

 

    public static void calculateWorkflowStatus(List<copado__User_Story__c> userStoryRecords , set<id> environmentIds){
        Map<id,copado__Environment__c> environmentData =  new Map<id,copado__Environment__c>( [select id,Name,CICD_EnvironmentType__c from copado__Environment__c where id IN :environmentIds] );
        string deployedStatus = 'Deployed to ';
        string readyForTestStatus = 'Ready for Testing in ';
        string deployementFailedStatus ='Deployment failed to ';
        string environmentType;
        Map<string,string> upperEnvironmentMap = new Map<string,string>{
            'DEV' => 'INT',
            'INT' => 'UAT',
            'UAT' => 'PROD'
        };
     
        for(copado__User_Story__c userStory : userStoryRecords){
            environmentType = environmentData.get( userStory.copado__Environment__c ).CICD_EnvironmentType__c;
            if(userStory.CICD_LastDeploymentStatus__c == 'Completed with errors'){
                userStory.CICD_WorkflowStatus__c = deployementFailedStatus + upperEnvironmentMap.get(environmentType);
            }else if(userStory.CICD_PostDeploymentManualTasksComplete__c || userStory.CICD_PostDeploymentManualTasks__c == null){
                 userStory.CICD_WorkflowStatus__c = readyForTestStatus + environmentType ; 
            }else{
                 userStory.CICD_WorkflowStatus__c = deployedStatus + environmentType;
            }

        }
    }

    

    public static void checkForReopenAndDefault(Map<id,copado__User_Story__c> newMap, Map<id,copado__User_Story__c> oldMap){
        //will be called before update

        List<copado__User_Story__c> userStoriesToDefaultCreds = new List<copado__User_Story__c>();
        for(copado__User_Story__c userStory : newMap.values()){
            if(userStory.CICD_ReopenUserStory__c){
                userStoriesToDefaultCreds.add(userStory);
            }           
        }
        if(userStoriesToDefaultCreds.size() > 0) defaultUsCredentials(userStoriesToDefaultCreds);
    }


    public static Map<string,copado__Org__c> getCredentialRecords(   List<string> credentialNames , List<user> OwnerData ){
        /* Since there will be only known limited org credentials stored, limits for #rows returned will be negligible - expected no greater than 15, one per application or Jira Project*/
        List<string> additionalNamesToAdd = new List<String>();

        for(string credentialName : credentialNames){
            for(user userRecord: OwnerData){
                additionalNamesToAdd.add(credentialName + ' ' + userRecord.FirstName + ' ' + userRecord.LastName);
            }
            
        }

        credentialNames.addAll(additionalNamesToAdd);


        Map<string,copado__Org__c> credentials = new Map<string,copado__Org__c>();       
        for(copado__Org__c orgCredential:[select id,Name,copado__Environment__c,copado__Environment__r.Name, copado__Environment__r.CICD_EnvironmentType__c from copado__Org__c where Name IN :credentialNames ] ){
            credentials.put(orgCredential.Name , orgCredential);
        }
        return credentials;
    }

    public static copado__Org__c getOrgCredential(string projectId, Map<id,copado__Project__c> projectRecords , Map<string,copado__Org__c> credentialRecordMap ,  Map<string,CICD_JiraProjectNSFEnvironmentMapping__mdt> projectSettings , user userRecord){
        copado__Org__c orgCredential = new copado__Org__c();
        try{
            
            string jiraProjectKey = projectRecords.get(projectId).CICD_JiraProjectKey__c;
            string credentialName = projectSettings.get(jiraProjectKey).CICD_SfDevOrgCredential__c;
            string userBasedCredentialName = credentialName + ' ' +  userRecord.FirstName + ' ' + userRecord.LastName;
            orgCredential =  credentialRecordMap.get(userBasedCredentialName) != null ? credentialRecordMap.get(userBasedCredentialName) :  credentialRecordMap.get(credentialName);

        }Catch(Exception Ex){
            System.debug('>> Unable to find org credential for projectID ' + projectId);
        }
        return orgCredential;

    }

    public static List<string> getCredentialNames(List<CICD_JiraProjectNSFEnvironmentMapping__mdt> projectSettings){

        List<string> credentialNames = new List<string>();
        for(CICD_JiraProjectNSFEnvironmentMapping__mdt setting : projectSettings ){
           credentialNames.add(setting.CICD_SfDevOrgCredential__c);
        }
        return credentialNames;

    }

    public static Map<string,CICD_JiraProjectNSFEnvironmentMapping__mdt> getProjectSettings(){
         
         Map<string,CICD_JiraProjectNSFEnvironmentMapping__mdt> projectSettings = new Map<string,CICD_JiraProjectNSFEnvironmentMapping__mdt>();
         for(CICD_JiraProjectNSFEnvironmentMapping__mdt setting : [select id,DeveloperName,CICD_SfDefaultEnvironment__c,CICD_SfDevOrgCredential__c from CICD_JiraProjectNSFEnvironmentMapping__mdt]){
            projectSettings.put(setting.DeveloperName , setting);
        }
        return projectSettings;

    }

    public static set<id> getProjectIds(List<copado__User_Story__c> userStoryRecords){

        set<id> projectIds = new set<id>();
        for(copado__User_Story__c userStory : userStoryRecords){
            projectIds.add(userStory.copado__Project__c);
        }
        return projectIds;

    }

    public static Map<id,copado__Project__c> getProjectRecords(set<id> projectIds){
        return (new Map<id,copado__Project__c>([select id,Name,CICD_JiraProjectKey__c from copado__Project__c where id in :projectIds ]) );
    }
}