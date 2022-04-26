({
    shared : {}, 
    filterText : 'Approved by QA in ',
    filters :  [
        {'label': '', 'value': 'approvedByQA'},
        {'label': 'All', 'value': 'all'}
    ],
    updateFilterTabText : function(component, helper){
        var org = component.get('v.selectedSourceOrg');
        helper.filters[0].label = helper.filterText + org;

        component.set('v.userStoryFilters', helper.filters);
    },
    setCss : function(component, event, helper) {
        
        var focusedTab = component.get('v.focusedTab');

        var css = '<style>';

        if(focusedTab == 'story-all'){
            // css += '.story-qa-approved {display: flex;}'
        }else if(focusedTab == 'approvedByQA'){
            css += '.story-all {display: none;}'
        }

        css += '</style>';

        component.set('v.hideShowCss', css);
    }, 
    updatePreDeploymentSteps : function(component, event, helper){

        var stories = component.get('v.stories');
        var id = event.getSource().get("v.value");
        var isChecked = event.getSource().get("v.checked");
        var preDeploySteps = component.get('v.preDeploySteps'); 
        var preStep = getPreText(id);
        var preStepIndex = preDeploySteps.indexOf(preStep);

        if(isChecked){ 
            if(hasPreStep(id)){
                preDeploySteps.push(preStep);
            }            
        }else if(!isChecked && preStepIndex != -1){
            preDeploySteps.splice(preStepIndex,1)                       
        }

        component.set('v.preDeploySteps', preDeploySteps);


        function hasPreStep(storyId){            
            for(var i=0; i<stories.length; i++){
                if(stories[i].Id == storyId){
                    if(stories[i].CICD_PreDeploymentManualTasks__c){
                        return true;
                    }
                }
            }              
            return false;
        }

        function getPreText(storyId){            
            var n = ''; 
            for(var i=0; i<stories.length; i++){
                if(stories[i].Id == storyId){
                    n = helper.shared.buildDeployText(
                        stories[i].Name,
                        stories[i].copado__User_Story_Title__c,
                        stories[i].CICD_PreDeploymentManualTasks__c);
                
                }
            }
            return n;
        }

    },


    updatePostDeploymentSteps : function(component, event, helper){

        var stories = component.get('v.stories');
        var id = event.getSource().get("v.value");
        var isChecked = event.getSource().get("v.checked");
        var postDeploySteps = component.get('v.postDeploySteps'); 
        var postStep = getPostText(id);
        var postStepIndex = postDeploySteps.indexOf(postStep);
        var postDeployIds = component.get('v.postDeployIds'); 

        if(isChecked){ 
            if(hasPostStep(id)){
                postDeploySteps.push(postStep);
                postDeployIds.push(id);
            }            
        }else if(!isChecked && postStepIndex != -1){
            postDeploySteps.splice(postStepIndex,1)     
            postDeployIds.splice(postStepIndex,1);                  
        }

        component.set('v.postDeploySteps', postDeploySteps);
        component.set('v.postDeployIds', postDeployIds);
        component.set('v.postStepCss', '');

        function hasPostStep(storyId){            
            for(var i=0; i<stories.length; i++){
                if(stories[i].Id == storyId){
                    if(stories[i].CICD_PostDeploymentManualTasks__c){
                        return true;
                    }
                }
            }              
            return false;
        }

        function getPostText(storyId){            
            var n = ''; 
            for(var i=0; i<stories.length; i++){
                if(stories[i].Id == storyId){
                    n =  helper.shared.buildDeployText(
                        stories[i].Name, 
                        stories[i].copado__User_Story_Title__c,
                        stories[i].CICD_PostDeploymentManualTasks__c);
                }
            }
            return n;
        }

    },
})