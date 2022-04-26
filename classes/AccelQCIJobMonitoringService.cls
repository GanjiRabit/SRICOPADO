global with sharing class AccelQCIJobMonitoringService implements Database.batchable<sobject>,Database.AllowsCallouts , Database.Stateful{
    global final String Query;
    global  Map<string,string> tokens;
    global  string endPoint;
    global AccelQCIJobMonitoringService(){
        query = 'Select id,Project__c,Status__c,TotalTestCases__c,StatusUpdatedOn__c,JobStartedOn__c,JobCompletedOn__c,RunTimeAttributes__c,ParentId__c,CIJobInstanceId__c,AccelQCIJobId__c,TestCasesPassed__c,TestCasesNotRun__c,TestCasesFailed__c from CIJob__c where CIJobInstanceId__c != null and Status__c != \'Complete\'';              
        endPoint =  AccelQConnect.getEndpoint();
    }
    global AccelQCIJobMonitoringService(Map<string,string> tokens){
    	this();
        this.tokens =tokens;
    }
    
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }  
    global void execute(Database.BatchableContext info, List<CIJob__c> jobs){
        try{
            If(tokens == null)  tokens = AccelQConnect.getAccessToken();
            for(CIJob__c job : jobs){
               AccelQConnect.monitorJob( endPoint , tokens , job );
            }
        }catch(Exception Ex){
            CommonServices.logError('AccelQJobInitiator batch', Ex);
        }
      
        
    }     
    global void finish(Database.BatchableContext info){   
       //do nothing
    } 
}