@isTest
public class CICD_FetchCommitFromJiraManagerTest {
// testing arproject gaby
    @TestSetup
    public static void prepTestData(){
        CICD_UtilsTest.preapareTestData();
    } 

    public static testMethod void fetchFilesFromCommitTest(){
        Test.startTest();
             Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(200));
             CICD_FetchCommitFromJiraManager.fetchCommitsFromBitbucekt([select id from copado__User_Story__c limit 1].id );
             CICD_FetchCommitFromJiraManager.query('select id,Name from Account');
             CICD_FetchCommitFromJiraManager.getFilesFromCommit('test' , 'test' , 'test' , 'test');
             CICD_FetchCommitFromJiraManager.commitToDeploymentPipeline('test' , 'test' , 'test' );
             CICD_FetchCommitFromJiraManager.getCopadoJobStatus('test');
        Test.stopTest();
    }
    public static testMethod void fetchFilesFromCommitNegativeTest(){
        Test.startTest();
             Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(200));
             CICD_FetchCommitFromJiraManager.fetchCommitsFromBitbucekt( null );
             CICD_FetchCommitFromJiraManager.getFilesFromCommit( null , null , null , null);
             CICD_FetchCommitFromJiraManager.commitToDeploymentPipeline( 'test' , 'test' , null );
             CICD_FetchCommitFromJiraManager.query( null );             
        Test.stopTest();
    }
    
}