trigger CICD_CopadoPromotion on copado__Promotion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    CICD_TriggerFactory.createTriggerHandler(copado__Promotion__c.sobjectType);

}