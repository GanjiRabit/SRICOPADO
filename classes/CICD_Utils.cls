Global with sharing class CICD_Utils {
    
    @auraEnabled  @remoteAction    
    Global static Map<string,object> doRestCallout(string endpointUrl, Map<string,string> headerInfo ,string methodType ,string body ){
        
        Map<String,object> response = new Map<string,object>();
        
        try{
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint(endpointUrl);
            req.setMethod(methodType);               
            if(body != null) req.setBody(body);         
            req.setTimeout(120000);
            
            for(string key : headerInfo.keySet()){
                req.setHeader(key , headerInfo.get(key));
            }
            
            Http http = new Http();            
            HTTPResponse res = http.send(req);            
            response =  prepareResponse( true, res.getStatus() ,  res.getStatusCode() , res.getBody() ) ;                        
            
        }catch(Exception ex){
            
            response =  prepareResponse(false, 'CALLOUT_ERROR' , 0 , ex.getMessage());            
            system.debug('>> CICD --- ERROR CALLING OUT << ' + ex.getMessage() + ' >> ' + ex.getTypeName());
        }
        
        return response;        
        
    }
    
    @auraEnabled
    global static string getIncidentFromSNOw(string recordId){
        Map<String,object> response;
        try{
            copado__User_Story__c story = [select Name,CICD_JiraIssueId__c from copado__User_Story__c where id=: recordId ];            
            string url = 'callout:ServiceNow_Connect/incident/'  + story.CICD_JiraIssueId__c;
            Map<String,string> headerInfo = new Map<String,string>{ 'Content-Type' => 'application/json'} ;
                response =  CICD_Utils.doRestCallout(url , headerInfo, 'GET', null );
            
            if( (boolean) response.get('isSuccess') && (Integer) response.get('statusCode') == 200){
                
                object issue = (object) parseJsonUntyped( (string) response.get('message') , 'result');
                 List<copado__User_Story__c> userStories = new List<copado__User_Story__c>();
                copado__User_Story__c userStory;
                
                
                    userStory = new copado__User_Story__c();
                    userStory.copado__User_Story_Title__c = (string) getNodeFromDeserialziedObject(issue, 'short_description');
                    userStory.Description__c = (string) getNodeFromDeserialziedObject( issue, 'description');
                    userStory.CICD_JiraIssueId__c = (string) getNodeFromDeserialziedObject( issue, 'sys_id');
                                        userStory.Snow_Stage__c =  (string) getNodeFromDeserialziedObject( issue, 'state');

					userStories.add(userStory);
                    
              
                
                upsert userStories CICD_JiraIssueId__c;
                
            }else{
                insert new AppLog__c( AppCat__c ='CICD Jira Issue Sync Failed for release ' + story.Name , Severity__c ='Trace' , Message__c = (string) response.get('message')  );        
            }
            
            response = prepareResponse( true, null , null , null);
            
            
        }catch(exception ex){
            response = prepareResponse( false, null , null , Ex.getMessage());
        }
        
        
        return JSON.serialize(response);
    }
    @auraEnabled
    global static string getIncidentsFromSNow(string recordId){
        Map<String,object> response;
        try{
            List<object> issues = new List<object>();
            copado__Release__c release = [select Name from copado__Release__c where id=: recordId ];
            string query = EncodingUtil.urlEncode('u_release=' + release.Name, 'UTF-8');
            string url = 'callout:ServiceNow_Connect/incident?sysparm_query='  + query;
            Map<String,string> headerInfo = new Map<String,string>{ 'Content-Type' => 'application/json'} ;
                response =  CICD_Utils.doRestCallout(url , headerInfo, 'GET', null );
            
            if( (boolean) response.get('isSuccess') && (Integer) response.get('statusCode') == 200){
                
                issues = (list<object>) parseJsonUntyped( (string) response.get('message') , 'result');
                 List<copado__User_Story__c> userStories = new List<copado__User_Story__c>();
                copado__User_Story__c userStory;
                
                for( object issue : issues){
                    userStory = new copado__User_Story__c();
                    userStory.copado__Release__c = release.Id;
                    userStory.copado__User_Story_Title__c = (string) getNodeFromDeserialziedObject(issue, 'short_description');
                    userStory.Description__c = (string) getNodeFromDeserialziedObject( issue, 'description');
                    userStory.CICD_JiraIssueId__c = (string) getNodeFromDeserialziedObject( issue, 'sys_id');
                    userStory.Snow_Stage__c =  (string) getNodeFromDeserialziedObject( issue, 'state');
					userStories.add(userStory);
                    
                }
                
                upsert userStories CICD_JiraIssueId__c;
                
            }else{
                insert new AppLog__c( AppCat__c ='CICD Jira Issue Sync Failed for release ' + release.Name , Severity__c ='Trace' , Message__c = (string) response.get('message')  );        
            }
            
            response = prepareResponse( true, null , null , null);
            
            
        }catch(exception ex){
            response = prepareResponse( false, null , null , Ex.getMessage());
        }
        
        
        return JSON.serialize(response);
    }
    
    global static Map<string,object> prepareResponse(boolean isSuccess, string status , integer statusCode, string message){
        Map<String,object> response = new Map<string,object>();
        response.put('isSuccess' , isSuccess);
        response.put('status' , status);
        response.put('statusCode' , StatusCode);
        response.put('message' , message);
        return response;
    }
    
    global static object parseJsonUntyped(string jsonBody , string jsonNodePath ){
        object nodeToReturn = JSON.deserializeUntyped(jsonBody);
        try{
            
            nodeToReturn = getNodeFromDeserialziedObject( nodeToReturn , jsonNodePath);
            
        }catch(Exception Ex){
            System.debug('>> Unable to Process Json body >> ' + jsonBody +' >> ' + jsonNodePath );
            nodeToReturn = '';
        }
        return nodeToReturn;
    }
    
    global static object getNodeFromDeserialziedObject(object jsonObject , string jsonNodePath){
        
        object nodeToReturn = (map<string,object>)  jsonObject;
        
        System.debug('>> jsonObject >> ' + jsonObject  +' >> ' +  jsonNodePath);
        
        
        try{
            
            List<string> nodes = jsonNodePath.split('\\.');
            for(integer index =0 ;index < nodes.size(); index++){
                if(nodeToReturn == null) break;
                nodeToReturn = ( (map<string,object>) nodeToReturn ).get(nodes[index]);       
                
                System.debug('>> nodeToReturn >> ' + nodeToReturn  +' >> ' +  index);
                
            }
            
        }catch(Exception ex){
            System.debug('>> Unable to Process Json body >> ' + jsonNodePath + jsonObject +' >> ');
            system.debug('>> EXCEPTION ' + ex.getMessage());
            nodeToReturn = null;
        }
        return nodeToReturn;
    }
    
    global static void prepareSobjectBasedOnJiraConfig(sobject record,  object jiraFieldsInformation){
        try{
            sobject parentRecord;
            string parentExternalId, lookupField , sobjectType = string.valueOf(record.getSObjectType());
            set<String>exemptNodes = new set<string>{ 'id' , 'key'};
                string node;
            for(CICD_JiraSyncConfiguration__mdt setting : Database.query( prepareSettingQuery( sobjectType , record , true , jiraFieldsInformation , false ) ) ){
                
                node = exemptNodes.contains(setting.CICD_JiraIssueFieldName__c) ? setting.CICD_JiraIssueFieldName__c : 'fields.' + setting.CICD_JiraIssueFieldName__c;
                
                if(setting.CICD_ParentObject__c != null){
                    parentRecord = Schema.getGlobalDescribe().get(setting.CICD_ParentObject__c).newSObject();                                                                
                    parentExternalId = setting.CICD_SfFieldApiName__c.split('\\.')[1];                                
                    lookupField = (setting.CICD_SfFieldApiName__c.split('\\.')[0]); //.replace('__r' , '__c');                                
                    parentRecord.put(parentExternalId , getNodeFromDeserialziedObject( jiraFieldsInformation, node) );
                    record.putSObject(lookupField, parentRecord);
                }else{
                    
                    
                    record.put( setting.CICD_SfFieldApiName__c ,  string.valueOf( getNodeFromDeserialziedObject( jiraFieldsInformation , node)) );
                }                       
                
            }
            
            system.debug(' >>> record ' + record);
            
        }catch(Exception ex){
            system.debug('>> UNABLE TO GENERATE SOBJECT >> ' + record +' >> '+ jiraFieldsInformation);
            system.debug('>> EXCEPTOION >> ' + ex.getMessage());
        }
    }
    
    global static string prepareSettingQuery(string sobjectType, sobject recordData , boolean syncFromJira , object jiraFieldsInformation , boolean isTransition){
        string query ='select id,DeveloperName,CICD_ParentObject__c,CICD_SfFieldApiName__c,CICD_JiraIssueFieldName__c from CICD_JiraSyncConfiguration__mdt where CICD_SfObjectApiName__c=\'' + sobjectType + '\'' ;
        
        // if sync from jira, get only sync from jira settings
        // if sync to jira, based on whether the status field is being updated or not, get required settings
        query += syncFromJira ? ' and CICD_SyncFromJira__c = true ' : isTransition ?  ' and CICD_SyncToJira__c = true and  CICD_JiraIssueFieldName__c  LIKE \'status.%\' ' : ' and CICD_SyncToJira__c = true and  ( NOT CICD_JiraIssueFieldName__c  LIKE \'status.%\' ) ';
        List< CICD_JiraSyncVariation__mdt>  variations = [select CICD_SfFieldApiName__c ,CICD_JiraIssueFieldName__c from CICD_JiraSyncVariation__mdt where CICD_SfObjectApiName__c = :sobjectType ];
        
        if(variations != null && variations.size() > 0){
            for( CICD_JiraSyncVariation__mdt variation : variations){
                query += ' and CICD_SyncVariationKey__c = \'' + ( syncFromJira ? (string) getNodeFromDeserialziedObject( jiraFieldsInformation, variation.CICD_JiraIssueFieldName__c) : (string) getSobjectValue(recordData , variation.CICD_SfFieldApiName__c) ) + '\'';
            }        
        }else{
            query += ' and CICD_SyncVariationKey__c = null ';
        }
        
        
        system.debug('>>> final setting query  ' + query);
        
        return query;
    }
    
    global static string prepareJiraUserStoryRequest(sobject record , boolean isTransition){
        Map<string,object> request = new Map<String,object>();         
        Map<string,object> fields = new Map<String,object>();      
        try{
            
            string  sobjectType = string.valueOf(record.getSObjectType());
            
            for(CICD_JiraSyncConfiguration__mdt setting :  Database.query( prepareSettingQuery(sobjectType , record , false , null , isTransition) ) ){
                
                if(!isTransition) addFieldToRequest( fields , record , setting.CICD_JiraIssueFieldName__c ,setting.CICD_SfFieldApiName__c );
                else fields.put( 'id' ,   getTransitionId( record , (string) CICD_Utils.getSobjectValue( record ,  setting.CICD_SfFieldApiName__c ) ) );
            }
            
        }catch(Exception ex){
            System.debug( '>> EXCEPTION PREPARING US REQUEST >> ' + ex.getMessage() );
        }
        
        
        request.put( isTransition ? 'transition' : 'fields' , fields);
        
        system.debug('>> request >> ' + request);
        return JSON.serialize(request);
    }
    
    global static string getTransitionId( sobject record , string transitionName ){
        string transitionId;
        try{
            string endPoint =  'callout:Devops_JiraConnector/api/2/issue/' + (string) record.get('CICD_JiraIssueId__c') + '/transitions';
            
            Map<string,string> headerInfo = new Map<String,string>();
            headerInfo.put('Content-Type','application/json');
            
            Map<string,object> transitionAPIResponse = doRestCallout( endPoint  , headerInfo , 'GET', null );
            if( (boolean) transitionAPIResponse.get('isSuccess') ){
                List< object > transitions =  (List< object >) parseJsonUntyped( (string) transitionAPIResponse.get('message') , 'transitions' ); 
                for( object transitionObject : transitions){
                    Map<string,object> transition = ( Map<string,object> ) transitionObject;
                    system.debug( '>> name ' + (string) transition.get('name') + ' transition name ' + transitionName);
                    if( ((string) transition.get('name')).startsWith(transitionName)){
                        transitionId = (string) transition.get( 'id' );
                        break;
                    }
                }
            }
            
        }catch(exception ex){
            System.debug(  ' Unable to find transition for record ' + record.get('id') + ' ' + ex.getMessage() );
        }
        
        return transitionId;
    }
    
    global static void addFieldToRequest( Map<string,object> fields, sobject record , string fieldPathInJira , string fieldPathInRecord){
        
        if(fieldPathInJira.contains('.')){
            List<string> fieldsInJira = fieldPathInJira.split('\\.');
            Map<string,object> fieldObject = new Map<string,object>(); 
            
            for( integer i = fieldsInJira.size() ; i > 0 ; i--){  
                
                
                if(i == fieldsInJira.size()){
                    fieldObject = new Map<string,object>{
                        fieldsInJira[i-1] => getSobjectValue(record , fieldPathInRecord) 
                            }; 
                                
                                }else{
                                    Map<string,object> tmpObj = (Map<string,object>) JSON.deserializeUntyped( JSON.serialize( fieldObject )) ;
                                    fieldObject = new Map<string,object>{
                                        fieldsInJira[i-1] => tmpObj
                                            };                  
                                                }
                
                system.debug( '>>>' +  i + ' >> ' + fieldsInJira[i-1] +' >> ' + fieldObject);
                
            }
            
            fields.put( fieldsInJira[0] ,  fieldObject.get(fieldsInJira[0]) );
            
        }else{
            fields.put(fieldPathInJira , getSobjectValue(record , fieldPathInRecord) );
        }
        
    }
    
    global static object getSobjectValue(object record, string fieldPath){
        object value = record;
        system.debug('>> Obtaining data from ' + record + ' >>  for field ' + fieldPath);
        if(fieldPath.contains('.')){
            List<string> fields = fieldPath.split('\\.');
            string field;
            for(integer i =0 ; i < fields.size() ; i++){
                field = fields[i];                
                if(field.endsWith('__r')){
                    if(value!= null) value = ( (sobject) value ).getSobject(field);
                }else{
                    if(value!= null) value = ( (sobject) value ).get(field);
                }
                
                system.debug('>>> iteration ' + i +' >> value ' + value +' >> field ' + fields[i]);
                
            }
            
        }else{
            value = ((sobject)record).get(fieldPath);
        }
        
        return value;
    }
    
    global static List<object> getJiraIssues(String releaseName){
        
        List<object> issues = new List<object>();
        try{
            
            Map<string,string> headerInfo = new Map<string,string>();
            headerInfo.put('Content-Type','application/json');
            
            String searchQuery = ENCODINGUTIL.URLENCODE( 'fixVersion=\'' + releaseName + '\'', 'UTF-8');
            String url = 'callout:Devops_JiraConnector/api/2/search?jql=' + searchQuery; 
            
            
            Map<string,object> response =  CICD_Utils.doRestCallout(url , headerInfo, 'GET', null );
            
            if( (boolean) response.get('isSuccess') && (Integer) response.get('statusCode') == 200){
                
                issues = (list<object>) parseJsonUntyped( (string) response.get('message') , 'issues');
               
            }else{
                insert new AppLog__c( AppCat__c ='CICD Jira Issue Sync Failed for release ' + releaseName , Severity__c ='Trace' , Message__c = (string) response.get('message')  );        
            }
            
            
        }catch(Exception ex){
            insert new AppLog__c( AppCat__c ='CICD Jira Issue Sync Failed for release ' + releaseName , Severity__c ='Trace' , Message__c = ex.getMessage() );
        }
        
        
        
        return  issues; 
    }
    
    global static void updateJiraWithSFURL(Map<String, String> JiraSfUSMap){
        Map<string,Map<String,object>> jiraSyncResponse = new Map<string,Map<string,object>>();
        for(String key : JiraSfUSMap.keySet()){
            
            String jiraKey = key;
            String sfId = JiraSfUSMap.get(key);
            
            Map<string,string> hdrs = new Map<string,string>();
            hdrs.put('Content-Type','application/json');
            
            String sfUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+sfId; 
            Map<string,object> jiraRequest = new Map<String,object>();
            Map<string,object> fields = new Map<String,object>();      
            
            fields.put('customfield_10027' , sfUrl);
            
            jiraRequest.put('fields' , fields);  
            
            String issueId = ENCODINGUTIL.URLENCODE( jiraKey, 'UTF-8');
            String putUrl = 'callout:Devops_JiraConnector/api/2/issue/'+issueId; 
            
            jiraSyncResponse.put(  sfId , doRestCallout(  putUrl, hdrs, 'PUT', JSON.serialize(jiraRequest) ) ); 
            
            parseResponseAndLogErrors(jiraSyncResponse);
            
        } 
        
    }
    
    global static void cancelDeletedJiras(List<String> ReleaseIds, List<String> JiraIds){
        
        List<copado__User_Story__c> storiesToDelete = [SELECT 
                                                       Id, 
                                                       Name, 
                                                       copado__Release__c, 
                                                       CICD_JiraIssueKey__c 
                                                       FROM copado__User_Story__c 
                                                       WHERE copado__Release__c IN: ReleaseIds 
                                                       AND CICD_JiraIssueId__c 
                                                       NOT IN: JiraIds
                                                      ];
        
        for(copado__User_Story__c delStory : storiesToDelete){
            delStory.copado__Status__c = 'Cancelled'; 
            delStory.copado__Cancellation_Reason__c = delStory.CICD_JiraIssueKey__c + ' was deleted in Jira';
        }
        
        if(storiesToDelete.size() > 0){
            update storiesToDelete;
        }
        
    }
    
    
    global static void parseResponseAndLogErrors( Map<string,map<string,object>>userStoryResponse ){
        
        List<AppLog__c> appLogs = new List<AppLog__c>();
        
        try{
            
            for( string storyId : userStoryResponse.keySet() ){
                
                if( (boolean) userStoryResponse.get(storyId).get('isSuccess') && (integer) userStoryResponse.get(storyId).get('statusCode') == 204 ){
                    //do nothing
                }else{
                    appLogs.add(new AppLog__c( AppCat__c = 'CICD User Story Sync for ' + storyId , Severity__c ='Trace' ,  Message__c = string.valueof(userStoryResponse.get(storyId).get('message'))) );
                }
            }
        }catch(Exception ex){
            appLogs.add(new AppLog__c( AppCat__c = 'CICD User Story Sync' , Severity__c ='Trace' ,  Message__c = Ex.getMessage() ));
        }
        
        
        
        
        if(appLogs.size() > 0 ) insert appLogs;
    }
    
    global static List<RecordType> getRecordTypeId(String recType){
        List<RecordType> recTypes = [SELECT Id from RecordType WHERE Name =: recType];
        return recTypes;
    }
    
    global static List<copado__User_Story__c> removeManual(List<copado__User_Story__c> stories){
        
        List<copado__User_Story__c> storiesFinal = new List<copado__User_Story__c>(); 
        List<RecordType> rectypes = getRecordTypeId('Manual Deployment');
        
        if(rectypes.size() > 0){            
            for(copado__User_Story__c story : stories)  {
                if(story.RecordTypeId != rectypes[0].Id){                     
                    storiesFinal.add(story);
                }                
            }
        }else{
            storiesFinal = stories;
        }
        
        return storiesFinal;
        
    }
    
    global static Map<id,copado__User_Story__c> removeManualMap(Map<id,copado__User_Story__c> storiesMap){
        
        Map<id,copado__User_Story__c> storiesFinal = new Map<id,copado__User_Story__c>(); 
        List<RecordType> rectypes = getRecordTypeId('Manual Deployment');
        
        if(rectypes.size() > 0){         
            for(String Id : storiesMap.keyset())  {
                if(storiesMap.get(Id).RecordTypeId != rectypes[0].Id){                     
                    storiesFinal.put(Id, storiesMap.get(Id));
                }                
            }
        }else{
            storiesFinal = storiesMap;
        }
        
        return storiesFinal;
        
    }
    
    
    
    
}