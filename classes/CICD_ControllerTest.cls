@isTest
public with sharing class CICD_ControllerTest {
    @TestSetup
    public static void prepTestData(){
        CICD_UtilsTest.preapareTestData();
    } 
    
    public static testMethod void testControllerMethods(){
        
        Test.startTest();

        CICD_Controller.hasPermissions();

        copado__Release__c rel = [SELECT Id, Name from copado__Release__c LIMIT 1];   
       
        CICD_Controller.getCopadoStories(rel.Id, null);
        CICD_Controller.upsertStories(rel.Name, rel.Id);   
        CICD_Controller.getReleaseById(rel.Id);


        List<copado__User_Story__c> stories = [SELECT Id, Name from copado__User_Story__c];         
        List<String> storyIds = new List<String>();

        for(copado__User_Story__c story : stories){
            storyIds.add(story.Id);
        }

        String storyIdStr = JSON.serialize(storyIds);        
       
        CICD_Controller.markPostDeploysComplete(storyIdStr); 
        CICD_Controller.checkStoryChanges(storyIdStr);

        Test.stopTest();        
    
    }
 
    
}