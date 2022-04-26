@isTest
public with sharing class CICD_BatchJobTest {
    @TestSetup
   public static void preapareTestData(){
        CICD_UtilsTest.preapareTestData();
    }

    public static testMethod void testBatchJob(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(200));
        Database.executeBatch( new CICD_BatchJob() , 1);

        Test.stopTest();
    }
}