public with sharing class CICD_PromotionTriggerActions {
    public static void updateUserStoriesWithPromotionStatus(Map<id,copado__Promotion__c> newMap , Map<id,copado__Promotion__c> oldMap){

        try{
            List<id> statusChangedIds = new List<id>();
            List<copado__User_Story__c> userStoriesToUpdate = new List<copado__User_Story__c>();

            for(copado__Promotion__c promotion : newMap.values()){
                if(promotion.copado__Status__c != oldMap.get(promotion.id).copado__Status__c) statusChangedIds.add(promotion.id);
            }

            for(copado__Promoted_User_Story__c promotedStory : [select id,copado__User_Story__c,copado__Promotion__c from copado__Promoted_User_Story__c where copado__Promotion__c in :statusChangedIds]){
                userStoriesToUpdate.add(new copado__User_Story__c(
                    id = promotedStory.copado__User_Story__c,
                    CICD_LastDeploymentStatus__c = newMap.get(promotedStory.copado__Promotion__c).copado__Status__c
                ));
            }

            
            if(userStoriesToUpdate.size() > 0 ) Update userStoriesToUpdate;


        }catch(Exception ex){

            if(newMap != null && newMap.values() != null)  CICD_TriggerFactory.propagateError( newMap.values() , ex.getMessage() );

        }
  
    }
}