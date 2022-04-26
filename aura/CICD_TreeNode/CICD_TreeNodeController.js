({
    toggleSelection : function(component, event, helper) {

        event.target.parentElement.setAttribute('aria-expanded' , ! (/true/i).test(event.target.parentElement.getAttribute('aria-expanded') ) );
    },
    removeItem : function(component, event, helper) {

       let deleteNodeEvt = component.getEvent("deleteNodeEvent");
       deleteNodeEvt.setParams({ nodeIndex : component.get("v.item").index });
       deleteNodeEvt.fire();
    }
})