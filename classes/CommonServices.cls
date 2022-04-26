public abstract with sharing class CommonServices {
    
    public static void logError( string classProcessName , Exception Ex){
        try{
            CIJobLogs__c log = new CIJobLogs__c();
            log.ClassProcessName__c = classProcessName;
            log.Type__c = Ex.getTypeName();
            log.Line__c = String.valueOf(Ex.getLineNumber());
            log.Message__c = Ex.getMessage();
            log.StackTrace__c = Ex.getStackTraceString();
            insert log;
        }catch(Exception logException){
            logError('CommonServices.logError' , logException);
        }        

    }
}