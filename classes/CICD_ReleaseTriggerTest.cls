@isTest
public with sharing class CICD_ReleaseTriggerTest {
    @TestSetup
    public static void prepTestData(){
        CICD_TriggerFactoryTest.prepTestData();
    }
    
    public static testMethod void testReleaseTriger(){
        //can reuse existing method to cover most of the trigger
        CICD_TriggerFactoryTest.testCreateHandler();        
    }
    
    public static testMethod void testNegativeScenarios(){
        CICD_ReleaseTriggerActions.createNewReleaseInJira('test');
        CICD_ReleaseTriggerActions.createReleaseInJira(null);
        
        CICD_TriggerFactory.createTriggerHandler(Account.SobjectType);
        
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(400));
        
        copado__Release__c releaseRecord = (copado__Release__c) CICD_TestFactory.createSObject(new copado__Release__c(copado__Project__c = [select id from copado__Project__c limit 1].id));        
        insert releaseRecord;        
        
        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        releaseRecord.copado__Planned_Date__c =  Date.today().addDays(100);
        releaseRecord.CICD_RelatedProjects__c = 'TEST1';
        releaseRecord.CICD_ReleaseIds__c ='1009;1008';
        update releaseRecord;
        
        
    }
    
    public static testMethod void testUniquenesLogic(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(400));
        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        copado__Release__c releaseRecord = (copado__Release__c) CICD_TestFactory.createSObject(new copado__Release__c(copado__Project__c = [select id from copado__Project__c limit 1].id));        
         Database.insert(releaseRecord);     
        
        try{
            CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
            releaseRecord = [select id,Name from copado__Release__c limit 1];    
            releaseRecord.id = null;
            Database.insert(releaseRecord);       
        }catch(Exception ex){

        }
         
         try{

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        releaseRecord = [select id,Name,CICD_RelatedProjects__c from copado__Release__c limit 1];    
        releaseRecord.CICD_RelatedProjects__c = 'All;Test';
            Database.update(releaseRecord);
         }catch(Exception Ex){
            
         }

          try{

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        releaseRecord = [select id,Name,CICD_RelatedProjects__c from copado__Release__c limit 1];    
        releaseRecord.CICD_RelatedProjects__c = 'Test';
            Database.update(releaseRecord);
         }catch(Exception Ex){
            
         }
        
        Test.stopTest();
        
        
        
        
    }
}