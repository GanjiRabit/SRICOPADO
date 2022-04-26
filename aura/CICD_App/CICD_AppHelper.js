({
    shared : {},
    loadStories : function(component, event, helper) {
        
        var versionName = component.get('v.release.Name'); 
        var releaseId = helper.shared.getUrlParams('c__releaseid'); 

        var params =  {
            'versionName':versionName, 
            'versionId' : releaseId
        }

        helper.shared.callApex('c.upsertStories', params, function(){
            helper.getCopadoStories(component, event, helper);
        });    
    }, //end getUSbyReleaseId  

    loadStoriesForBtns : function(component, event, helper){
        
        var releaseId = helper.shared.getUrlParams('c__releaseid'); 

        var params =  {             
            'releaseId' : releaseId
        }

        helper.shared.callApex('c.getCopadoStoriesByEnv', params, function(response){
           
            var envs = {
                'DEV' : [], 
                'INT' : [], 
                'UAT' : [], 
                'PROD' : []
            };
            
            const keys = Object.keys(envs)

            for(var i=0; i<response.length; i++){     
                var respEnv = response[i].copado__Environment__r.CICD_EnvironmentType__c;            
                if(respEnv){                  
                    for(var x=0; x<keys.length; x++){
                        if(respEnv == keys[x]){
                            envs[keys[x]].push(response[i])
                        }
                    }
                }                
            }   

            component.set('v.storiesDev', envs.DEV);
            component.set('v.storiesInt', envs.INT);
            component.set('v.storiesUat', envs.UAT);
            component.set('v.storiesProd', envs.PROD);

        });
    },

    getCopadoStories : function(component, event, helper){

        component.set('v.selectedUserStories', []);
        component.set('v.preDeploySteps', []);
        component.set('v.postDeploySteps', []);

        var releaseId = helper.shared.getUrlParams('c__releaseid'); 
        var sourceOrg = component.get('v.selectedSourceOrg');
        var selectedUserStories = component.get('v.selectedUserStories');
        var preDeploySteps = component.get('v.preDeploySteps');
        var postDeploySteps = component.get('v.postDeploySteps');

        helper.shared.callApex('c.getCopadoStories', {
            'releaseId':releaseId,
            'sourceOrg' : sourceOrg
        }, 
        function(response){
            if(response){   

                if(response.errorMessages){
                    component.set('v.recordError', response.errorMessages);
                }else{    
                    
                    var parsedResponse = [];

                    for(var i=0; i<response.length; i++){
                        if(response[i].CICD_WorkflowStatus__c == 
                            "QA Approved in " + sourceOrg){
                                response[i].defaultChecked = true;
                                response[i].className = "story-qa-approved";
                                selectedUserStories.push(response[i].Id);

                                if(response[i].CICD_PreDeploymentManualTasks__c){
                                    var txt = helper.shared.buildDeployText(
                                        response[i].Name, 
                                        response[i].copado__User_Story_Title__c, 
                                        response[i].CICD_PreDeploymentManualTasks__c); 
                                    preDeploySteps.push(txt);
                                }
                                if(response[i].CICD_PostDeploymentManualTasks__c){
                                    var txt = helper.shared.buildDeployText(
                                        response[i].Name, 
                                        response[i].copado__User_Story_Title__c,
                                        response[i].CICD_PostDeploymentManualTasks__c); 
                                    postDeploySteps.push(txt);
                                }

                        }else{
                            response[i].className = "story-all";
                        } 

                        parsedResponse.push(response[i]);
                        
                    } 

                    component.set('v.selectedUserStories', selectedUserStories);
                    component.set('v.userStories', parsedResponse); 
                    component.set('v.preDeploySteps', preDeploySteps);
                    component.set('v.postDeploySteps', postDeploySteps);
                }                 
                helper.hideLoading(component);
                // console.log(parsedResponse);
            }                
    });
    },

    hideLoading : function(component){
        component.set('v.loadingMessage','');
        component.set('v.loading',false);
    },

    promote : function(component, event, helper, checkOnly){
        
        component.set('v.loading',true); 

        var releaseObj =  component.get('v.release');
        var releaseId = helper.shared.getUrlParams('c__releaseid'); 
        var sourceOrg =  component.get('v.selectedSourceOrg')
        var stories = component.get('v.selectedUserStories');       
        var recError = component.get('v.recordError');
        var testLevel = component.find('testLevel').get("v.value");

        if(stories.length == 0){
            alert('Please select at least 1 user story');
            helper.hideLoading(component);             
            return false;
        }
        
        var params = {
            stories : JSON.stringify(stories), 
            releaseId : releaseId,
            sourceOrg : sourceOrg          
        } 

        helper.shared.callApex('c.promoteStories', params, function(response){	
            
            var newPromoId;

            if(!response){
                recError.push('There was a problem with entering the promotion');
                component.set('v.recordError', recError);
                helper.hideLoading(component);
                return false;
            }

            if(!response.isSuccess && response.message){
                recError.push(response.message);
                component.set('v.recordError', recError);
                helper.hideLoading(component);
                return false;
            }else{
                newPromoId = response;
            }

            if(newPromoId){

                var param2 = {
                    'promoId':newPromoId, 
                    'checkOnly':checkOnly, 
                    'releaseName' : releaseObj.Name, 
                    'sourceOrg' : sourceOrg, 
                    'testLevel' : testLevel
                }

                helper.shared.callApex('c.deployPromotion', param2, 
                
                function(finalResp){

                    if(finalResp.isSuccess == true){
                        helper.getLatestDeployment(component, event, helper, finalResp.promotionId);
                    }else if(!response.isSuccess && response.message){                        
                        recError.push(response.message);
                        component.set('v.recordError', recError);
                        helper.hideLoading(component);                     
                    }                    
                    
                })

            }
            
        });

    },  

    getLatestDeployment : function(component, event, helper, promoId){       
 
        var timerId = 0;

        timerId = setInterval(function(){
            helper.shared.callApex('c.getLatestDeployment', 
                {'promoId':promoId},
                function(response){
                    // console.log('response is ' + response);                        
                    if(response){
                        
                        clearInterval(timerId); 

                        helper.hideLoading(component);                           
                        
                        var deployUrl = window.location.origin + '/' + response; 

                        var html = '<p>Deployment has been created.'; 
                        html += ' Click <a target="_blank" href="'+deployUrl+'">here</a> to open</p>';

                        component.set('v.successMsg', html);
                        component.set('v.storiesDisabled', 'true');                        
                        helper.callServerForChanges(component, event, helper, true, null);
                    }else{
                        //check for 'error' : responseObj
                        //show error messaging...
                    }
                } , true);
        },3000);

        return false;

    }, //end getLatestDeployment

    storyEnvObj : {     
        timerId : 200, 
        envIds : '' //string
    },

    callServerForChanges : function(component, event, helper, firstLoad, cb){
        var params = {
            stories : JSON.stringify(component.get('v.selectedUserStories'))
        };

        helper.shared.callApex('c.checkStoryChanges', 
            params,
            function(response){
                console.log('here are env ids...');
                console.log(response);
                if(response){
                    if(firstLoad){
                        helper.storyEnvObj.envIds = response;
                    }     
                    if(cb){                        
                        cb(response);
                    }
                }
        } , true);

    },


    checkStoryChanges : function(component, event, helper){        

        component.set('v.loading', 'true');
        component.set('v.loadingMessage', 'Checking for changes');

        helper.callServerForChanges(component, event, helper, false, null);

        helper.storyEnvObj.timerId = setInterval(function(){
            helper.callServerForChanges(component, event, helper, false, callback);
        },3000);

        var callback = function(response){
            if(helper.storyEnvObj.envIds != response){
                clearInterval(helper.storyEnvObj.timerId); 
                helper.hideLoading(component);
                component.set('v.postDeployDisabled', 'false'); 
            }            
        }


        return false;

    }  

})