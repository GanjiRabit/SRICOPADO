public with sharing class CIJobsTriggerActions extends CommonServices {
    public static void setDefaultValuesIfNull( List<CIJob__c> jobs ){
        try{
            string defaultProject = AccelQConnect.getConfigValue( 'accelQDefaultProject');
        string defaultCIJob = AccelQConnect.getConfigValue( 'accelQDefaultCIJob');
        string defaultRunTimeAttributes = AccelQConnect.getConfigValue( 'accelQDefualtRunTimeAttributes');
        Map<string,string> sobjectTypeField = new Map<String,string>();

        for( CS_IntegrationFieldMapping__c mapping : CS_IntegrationFieldMapping__c.getAll().values()){
            if(mapping.MappingType__c == 'Self' && mapping.SourceAPIName__c != null && mapping.SobjectAPIName__c != null)
            sobjectTypeField.put(mapping.SobjectAPIName__c , mapping.SourceAPIName__c);
        }
        for( CIJOb__c job : jobs){
            if(job.AccelQCIJobId__c == null ) job.AccelQCIJobId__c = defaultCIJob;
            if(job.Project__c == null ) job.Project__c = defaultProject;
            if(job.RunTimeAttributes__c == null ) job.RunTimeAttributes__c = defaultRunTimeAttributes;
            
            if(job.ParentId__c != null){                
                string sobjectType = Id.valueOf(job.ParentId__c).getSobjectType().getDescribe().getName();
                if(sobjectTypeField.get(sobjectType) != null)
                job.put( sobjectTypeField.get(sobjectType) , job.parentId__c );
            }
        }

        }catch(Exception Ex){
            logError( 'CIJobTriggerActions.setDefaults' , Ex);
        }
        
    }

    public static void initiateBatchIfNeeded(){
        try{
            Id initiateBatchClassId = [select Id from ApexClass where Name =: 'AccelQCIJobInitiator' limit 1].id;
            Integer enqueuedJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing','Preparing','Queued') AND ApexClassID =: initiateBatchClassId] ;

            if(enqueuedJobs == 0){
                Database.executeBatch( new AccelQCIJobInitiator() , 1 );
            }

        }catch(Exception Ex){
            logError( 'CIJOBTriggerActions.InitiateAccelqCIJob' , Ex);
        }
            
    }

    public static void notifyParent(List<CIJob__c> jobs ){
        try{


            Map<string,Map<string,string>> sobjectTypeFieldMapping = new Map<String,Map<string,string>>();

            for( CS_IntegrationFieldMapping__c mapping : CS_IntegrationFieldMapping__c.getAll().values()){
                if(mapping.MappingType__c != 'self' && mapping.SobjectAPIName__c != null && mapping.FieldAPIName__c != null && mapping.SourceAPIName__c != null){
                    if(sobjectTypeFieldMapping.get(mapping.SobjectAPIName__c)  == null ){
                        sobjectTypeFieldMapping.put(mapping.SobjectAPIName__c , (new Map<string,string>{
                            mapping.FieldAPIName__c => mapping.SourceAPIName__c 
                        }));
                    }else{
                        sobjectTypeFieldMapping.get(mapping.SobjectAPIName__c).put( mapping.FieldAPIName__c , mapping.SourceAPIName__c );
                    
                }
                }
            }

            List<sobject> sobjectsToUpdate = new List<sobject>();
            for(CIJob__c job : jobs){
                if(job.ParentId__c != null){      
                    schema.sobjectType objectType =  Id.valueOf(job.ParentId__c).getSobjectType();
                    Schema.DescribeSObjectResult objectInfo   = objectType.getDescribe();       
                    string sobjectType = objectInfo.getName();
                    if(sobjectTypeFieldMapping.get(sobjectType) != null){
                        sobject record = objectType.newSObject( job.ParentId__c );
                        Map<string,string> fieldMapping = sobjectTypeFieldMapping.get(sobjectType);
                        for(string fieldAPIName : fieldMapping.keyset() ){
                            record.put( fieldAPIName , job.get( fieldMapping.get(fieldAPIName)  ) );
                        }
                        sobjectsToUpdate.add(record);                        
                    }
                   
                }
            }

            if(sobjectsToUpdate != null && sobjectsToUpdate.size() > 0 ) update sobjectsToUpdate;

        }catch(Exception Ex){
            logError( 'CIJOBTriggerActions.NotifyParent' , Ex);
        }
    }


}