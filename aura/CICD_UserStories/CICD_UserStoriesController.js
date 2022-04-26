({
    doInit : function(component, event, helper){

        helper.shared = component.find("CICD_Shared");

        helper.setCss(component, event, helper); 
        helper.updateFilterTabText(component, helper);
    },

    updateFilterTabText : function(component, event, helper){
       helper.updateFilterTabText(component, helper);
    },

    updateChecked : function(component, event, helper) {     

        var selectedUserStories = component.get('v.selectedUserStories');

        var id = event.getSource().get("v.value");
        var isChecked = event.getSource().get("v.checked");
        var itemIndex = selectedUserStories.indexOf(id);  

        if(isChecked){
            selectedUserStories.push(id);
        }else if(!isChecked && itemIndex >= 0){
            selectedUserStories.splice(itemIndex,1);
        }

        // console.log(selectedUserStories);

        component.set('v.selectedUserStories', selectedUserStories);

        helper.updatePreDeploymentSteps(component, event, helper);
        helper.updatePostDeploymentSteps(component, event, helper);        

    }, 
    tabSwitch : function(component, event, helper){
        var focusedTab = event.getSource().get("v.value"); 
        component.set('v.focusedTab', focusedTab);
        helper.setCss(component, event, helper);
    }
})