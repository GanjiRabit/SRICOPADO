({
    getCommitInformation : function(component, event, helper) {

        //fetch commits associated to current jira
        _fireServerSideAction( component , 'fetchCommitsFromBitbucekt' ,  { userStoryId : component.get("v.recordId")} )
        .then( response  => {
            
            if(response && response.message ){
                
                console.log( JSON.parse(response.message ) );
                //check if commit files were all returned or only top files
                return helper.validateCommitFiles( component  ,  JSON.parse( response.message ) );


            }else{
                throw 'Invalid Response';
            }
        })
        .then( response => {

            if(response && response.length > 0 ){
                component.set("v.displaycommitsInformation" , true );
            }else{
                // Show a message to user and redirect to manual selection process
                component.set("v.noCommitsFound" , true);
            }

            component.set("v.displaySpinner" , false);

        })
        .catch( errMsg =>{
            
            component.set("v.noCommitsFound" , true);
        })
    },
    navigateToRecord : function(component, event, helper) {

        helper.navigateToRecord( component.get("v.recordId") );

    },
    navigateToCopadoCommitSelection : function(component, event, helper) {

        helper.navigateToUrl( "/apex/copado__GitCommitMain?userStoryId=" + component.get("v.recordId") + "&variant=userstorycommit" );

    },
    prepareFilesForCommit : function(component, event, helper) {

       component.set( "v.displaycommitsInformation" , false );
       component.set( "v.showFilesSelection" , false );
       component.set("v.filePaths" , []);
       helper.displaySteps(component , 'Commit_Files_Fetch_Progress')
       .then( res => {
           //step 1
           return   helper.markStepActive(component , 1 )
                    .then( res => {
                      return   helper.verfiyCommitForFiles(component);
                    })
                    .then (res => {
                        return helper.markStepComplete(component , 1);
                    })
                    .catch(err => {
                        throw err;
                    });
       })//end of step 1
       .then ( res => {
            //setp 2
            return helper.markStepActive(component , 2 )
            .then( res => {
              return helper.retrieveMissingFiles(component);
            })
            .then (res => {               
                return helper.markStepComplete(component , 2);
            })
            .catch(err => {
                throw err;
            });;
       })//end of step 2
       .then ( res => {
            //setp 3
            
            return helper.markStepActive(component , 3 )
            .then( res => {
              return helper.getMetadataConfiguration(component);
            })
            .then (res => {            
                return helper.markStepComplete(component , 3);
            })
            .catch(err => {
                throw err;
            });;
        })//end of step 3 
       .then ( res => {
            //setp 4            
            return helper.markStepActive(component , 4 )
            .then( res => {
              return helper.groupFilesByMetadata(component);
            })
            .then (res => {               
                return helper.markStepComplete(component , 4);
            })
            .catch(err => {
                throw err;
            });;
        })//end of step -4
        .then ( res => {
            //display metadata grouping
            component.set("v.displaySteps" , false);
            component.set("v.showFilesSelection" , true);
            
       })
       .catch( err => {
        helper.showToast( 'error' , 'Error' , err.stackTrace || err);
       })

       

    },
    removeNodeFromMetadata : function(component, event, helper) {
        try{

            let nodeIndex = event.getParam("nodeIndex");

            if(nodeIndex){
                let metadataGrouping = component.get("v.metadataGrouping");
                let nodeIndexes = nodeIndex.split(':');
                if( nodeIndexes.length == 1){
                    metadataGrouping[ nodeIndexes[0] ].isDeleted = true; 
                }else{
                    metadataGrouping[nodeIndexes[0]].items[ nodeIndexes[1] ].isDeleted = true; 
                    metadataGrouping[nodeIndexes[0]].count--;
                }
                component.set("v.metadataGrouping" , metadataGrouping);
            }
            
        }catch(err){
            console.log(err);
        }
    },
    continueWithCommit : function(component, event, helper) {
        component.set("v.displaySpinner" , true);
        helper.commitFiles(component)
        .then(res =>{
            component.set("v.displaySpinner" , false);
            
        })
        .catch( err => {
          helper.showToast( 'error' , 'Error' ,err);
            component.set("v.displaySpinner" , false);
        })
    },
    closeModal : function(component, event, helper) {
        component.set("v.restrictedMetadata" , []);
    }
})