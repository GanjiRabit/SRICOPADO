({
    doInit : function(component, event, helper) {
        
        helper.shared = component.find("CICD_Shared");

        helper.shared.callApex('c.hasPermissions',{},function(canView){
            
            if(!canView){
                component.set('v.appError', 'You don\'t have permissions to view this screen');
                component.set('v.loading',false);
                return false;
            }

            var releaseId = helper.shared.getUrlParams('c__releaseid'); 
            if(!releaseId){
                component.set('v.appError', 'Missing parameters');
                component.set('v.loading',false);
            }else{
                helper.shared.callApex('c.getReleaseById', {'releaseid':releaseId},function(response){	
                    if(response.length > 0){
                        component.set('v.release',response[0]);
                        helper.loadStories(component, event, helper);
                    }else{ //NO RESULTS..SHOW ERROR
                        component.set('v.appError', 'No Release with that Id found');
                        component.set('v.loading',false);
                    }	
                });
                    
            }  
             
        });

    }, 
    switchOrgs : function(component, event, helper){

        component.set('v.loading',true);

        var sourceOrg = component.find("sourceOrg");
        sourceOrg = sourceOrg.get("v.value"); 
        component.set('v.selectedSourceOrg', sourceOrg);

        helper.getCopadoStories(component, event, helper);

        var UserStoriesCmp = component.find("UserStories");
        UserStoriesCmp.updateFilterTabText();

    },  

    promote : function(component, event, helper){
        // component.set('v.successMsg', 'test');
        // return;
        component.set('v.loadingMessage', 'Promoting Stories');
        helper.promote(component, event, helper, false);
    }, 

    validate : function(component, event, helper){
        component.set('v.loadingMessage', 'Validating Stories');
        helper.promote(component, event, helper, true);
    }, 

    markComplete : function(component, event, helper){
        
        var ids = component.get('v.postDeployIds');
        var param = {'stories':JSON.stringify(ids)}; 

        component.set('v.loading',true);

        helper.shared.callApex('c.markPostDeploysComplete', param,
            function(response){	

                if(response == 'success'){
                    var css = '<style>';
                    css += '.post-step {text-decoration: line-through}'
                    css += '</style>';
                    component.set('v.postStepCss', css);                    
                }

                component.set('v.loading',false);

        });


    }, 

    closeSuccessMsg : function(component, event, helper){
        component.set('v.successMsg', '');
        helper.checkStoryChanges(component, event, helper);
    }
    
})