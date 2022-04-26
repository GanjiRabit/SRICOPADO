public class CICD_TriggerFactory {

    public static Map<string,boolean> triggerExecutionCheck;  

    public static void createTriggerHandler(Schema.SobjectType objectType){
        try{
            string sobjectName = objectType.getDescribe().getName();
            CICD_TriggerInterface handler = getHandler(sobjectName);
            initiateTriggerExecutionCheck();
            if(handler != null){
                executeTriggerLogic(handler , sobjectName);
            }else{
                throw new TypeException('INVALID HANDLER');
            }

        }catch(Exception Ex){
            system.debug('>> ERROR' + EX.getCause());
            system.debug(EX.getStackTraceString());
             propagateError(trigger.new, 'FATAL: Could not  locate appropriate Trigger Handler. Contact System  Administrator');
        }
        
    }

    public static void executeTriggerLogic(CICD_TriggerInterface handler, string sobjectName){

        if(trigger.isBefore && !hasTriggerEventFired(sobjectName , 'before')){
 
            logTriggerExecution(sobjectName , 'before');   
             if( canMethodBeFired(handler , 'bulkBefore')  ) handler.bulkBefore();         

            //Logic for before insert
            if(trigger.isInsert && canMethodBeFired(handler , 'beforeInsert') ){
                handler.beforeInsert();
            }

            //logic for before udpate
            if(trigger.isUpdate  && canMethodBeFired(handler , 'beforeUpdate')){
                handler.beforeUpdate();
            }

            //logic for before delete
            if(trigger.isDelete && canMethodBeFired(handler , 'beforeDelete')){
                handler.beforeDelete();
            }
        }

        if(trigger.isAfter && !hasTriggerEventFired(sobjectName , 'after')){
            logTriggerExecution(sobjectName , 'after');
            if(canMethodBeFired(handler , 'bulkAfter')) handler.bulkAfter();
            
            //Logic for after insert
            if(trigger.isInsert && canMethodBeFired(handler , 'afterInsert')){
                handler.afterInsert();
            }

            //logic for after udpate
            if(trigger.isUpdate && canMethodBeFired(handler , 'afterUpdate')){
                handler.afterUpdate();
            }

            //logic for after delete
            if(trigger.isDelete && canMethodBeFired(handler , 'afterDelete')){
                handler.afterDelete();
            }

            //logic for after undelete
            if(trigger.isUndelete && canMethodBeFired(handler , 'afterUnDelete')){
                handler.afterUnDelete();
            }

        }

        //final Execution
        if(canMethodBeFired(handler , 'andFinally')) handler.andFinally();
    }

    public static void initiateTriggerExecutionCheck(){
        if(triggerExecutionCheck == null){
            triggerExecutionCheck = new Map<string,boolean>(); 
        }
    }
    public static void logTriggerExecution(string sobjectName , string eventName){
        triggerExecutionCheck.put(sobjectName + eventName , true);
    }


    public static boolean canMethodBeFired(CICD_TriggerInterface handler, string methodName){
        Boolean canBeFired = true;
        try{
            String className = String.valueOf(handler).substring(0,String.valueOf(handler).indexOf(':'));
            TriggerDisabled__mdt config = [select id,isDisabled__c FROM TriggerDisabled__mdt where isDisabled__c= true and TriggerName__c =: className and MethodName__c=:methodName ];
            canBeFired = config != null ? false : true;
        }catch(Exception ex){

        }

        return canBeFired;
    }

    public static boolean hasTriggerEventFired(string sobjectName, string eventName){
        boolean hasFired = triggerExecutionCheck.get(sobjectName + eventName) != null ?  triggerExecutionCheck.get(sobjectName + eventName) : false;

        return hasFired;
    }

    public static CICD_TriggerInterface getHandler(string objectAPIName){
        CICD_TriggerInterface handler;
        try{
            
            string handlerName = [select CICD_HandlerClass__c from CICD_SobjectTriggerHandlerMapping__mdt where CICD_SobjectName__c =:objectAPIName  limit 1].CICD_HandlerClass__c;

            Type handlerType = Type.forName(handlerName);

            handler = (CICD_TriggerInterface) handlerType.newInstance();

        }catch(Exception ex){
            //Log the exception
            propagateError(trigger.new, 'FATAL: Could not  locate appropriate Trigger Handler. Contact System  Administrator');
        }
        
        return handler;
    }

    public static void propagateError(List<sobject> recordList, string message){
        recordList = recordList == null ? new List<sobject>() : recordList;
        for(Sobject record: recordList){
            record.addError(message);
        }
    }
}