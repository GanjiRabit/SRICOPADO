@isTest
public with sharing class CICD_UserStoryTriggerTest {
    
    @TestSetup
    public static void preapareTestData(){        
            
           CICD_JiraProjectNSFEnvironmentMapping__mdt setting = [select id,DeveloperName,CICD_SfDefaultEnvironment__c,CICD_SfDevOrgCredential__c from CICD_JiraProjectNSFEnvironmentMapping__mdt limit 1];

            copado__Project__c projectRecord = (copado__Project__c) CICD_TestFactory.createSObject(new copado__Project__c(
                CICD_JiraProjectKey__c = setting.DeveloperName
            ));
            
             insert projectRecord;

              copado__Environment__c environment = (copado__Environment__c) CICD_TestFactory.createSObject(new copado__Environment__c( 
                    Name = setting.CICD_SfDefaultEnvironment__c,
                    copado__Promotion_Default_Credential__c = 'All Promotions',
                    copado__Org_ID__c ='test',
                    CICD_EnvironmentType__c ='INT'
                    
                    ));            
                insert environment;

                copado__Org__c orgCredential = (copado__Org__c) CICD_TestFactory.createSObject(new copado__Org__c( 
                    Name = setting.CICD_SfDevOrgCredential__c,
                    copado__Environment__c = environment.id,
                    copado__Validated_Date__c = Date.today(),
                    copado__Disable_Validation__c = true,
                    copado__Org_Type__c = 'Sandbox',
                    copado__Token__c ='test token',
                    copado__SFDC_Org_ID__c =  UserInfo.getOrganizationId(),
                    copado__Default_Credential__c = true,
                    copado__Oauth_Signature__c ='test oAuth',                    
                    copado__is_Developer_Hub_Org__c =false,
                    copado__Username__c = UserInfo.getUserName()

                    ));            
                insert orgCredential;


            copado__User_Story__c userStoryRecord = (copado__User_Story__c) CICD_TestFactory.createSObject(new copado__User_Story__c( 
                    copado__Promote_and_Deploy__c = true,
                    copado__Project__c = projectRecord.id,
                    CICD_PrimaryDeveloperEmail__c  = 'salesforce_admins@parsons.com',
                    CICD_JiraIssueId__c = '1500'
             ));            
             insert userStoryRecord;
    }

    public static testMethod void testUserStoryTrigger(){
        Test.startTest();

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(204));
        copado__User_story__c userStory = [select id,Name,CICD_PostDeploymentManualTasksComplete__c from copado__User_Story__c limit 1];
        userStory.CICD_ReopenUserStory__c = true;
        userStory.CICD_PostDeploymentManualTasksComplete__c = true;
        update userStory;

        Test.stopTest();
    }

    public static testMethod void testNegativeScenario(){
        Test.startTest();

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(500));
        copado__User_story__c userStory = [select id,Name,CICD_PostDeploymentManualTasksComplete__c from copado__User_Story__c limit 1];
        userStory.CICD_ReopenUserStory__c = true;
        userStory.CICD_PostDeploymentManualTasksComplete__c = true;
        update userStory;

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        userStory.CICD_PostDeploymentManualTasksComplete__c = false;
        userStory.CICD_WorkflowStatus__c = 'Ready for Testing in PROD';
        userStory.CICD_PostDeploymentManualTasks__c = 'test';
        userStory.CICD_LastDeploymentStatus__c = 'Completed with errors';
        update userStory;

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();        
        userStory.CICD_WorkflowStatus__c = 'Ready for Testing in INT';        
        userStory.CICD_LastDeploymentStatus__c = '';
        update userStory;



        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        delete userStory;

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        undelete userStory;

        Test.stopTest();
    }
}