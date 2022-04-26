trigger CiJobsTrigger on CIJob__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
TriggerFactory.createTriggerHandler(CIJob__c.sobjectType);
}