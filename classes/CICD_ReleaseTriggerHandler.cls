public class CICD_ReleaseTriggerHandler implements CICD_TriggerInterface {
    
    public CICD_ReleaseTriggerHandler(){
        // needed for proper initialization
    }
  
    public void bulkBefore(){
        // place holder
    } 

    public void bulkAfter(){
        // place holder
    }

	public void beforeInsert(){
        //Step -1 check if user is release Manager
        CICD_ReleaseTriggerActions.restrictChangesToRM(trigger.new);

        // Step -2
        CICD_ReleaseTriggerActions.restrictProjectSelection(trigger.new);

        //Setp -3
        CICD_ReleaseTriggerActions.restrictReleaseName( trigger.new , new set<id>());
    }

	public void beforeUpdate(){
        //Step -1 check if user is release Manager
        CICD_ReleaseTriggerActions.restrictChangesToRM(trigger.new);

        // Step -2
         CICD_ReleaseTriggerActions.restrictProjectSelection(trigger.new);

        //Setp -3
        CICD_ReleaseTriggerActions.restrictReleaseName( trigger.new , trigger.newMap.keyset());
    }

	public void beforeDelete(){         
         //Step -1 check if user is release Manager
        CICD_ReleaseTriggerActions.restrictChangesToRM(trigger.new);
    }

	public void afterInsert(){
         //Step 1
         CICD_ReleaseTriggerActions.createReleaseInJira(trigger.newMap.keyset() );
    }

	public void afterUpdate(){
        //Step 1
       CICD_ReleaseTriggerActions.handleReleaseUpdate( (Map<id,copado__Release__c>) trigger.newMap , (Map<id,copado__Release__c>) trigger.oldMap);
    }   

	public void afterDelete(){
         // place holder
    }

    public void afterUnDelete(){
         // place holder
    }

    public void andFinally(){

    }

}