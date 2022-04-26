public class CICD_UserStoriesTriggerHandler implements CICD_TriggerInterface {
    
    public CICD_UserStoriesTriggerHandler(){
        // needed for proper initialization
    }
  
    public void bulkBefore(){
        // place holder
    } 



    public void bulkAfter(){
        // place holder
    }

    public void beforeInsert(){
        
        //remove stories with manual deployment
        List<copado__User_Story__c> stories = CICD_Utils.removeManual(trigger.new);

        //Step - 1
        CICD_UserStoriesTriggerActions.populateOwner( stories );

        //Step - 2       
        CICD_UserStoriesTriggerActions.defaultUsCredentials( stories );
         

    }

    public void beforeUpdate(){

        Map<id,copado__User_Story__c> triggerNewMap = CICD_Utils.removeManualMap((Map<id,copado__User_Story__c>) trigger.newMap);
        Map<id,copado__User_Story__c> triggerOldMap = CICD_Utils.removeManualMap((Map<id,copado__User_Story__c>) trigger.oldMap);

         //Step -1
         CICD_UserStoriesTriggerActions.checkForReopenAndDefault( triggerNewMap, triggerOldMap );

         //Step-2
         CICD_UserStoriesTriggerActions.resetPostDeploymentCheck( triggerNewMap, triggerOldMap ); 

         //Step -3
         CICD_UserStoriesTriggerActions.udpateWorkflowStatus( triggerNewMap, triggerOldMap );
    }

    public void beforeDelete(){
         // place holder
    }

    public void afterInsert(){
        // place holder
    }

    public void afterUpdate(){
        Map<id,copado__User_Story__c> triggerNewMap = CICD_Utils.removeManualMap((Map<id,copado__User_Story__c>) trigger.newMap);
        Map<id,copado__User_Story__c> triggerOldMap = CICD_Utils.removeManualMap((Map<id,copado__User_Story__c>) trigger.oldMap); 
        //Step -1
       if( !System.isBatch() && !System.isQueueable() && !System.isFuture() && !CICD_BatchJob.isSyncFromJira) CICD_UserStoriesTriggerActions.updateJira(triggerNewMap, triggerOldMap );
        
        CICD_UserStoriesTriggerActions.updateServiceNow((Map<id,copado__User_Story__c>) trigger.newMap , (Map<id,copado__User_Story__c>)trigger.OldMap);
    }   

    public void afterDelete(){
         // place holder
    }

    public void afterUnDelete(){
         // place holder
    }

    public void andFinally(){
        // place holder
    }

}