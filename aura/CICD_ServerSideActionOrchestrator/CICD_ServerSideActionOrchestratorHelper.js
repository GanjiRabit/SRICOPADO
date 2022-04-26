({
    navigateToRecord : function(recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": recordId,
        "slideDevName": "detail"
        });
        navEvt.fire();

    },
    navigateToUrl : function(url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
        "url": url
        });
        urlEvent.fire();
    },
    showToast : function ( tType , title , message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
                type: tType,
                title : title,
                message : message
        });
        toastEvent.fire();
    }
})