public with sharing class TriggerFactory extends CommonServices{
    public static Map<string,boolean> triggerExecutionCheck;  

    public static void createTriggerHandler(Schema.SobjectType objectType){
        try{
            string sobjectName = objectType.getDescribe().getName();
            
            initiateTriggerExecutionCheck();
            for( TriggerInterface handler : getHandlers(sobjectName)){
                executeTriggerLogic(handler , sobjectName);
            }
                        
        }catch(Exception Ex){
            system.debug('>> ERROR' + EX.getCause());
            system.debug(EX.getStackTraceString());
             logError( 'TriggerFactory.createHandler' , Ex );
        }
        
    }

    public static void executeTriggerLogic(TriggerInterface handler, string sobjectName){

        if(trigger.isBefore && !hasTriggerEventFired(sobjectName , 'before')){
 
            logTriggerExecution(sobjectName , 'before');   
             handler.bulkBefore();         

            //Logic for before insert
            if(trigger.isInsert  ){
                handler.beforeInsert();
            }

            //logic for before udpate
            if(trigger.isUpdate  ){
                handler.beforeUpdate();
            }

            //logic for before delete
            if(trigger.isDelete ){
                handler.beforeDelete();
            }
        }

        if(trigger.isAfter && !hasTriggerEventFired(sobjectName , 'after')){
            logTriggerExecution(sobjectName , 'after');
            handler.bulkAfter();
            
            //Logic for after insert
            if(trigger.isInsert){
                handler.afterInsert();
            }

            //logic for after udpate
            if(trigger.isUpdate){
                handler.afterUpdate();
            }

            //logic for after delete
            if(trigger.isDelete ){
                handler.afterDelete();
            }

            //logic for after undelete
            if(trigger.isUndelete ){
                handler.afterUnDelete();
            }

        }

        //final Execution
        handler.andFinally();
    }

    public static void initiateTriggerExecutionCheck(){
        if(triggerExecutionCheck == null){
            triggerExecutionCheck = new Map<string,boolean>(); 
        }
    }
    public static void logTriggerExecution(string sobjectName , string eventName){
        triggerExecutionCheck.put(sobjectName + eventName , true);
    }

   
    public static boolean hasTriggerEventFired(string sobjectName, string eventName){
        boolean hasFired = triggerExecutionCheck.get(sobjectName + eventName) != null ?  triggerExecutionCheck.get(sobjectName + eventName) : false;

        return hasFired;
    }

    public static List<TriggerInterface> getHandlers(string objectAPIName){
        List<TriggerInterface> handlers = new List<TriggerInterface>();
        try{            
            TriggerInterface handler;
            Type handlerType;
            for( TriggerHandlerMapping__mdt setting : [select HandlerClassName__c from TriggerHandlerMapping__mdt where SobjectApiName__c =:objectAPIName Order By Order__c ASC]){
                
                handlerType = Type.forName( setting.HandlerClassName__c );
                handler = (TriggerInterface) handlerType.newInstance();
                handlers.add( handler);

            }                        

        }catch(Exception ex){
            //Log the exception
            logError( 'TriggerFactory' , Ex);
        }
        
        return handlers;
    }
   
}