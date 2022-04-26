public with sharing class CICD_ReleaseTriggerActions {
   

 public static void handleReleaseUpdate(Map<id,copado__Release__c> newMap , Map<id,copado__Release__c> oldMap){
     Map<id,List<string>> releaseWithNewProjects = new Map<id,List<string>>();
     set<id>releasesWithUpdates = new set<id>();

     List<string> fieldsToTrackForChanges = new List<string> { 'Name' , 'copado__Description__c' , 'CICD_Released__c' , 'copado__Planned_Date__c' , 'CICD_StartDate__c' };

     List<string> projectCodes;
     for(copado__Release__c releaseRecord : newMap.values()){         

         if(releaseRecord.CICD_RelatedProjects__c != oldMap.get(releaseRecord.Id).CICD_RelatedProjects__c){
                projectCodes = new List<string>();

                for(string projectCode: releaseRecord.CICD_RelatedProjects__c.split(';')){
                        if(!oldMap.get(releaseRecord.Id).CICD_RelatedProjects__c.contains(projectCode)) {

                                if(projectCode != 'All') projectCodes.add(projectCode);   
                                else projectCodes.addAll(Label.CICD_DefaultReleaseProjects.split(';'));
                        } 

                }
                if(projectCodes.size () > 0){
                    releaseWithNewProjects.put(releaseRecord.Id , projectCodes);                    
                } 

         }

         for(string fieldName: fieldsToTrackForChanges){
             if(releaseRecord.get(fieldName) != oldMap.get(releaseRecord.Id).get(fieldName)){
                 releasesWithUpdates.add(releaseRecord.Id);                
             } 
         }
     }

     //Update existing release records
    if(releasesWithUpdates.size() > 0 ) updateReleaseInJira(releasesWithUpdates);

     //create release records 
    if(releaseWithNewProjects.size() > 0) createNewReleaseInJira( JSON.serialize( releaseWithNewProjects ));

    


 }

 public static void restrictChangesToRM(List<copado__Release__c> releaseRecords){
     
     boolean isReleaseManager = FeatureManagement.checkPermission('CICD_ReleaseManager');

     for(copado__Release__c releaseRecord: releaseRecords){
         if(!isReleaseManager &&  !Test.isRunningTest() ) releaseRecord.addError('Insufficient Priviliges to manage Releases in Copado. Please Contact System Administrator');
     }
 }

public static void restrictReleaseName(List<copado__Release__c> releaseRecords , set<id> releaseIds){

    

    List<string> releaseNames = new List<string>();

    set<string> existingNames= new set<string>();

    for( copado__Release__c releaseRecord : releaseRecords){
        releaseNames.add(releaseRecord.Name);
    }

    for(AggregateResult result : [select count(id),Name from copado__Release__c where Name IN :releaseNames and ID not IN:releaseIds group by name  having count(id) > 0  ]){
        existingNames.add((string)result.get('Name'));
    }

    for( copado__Release__c releaseRecord : releaseRecords){
        if(existingNames.contains(releaseRecord.Name)) releaseRecord.Name.addError('A record with same name exists. Please choose a different name');
    }



}

public static void restrictProjectSelection(List<copado__Release__c> releaseRecords){

    for(copado__Release__c releaseRecord : releaseRecords){

        if( releaseRecord.CICD_RelatedProjects__c != null && 
        releaseRecord.CICD_RelatedProjects__c.contains('All') && 
        releaseRecord.CICD_RelatedProjects__c.split(';').size() > 1){
           releaseRecord.CICD_RelatedProjects__c.addError('Invalid Project Selection. Option All can not be combined with individual projects');
        }
    }
}

 @future(callout=true)
 public static void createNewReleaseInJira(string newReleaseInformation){

      try{
          
          Map<id,List<string>> releaseWithNewProjects = ( Map<id,List<string>> ) JSON.deserialize(newReleaseInformation,  Map<id,List<string>>.class);
          
          Map<string, List<object>> releaseIdMap = new Map<string, List<object>>();
          
          Map<id,copado__Release__c> releaseRecords = new Map<id,copado__Release__c>([select id,Name,copado__Description__c,CICD_Released__c, copado__Planned_Date__c,CICD_StartDate__c,CICD_RelatedProjects__c,CICD_ReleaseIds__c from copado__Release__c where id in :releaseWithNewProjects.keyset()]);
          
          List<copado__Release__c> releaseRecordsToUpdate = new List<copado__Release__c>();
          List<AppLog__c> appLogs = new List<AppLog__c>();
            

         for( string releaseId : releaseWithNewProjects.keySet() ){

             createReleaseInJiraProject(releaseIdMap , releaseRecords.get(releaseId) , releaseWithNewProjects.get(releaseId));     

             parseReleaseCreationResponse(appLogs , releaseRecordsToUpdate , releaseIdMap , releaseRecords.get(releaseId)  );          

         }

           if(releaseRecordsToUpdate.size() > 0 ) update releaseRecordsToUpdate;

           if(appLogs.size() > 0) insert appLogs;


      }catch(Exception Ex){
          system.debug('>>> ERROR ' + EX.getMessage());
      }
       
 }

  @future(callout=true)
 public static void updateReleaseInJira(set<id> releasesWithUpdates){
     try{
         Map<id,copado__Release__c> releaseRecords = new Map<id,copado__Release__c>([select id,Name,copado__Description__c,CICD_Released__c, copado__Planned_Date__c,CICD_StartDate__c,CICD_RelatedProjects__c,CICD_ReleaseIds__c from copado__Release__c where id in :releasesWithUpdates]);
    
        Map<string, List<object>> releaseIdMap = new Map<string, List<object>>();

        List<AppLog__c> appLogs = new List<AppLog__c>();

        for( copado__Release__c releaseRecord : releaseRecords.values() ){

            updateReleaseInJiraProject(releaseIdMap , releaseRecord ,  releaseRecord.CICD_ReleaseIds__c.split(';'));
            
            parseReleaseCreationResponse(appLogs , new List<copado__Release__c>() , releaseIdMap , releaseRecord );

        }

        if(appLogs.size() > 0 ) insert appLogs;

     }catch(Exception Ex){
         system.debug('>> ERROR ' + Ex.getMessage());
     }
    
 }

 public static void updateReleaseInJiraProject( Map<string, List<object>> releaseIdMap , copado__Release__c releaseRecord , List<string> releaseCodes){
            Map<string,string> headers = new Map<string,string>();
            headers.put('Content-Type','application/json');

          string baseUrl = 'callout:Devops_JiraConnector/api/2/version';
           string endpoint;

            for(string releaseCode : releaseCodes){
                    
                    endpoint = baseUrl + '/' + releaseCode;
                   //target is not bulkified, so the callout is being made in a for loop
                  List<object> releaseResponses =  releaseIdMap.get( releaseRecord.Id ) != null ? releaseIdMap.get( releaseRecord.Id ) : new List<object>();
                  releaseResponses.add(  CICD_Utils.doRestCallout(endpoint, headers, 'PUT',  prepareReleaseRequest(releaseRecord , null) ) );
                  releaseIdMap.put( releaseRecord.Id ,  releaseResponses) ;                  
            }
             
        
}
 /*
    No bulkified api available, so need to be adjusted to a batch job as when bulk operations from release are being made.
 */
    @future(callout=true)
    public static void createReleaseInJira(set<id>releaseIds){
        
        try{

             

           Map<string, List<object>> releaseIdMap = new Map<string,List<object>>();
           List<copado__Release__c> releaseRecordsToUpdate = new List<copado__Release__c>();
           List<AppLog__c> appLogs = new List<AppLog__c>();
            

          for(copado__Release__c releaseRecord : [select id,Name,copado__Description__c,CICD_Released__c, copado__Planned_Date__c,CICD_StartDate__c,CICD_RelatedProjects__c,CICD_ReleaseIds__c from copado__Release__c where id in :releaseIds]){
               List<String> projectCodes =  releaseRecord.CICD_RelatedProjects__c == 'All' ? Label.CICD_DefaultReleaseProjects.split(';') : releaseRecord.CICD_RelatedProjects__c.split(';'); 

                createReleaseInJiraProject(releaseIdMap , releaseRecord , projectCodes);            
                
                parseReleaseCreationResponse(appLogs , releaseRecordsToUpdate , releaseIdMap , releaseRecord );           
            }

             if(releaseRecordsToUpdate.size() > 0 ) update releaseRecordsToUpdate;

             if(appLogs.size() > 0) insert appLogs;



        }catch(Exception Ex){
         System.debug('>> ERROR Processing New Releases ' + Ex.getMessage() + ' >> ids ' + releaseIds);
        }     

    }

    public static void parseReleaseCreationResponse(  List<AppLog__c> appLogs  , List<copado__Release__c> releaseRecordsToUpdate ,  Map<string, List<object>> releaseIdMap , copado__Release__c releaseRecord  ){

          for(string releaseId : releaseIdMap.keyset()){
                string jiraIds = ' ';
                for(object response : releaseIdMap.get(releaseId)){

                    Map<string,object> jiraResponse = (Map<string,object>) response;
                    if( (boolean) jiraResponse.get('isSuccess') && ((Integer) jiraResponse.get('statusCode') == 201 || (Integer) jiraResponse.get('statusCode') == 200) ){
                            string jiraId = (string) CICD_Utils.parseJsonUntyped( (string)jiraResponse.get('message'), 'id');
                            if(jiraId != null) jiraIds += jiraId +  ';';
                    }else{
                        appLogs.add( new AppLog__c(                            
                            Severity__c = 'Trace' , 
                            Message__c = (string)jiraResponse.get('message') , 
                            AppCat__c = 'CICD Release Creation Process for ' + releaseId
                            ) );
                    }
                }

                jiraIds = jiraIds.trim();                
                if(jiraIds.length() > 0 ){
                    jiraIds = releaseRecord.CICD_ReleaseIds__c != null ? releaseRecord.CICD_ReleaseIds__c  + jiraIds : jiraIds;
                    releaseRecordsToUpdate.add(new copado__Release__c(id = releaseId , CICD_ReleaseIds__c = jiraIds));
                }

            }

    }

    public static void createReleaseInJiraProject( Map<string, List<object>> releaseIdMap , copado__Release__c releaseRecord , List<string> projectCodes){
            Map<string,string> headers = new Map<string,string>();
            headers.put('Content-Type','application/json');

          string endpoint = 'callout:Devops_JiraConnector/api/2/version';

            for(string projectCode : projectCodes){
                   //target is not bulkified, so the callout is being made in a for loop
                  List<object> releaseResponses =  releaseIdMap.get( releaseRecord.Id ) != null ? releaseIdMap.get( releaseRecord.Id ) : new List<object>();
                  releaseResponses.add(  CICD_Utils.doRestCallout(endpoint, headers, 'POST',  prepareReleaseRequest(releaseRecord , projectCode) ) );
                  releaseIdMap.put( releaseRecord.Id ,  releaseResponses) ;                  
            }
             
        
    }

    public static string prepareReleaseRequest(copado__Release__c releaseRecord , string projectCode){

        Map<string,object> releaseBody = new Map<string,object>();

        checkForNullAndAdd(releaseRecord , 'Name' , 'name' , releaseBody);
        checkForNullAndAdd(releaseRecord , 'copado__Description__c' , 'description' , releaseBody);
        checkForNullAndAdd(releaseRecord , 'CICD_Released__c' , 'released' , releaseBody);
        checkForNullAndAdd(releaseRecord , 'copado__Planned_Date__c' , 'releaseDate' , releaseBody);
        checkForNullAndAdd(releaseRecord , 'CICD_StartDate__c' , 'startDate' , releaseBody);        
        if(projectCode != null) releaseBody.put('project',projectCode);
        
        return JSON.serialize(releaseBody);
    }

    public static void checkForNullAndAdd(sobject releaseRecord,string field ,string key,Map<string,object> bodyObject){
        set<string> dateFields = new set<string> { 'copado__Planned_Date__c' , 'CICD_StartDate__c' };

        if(releaseRecord.get(field) != null ){
            object value = releaseRecord.get(field);
            if( value != null && dateFields.contains(field)) value = ((Date) value).addDays(1);
            bodyObject.put(key,value);
        }
    }

}