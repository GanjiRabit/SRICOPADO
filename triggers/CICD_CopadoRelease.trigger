trigger CICD_CopadoRelease on copado__Release__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    CICD_TriggerFactory.createTriggerHandler(copado__Release__c.sobjectType);
    
}