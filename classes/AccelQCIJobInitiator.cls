global with sharing class AccelQCIJobInitiator implements Database.batchable<sobject>,Database.AllowsCallouts , Database.Stateful{
    global final String Query;
    global  Map<string,string> tokens;
    global final string endPoint;

    global AccelQCIJobInitiator(){
        query = 'Select id,Project__c,Status__c,RunTimeAttributes__c,ParentId__c,CIJobInstanceId__c,AccelQCIJobId__c from CIJob__c where CIJobInstanceId__c = null and Status__c = \'Created\'';
        endPoint =  AccelQConnect.getEndpoint();
    }
    global AccelQCIJobInitiator(Map<string,string> tokens){
          this();
        this.tokens = tokens;
      
    }
    
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }  
    global void execute(Database.BatchableContext info, List<CIJob__c> jobs){
        try{
            system.debug('>>>> END POINT <<< ' + endPoint);
            If(tokens == null)  tokens = AccelQConnect.getAccessToken();           
            for(CIJob__c job : jobs){
               AccelQConnect.initiateJob( endPoint , tokens , job );
            }
        }catch(Exception Ex){
            CommonServices.logError('AccelQJobInitiator batch', Ex);
        }
      
        
    }     
    global void finish(Database.BatchableContext info){   
        List<CIJob__c> jobs = Database.Query(query);

        if(jobs.size() > 0){
            //Database.executeBatch( new AccelQCIJobInitiator() , 50 );
        }
    } 

}