trigger CICD_CopadoStories on copado__User_Story__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
 
    CICD_TriggerFactory.createTriggerHandler(copado__User_Story__c.sobjectType);


}