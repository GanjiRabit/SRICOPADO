({
    doInit : function(component, event, helper) {        
        helper.shared = component.find("CICD_Shared");
        var stories = component.get('v.envStories');
        var selected = [];
        for(var i=0; i<stories.length; i++){
            selected.push(stories[i].Id);
        }
        component.set('v.selectedStories', selected);    
    }, 
    closeEnvModal : function(component, event, helper){
        component.set('v.envModal',false);
        component.set('v.envStories',[]);
        component.set('v.selectedStories', []);
    }, 
    selectStory : function(component, event, helper){
        
        var id = event.getSource().get("v.value");
        var isChecked = event.getSource().get("v.checked");        
        var selectedStories = component.get('v.selectedStories');
        var itemIndex = selectedStories.indexOf(id); 

        if(isChecked){
            selectedStories.push(id);
        }else if(!isChecked && itemIndex >= 0){
            selectedStories.splice(itemIndex,1);
        }       

        component.set('v.selectedStories', selectedStories);

    }, 
    notifyBtnClicked : function(component, event, helper){

        var emails = component.find("emails").get("v.value");
        var comments = component.find("comments").get("v.value");
        var subject = component.find("subject").get("v.value");
        var release = component.get('v.release'); 


        if(!emails){
            alert('Please enter at least one email');
            return false;
        }
        
        var emailArray = emails.split(',');

        for(var i=0; i<emailArray.length; i++){
           if(!/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(emailArray[i].trim())) {
               alert('One of the email addresses you entered in invalid');
               return false;
           }
        }

        var selected = component.get('v.selectedStories');

        if(selected.length == 0){
            alert('Please select at least one user story');
            return false;
        }

        component.set('v.loading', true);
        component.set('v.loadingMessage', 'Sending Message');

        var params = {
            'emails' : JSON.stringify(emailArray), 
            'stories' : JSON.stringify(component.get('v.selectedStories')), 
            'comments' : comments, 
            'subject' : subject, 
            'releaseName' : release.Name
        }

        helper.shared.callApex('c.notifyTeam', params, function(response){    
            component.set('v.loading', false);
            component.set('v.loadingMessage', '');
            component.set('v.envModal',false);
            component.set('v.envStories',[]);
            component.set('v.selectedStories', []);

            if(response != 'success'){                
                component.set('v.recordError',response);                
            }
        })

 


    }
})