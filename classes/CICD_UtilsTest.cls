@isTest
public class CICD_UtilsTest {
      @TestSetup
    public static void preapareTestData(){        
            

           CICD_JiraProjectNSFEnvironmentMapping__mdt setting = [select id,DeveloperName,CICD_SfDefaultEnvironment__c,CICD_SfDevOrgCredential__c from CICD_JiraProjectNSFEnvironmentMapping__mdt limit 1];

            copado__Project__c projectRecord = (copado__Project__c) CICD_TestFactory.createSObject(new copado__Project__c(
                CICD_JiraProjectKey__c = setting.DeveloperName
            ));
              system.debug( '>> projectRecord ' + projectRecord);
             insert projectRecord;

             copado__Release__c releaseRecord = (copado__Release__c) CICD_TestFactory.createSObject(new copado__Release__c( copado__Project__c = projectRecord.id));                
             system.debug( '>> releaseRecord ' + releaseRecord);
            insert releaseRecord;     

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
                    CICD_JiraIssueId__c = '1500',
                    copado__Release__c = [select id from copado__Release__c limit 1].id
             ));            
             insert userStoryRecord;
    }

    public static testMethod void testCallout(){

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(200));
        
        //positive scenario
       Map<string,object> response = CICD_Utils.doRestCallout( 'callout:Devops_JiraConnector/2/version', new Map<string,string> { 'test' => 'test'} , 'GET', null);

       CICD_Utils.parseJsonUntyped( (string) response.get('message') , 'project.key');

        //negative scenario
        CICD_Utils.doRestCallout(  null , null , 'GET', null);

        CICD_Utils.getJiraIssues('test');

        

        Test.stopTest();
    }

    public static testMethod void testJiraSyncConfiguration(){

        
        Test.startTest();

        string testJiraIssueResponse = '{"id" : 25 , "key": 30, "fields" : { "project": { "key" : "TEST1"} , "summary" : "test" } }';
        
        CICD_Utils.prepareSobjectBasedOnJiraConfig( new copado__User_Story__c() , (Map<String,object>) JSON.deserializeUntyped(testJiraIssueResponse)  ) ;

        copado__User_Story__c userStory = [select id,Name,CICD_WorkflowStatus__c,copado__project__r.Name,copado__project__r.CICD_JiraProjectKey__c from copado__User_Story__c limit 1];
        //to jira request
        CICD_Utils.prepareJiraUserStoryRequest( userStory , true );

        CICD_Utils.getSobjectValue(userStory, 'copado__project__r.Name');

        //positive jira call
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(200));
        CICD_Utils.getJiraIssues('test');
        CICD_Utils.updateJiraWithSFURL(new Map<string,string>{ 'test' => 'test'});

        //bad jira call
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(400));
        CICD_Utils.getJiraIssues('test');        
        CICD_Utils.updateJiraWithSFURL(new Map<string,string>{ 'test' => 'test'});

        CICD_Utils.addFieldToRequest( new Map<string,object>() , userStory , 'description', 'Name');
         CICD_Utils.addFieldToRequest( new Map<string,object>() , userStory , 'description.value', 'Name');
        CICD_Utils.cancelDeletedJiras(new List<string>{ [select id from copado__Release__c limit 1].id } , new List<string> {'500000000'});
        CICD_Utils.getNodeFromDeserialziedObject( new Map<string,object>() , null);
        CICD_Utils.prepareSobjectBasedOnJiraConfig( null , null);
        CICD_Utils.prepareJiraUserStoryRequest( null , false);

        //negative scenarios
        CICD_Utils.parseJsonUntyped( '{ }' , 'test');
        CICD_Utils.getNodeFromDeserialziedObject( null , 'test.');
        CICD_Utils.getJiraIssues(null);
        CICD_Utils.parseResponseAndLogErrors(null);


        Test.stopTest();

    }

    public static testMethod void testGetTransitionId(){

        Test.startTest();
         //positive jira call
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(200));
        CICD_Utils.getTransitionId( [select id,CICD_JiraIssueId__c from copado__User_Story__c limit 1] , 'In Progress');        

        //bad jira call
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(405));
        CICD_Utils.getTransitionId( [select id,CICD_JiraIssueId__c from copado__User_Story__c limit 1] , 'In Progress');

        Test.stopTest();
    }
}