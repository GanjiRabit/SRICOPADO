({
    navigateToFetchJiraIssue : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CICD_FetchCommitFromJira",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    navigateToCopadoCommitSelection : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/apex/copado__GitCommitMain?userStoryId="+component.get("v.recordId") + "&variant=userstorycommit"
        });
        urlEvent.fire();
 
    }
})