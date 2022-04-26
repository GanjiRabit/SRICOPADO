global class CICD_BatchJob implements 
    Database.Batchable<sObject>, 
    Database.Stateful, 
    Database.AllowsCallouts  {    
    
    global List<String> jiraIds = new List<String>();     
    global List<String> releaseIds = new List<String>();
    global Map<String, String> jiraSfUSMap = new Map<String, String>();
    global List<AppLog__c> appLogs = new List<AppLog__c>();

    global Iterable<sObject> start(Database.BatchableContext bc) {    
        String query = 'SELECT Id, Name, copado__Project__c from copado__Release__c WHERE CICD_SyncRelease__c = true';     
        return Database.query(query);
    }

    global void execute(Database.BatchableContext bc, List<copado__Release__c> records){

        //expecting the batch size to be set to 1 all the time
        syncStoriesFromJira(records[0].Id , records[0].Name , JiraIds , JiraSfUSMap , appLogs , releaseIds);

        
    }    
    global void finish(Database.BatchableContext bc){ 
        
        performPostSyncOperations( JiraIds , JiraSfUSMap , appLogs , releaseIds);
       
    }

    global static void performPostSyncOperations( List<String> JiraIds , Map<String, String> JiraSfUSMap , List<AppLog__c> appLogs ,List<String> releaseIds  ){
        
        CICD_Utils.updateJiraWithSFURL(JiraSfUSMap);
        
        CICD_Utils.cancelDeletedJiras(releaseIds, JiraIds);

        if(appLogs.size() > 0) insert appLogs;

    }

    global static void syncStoriesFromJira(string releaseId , string releaseName , List<String> JiraIds , Map<String, String> JiraSfUSMap , List<AppLog__c> appLogs ,List<String> releaseIds  ){

            ReleaseIds.add(releaseId); 

            List<object> issues = CICD_Utils.getJiraIssues(releaseName);
            
            List<copado__User_Story__c> storiesToUpsert = new List<copado__User_Story__c>();

            if(issues != null && issues.size() > 0){
                for(object issueObject: issues){
                    copado__User_Story__c uStory =  new copado__User_Story__c(
                    copado__Release__c = releaseId
                    );
                    
                    CICD_Utils.prepareSobjectBasedOnJiraConfig( uStory , issueObject); 
                    storiesToUpsert.add(uStory);

                    JiraIds.add(uStory.CICD_JiraIssueId__c);                     
                }
            }

        
            Database.UpsertResult[] upsertResults = Database.upsert( storiesToUpsert, copado__User_Story__c.Fields.CICD_JiraIssueKey__c , false);// upsert cStories CICD_JiraIssueKey__c; 
            integer index = 0;
            for(Database.UpsertResult result : upsertResults){
                if( result.isSuccess() ){
                    if(result.isCreated()) JiraSfUSMap.put( storiesToUpsert[index].CICD_JiraIssueId__c , result.getId() );
                }else{
                    appLogs.add( new AppLog__c( AppCat__c ='CICD Issue Upsert failed for ' + result.getId() , Severity__c ='Trace' , Message__c = result.getErrors()[0].getMessage() +'\n' + JSON.serialize(storiesToUpsert) ) );
                }

                index++;
            }
    }


}