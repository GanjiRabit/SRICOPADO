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
         //Step - 1
         CICD_UserStoriesTriggerActions.populateOwner( trigger.new );

         //Step - 2       
         CICD_UserStoriesTriggerActions.defaultUsCredentials( trigger.new );
         

    }

    public void beforeUpdate(){
         //Step -1
         CICD_UserStoriesTriggerActions.checkForReopenAndDefault( (Map<id,copado__User_Story__c>) trigger.newMap, (Map<id,copado__User_Story__c>) trigger.oldMap );

         //Step-2
         CICD_UserStoriesTriggerActions.resetPostDeploymentCheck( (Map<id,copado__User_Story__c>) trigger.newMap, (Map<id,copado__User_Story__c>) trigger.oldMap  ); 

         //Step -3
         CICD_UserStoriesTriggerActions.udpateWorkflowStatus( (Map<id,copado__User_Story__c>) trigger.newMap, (Map<id,copado__User_Story__c>) trigger.oldMap );
    }

    public void beforeDelete(){
         // place holder
    }

    public void afterInsert(){
        // place holder
    }

    public void afterUpdate(){
        //Step -1
       if( !System.isBatch() && !System.isQueueable() && !System.isFuture() ) CICD_UserStoriesTriggerActions.updateJira( (Map<id,copado__User_Story__c>) trigger.newMap, (Map<id,copado__User_Story__c>) trigger.oldMap );
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