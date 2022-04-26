@isTest
public with sharing class CICD_TriggerFactoryTest {
    
    @TestSetup
    public static void prepTestData(){
        copado__Project__c projectRecord = (copado__Project__c) CICD_TestFactory.createSObject(new copado__Project__c());
        insert projectRecord;
    }

    public static testMethod void testCreateHandler(){
        //Negatice Scenario
        CICD_TriggerFactory.createTriggerHandler(Account.SobjectType);

        Test.setMock(HttpCalloutMock.class, new CICD_CreateReleaseMock(201));

        //Positive Scenario
        copado__Release__c releaseRecord = (copado__Release__c) CICD_TestFactory.createSObject(new copado__Release__c(copado__Project__c = [select id from copado__Project__c limit 1].id));        
        insert releaseRecord;        

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        releaseRecord.CICD_StartDate__c =  Date.today();
        releaseRecord.CICD_RelatedProjects__c = 'TEST1';
        releaseRecord.CICD_ReleaseIds__c ='1009;1008';
        update releaseRecord;

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        delete releaseRecord;

        CICD_TriggerFactory.triggerExecutionCheck = new Map<string,boolean>();
        undelete releaseRecord;
    }

    public static testMethod void validateCanBeFired(){
        System.assertEquals( true , CICD_TriggerFactory.canMethodBeFired(new CICD_ReleaseTriggerHandler(), 'afterInsert'));
    }

    public static testMethod void testPropogateError(){
        CICD_TriggerFactory.propagateError([select id,Name from copado__Project__c limit 2], 'vaidate error message');
    }


}