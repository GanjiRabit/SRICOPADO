/*
    Author: Balaji C Garapati (Salesforce Consultant)
    Purpose: Interface that sets template for trigger handlers
*/
public interface CICD_TriggerInterface {

    void bulkBefore(); // to perform any bulk operations before trigger actual code execution starts

    void bulkAfter(); // to perform any bulk operations before after trigger logic executes. 

	void beforeInsert(); // method to invoke on before insert event

	void beforeUpdate(); // method to invoke on before update event

	void beforeDelete(); // method to invoke on before delete event

	void afterInsert(); // method to invoke on after insert event

	void afterUpdate(); // method to invoke on after update event

	void afterDelete(); // method to invoke on after delete event

    void afterUnDelete(); // method to invoke on after undelete event

    void andFinally(); // method to execute after trigger logic is complete
     
}