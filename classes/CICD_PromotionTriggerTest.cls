@isTest(seeAllData = true)
public  class CICD_PromotionTriggerTest {
    
    public static testMethod void testStatusUpdate(){
        try{
            Test.startTest();
            
            copado__Deployment_Flow__c  deploymentFlow = [select id from copado__Deployment_Flow__c where Name=:Label.CICD_DeploymentFlowNameForTestClass limit 1];
            
            copado__Project__c projectRecord = (copado__Project__c) CICD_TestFactory.createSObject(new copado__Project__c(
                copado__Deployment_Flow__c = deploymentFlow.id
            ));
            insert projectRecord;
            
            copado__User_Story__c userStoryRecord = (copado__User_Story__c) CICD_TestFactory.createSObject(new copado__User_Story__c( 
                copado__Promote_and_Deploy__c = true,
                copado__Project__c = projectRecord.id
            ));            
            insert userStoryRecord;
            
            
            
            copado__Org__c orgCredential =  [select id,copado__Environment__c from copado__Org__c where copado__userName__c LIKE :Label.CICD_CredentialsForTestClass limit 1];
            
            
            copado__Promotion__c promotionRecord = (copado__Promotion__c) CICD_TestFactory.createSObject(new copado__Promotion__c(                    
                copado__Project__c = projectRecord.id,            
                copado__Back_Promotion__c = false,
                copado__Source_Environment__c = orgCredential.copado__Environment__c,
                copado__Source_Org_Credential__c = orgCredential.id,                    
                copado__Status__c = 'CICD_PromotionTriggerTest'
                
            ));
            insert promotionRecord;
            
            copado__Promoted_User_Story__c promotedUsRecord = (copado__Promoted_User_Story__c) CICD_TestFactory.createSObject(new copado__Promoted_User_Story__c(
                copado__Promotion__c = promotionRecord.id,
                copado__User_Story__c = userStoryRecord.id
            ));
            insert promotedUsRecord;
            
            CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
            
            promotionRecord.copado__Status__c = 'In Progress';
            update promotionRecord;
            
            CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
            delete promotionRecord;
            
            CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
            undelete promotionRecord;
            
            //additional coverage
            CICD_PromotionTriggerActions.updateUserStoriesWithPromotionStatus(null, null);
            
            
            //-------CICD_Contoller methods-------//
            CICD_Controller.deployPromotion(promotionRecord.id, 'false', 'Release Name', 'INT', 'RunSpecifiedTests');
            CICD_Controller.getLatestDeployment(promotionRecord.id);   
            
            
            Test.stopTest();
        }catch(Exception ex){
            System.debug( '>> Test Setup failed >> ' + ex.getMessage());
        }
        
        
        
    }
    
    public static testMethod void testPromoteStories(){
        try{
            Test.startTest();
            
            copado__Release__c rel = [SELECT Id, Name from copado__Release__c LIMIT 1];
            List<copado__User_Story__c> stories = [SELECT Id, Name from copado__User_Story__c LIMIT 1];         
            
            List<String> storyIds = new List<String>();
            
            for(copado__User_Story__c story : stories){
                storyIds.add(story.Id);
            }
            
            String storyIdStr = JSON.serialize(storyIds);
            
            CICD_Controller.promoteStories(storyIdStr, rel.Id, 'INT');  
            
            Test.stopTest(); 
            
        }catch(Exception ex){
            System.debug('>> test method testPromoteStories failed ' + ex.getMessage() );
        }
        
    }
    
}