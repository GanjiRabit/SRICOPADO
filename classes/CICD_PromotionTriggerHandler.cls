public class CICD_PromotionTriggerHandler implements CICD_TriggerInterface {
    
    public CICD_PromotionTriggerHandler(){
        // needed for proper initialization
    }
  
    public void bulkBefore(){
        // place holder
    } 

    public void bulkAfter(){
        // place holder
    }

	public void beforeInsert(){
         // place holder
    }

	public void beforeUpdate(){
         // place holder
    }

	public void beforeDelete(){
         // place holder
    }

	public void afterInsert(){
     
     
    }

	public void afterUpdate(){
      //Step -1 
      CICD_PromotionTriggerActions.updateUserStoriesWithPromotionStatus( (Map<id,copado__Promotion__c>) trigger.newMap, (Map<id,copado__Promotion__c>) trigger.oldMap);
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