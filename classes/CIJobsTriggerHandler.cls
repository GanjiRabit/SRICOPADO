public with sharing class CIJobsTriggerHandler implements TriggerInterface{
      
    public CIJobsTriggerHandler(){
        // needed for proper initialization
    }
  
   
    public void bulkBefore(){
        // place holder
    } 

    public void bulkAfter(){
        // place holder
    }

	public void beforeInsert(){
        CIJobsTriggerActions.setDefaultValuesIfNull(trigger.new);
        //place holder
    }

	public void beforeUpdate(){
       //place holder
    }

	public void beforeDelete(){         
        //place holder
    }

	public void afterInsert(){
        CIJobsTriggerActions.initiateBatchIfNeeded();
         //place holder
    }

	public void afterUpdate(){
       CIJobsTriggerActions.notifyParent(trigger.new);
    }   

	public void afterDelete(){
         // place holder
    }

    public void afterUnDelete(){
         // place holder
    }

    public void andFinally(){

    }
}