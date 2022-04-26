({
    validateCommitFiles : function( component , response) {
        var _self = this;
        return new Promise( (resolve , reject) => {
            
            try{
                let commits = [];
               
                if(response && response.detail && response.detail.length > 0 ){
                    console.log(' >>>>> response' , response);


                    response.detail[0].repositories.forEach ( repo => {
                        repo.commits.forEach ( commit =>{
                            commits.push({
                                id: commit.displayId,
                                message: commit.message,
                                fileCount: commit.fileCount,
                                isCompleteList : commit.fileCount == commit.files.length,
                                url: commit.url,
                                author: commit.author.name,
                                timeStamp: commit.authorTimestamp,
                                isSelected: true,
                                files: commit.files,
                                repoName: repo.name,
                                projectName: null,
                                isMerge : commit.merge ,
                                projectCode : null,
                                repoCode : repo.name
                            });//end of push
                        });
                    });
                    /*
                    response.values.forEach( commit => {                      
                        commits.push({
                            id: commit.toCommit.id,
                            message: commit.toCommit.message,
                            fileCount: commit.changes.size,
                            isCompleteList : commit.changes.isLastPage,
                            url: commit.links.self[0].href.split('#')[0],
                            author: commit.toCommit.author.name,
                            timeStamp: commit.toCommit.authorTimestamp,
                            isSelected: true,
                            files: commit.changes.values,
                            repoName: commit.repository.name,
                            projectName: commit.repository.project.name,
                            isMerge : commit.toCommit.parents.length > 1,
                            projectCode : commit.repository.project.key,
                            repoCode : commit.repository.slug,
                        });//end of push

                        
                        
                    });//end of values      
                    */            
                   // alert(commits.length);
                    component.set("v.commits" , commits);
                    component.set("v.commitsToPromote" , commits.length);
                }

                resolve(commits);


            }catch(err){
                reject( err.stackTrace || err );
            }

        });
    },
    verfiyCommitForFiles : function(component){
        return new Promise( (resolve, reject) => {
            try{

                let commits = component.get("v.commits");
                let commitsToProcess = [];
                let commitsToGetAdditionalFiles = [];
                let filePaths = [];
                commits.forEach( commit => {
                    if(commit.isSelected){
                        commitsToProcess.push( commit );
                        if(!commit.isCompleteList ){
                            commitsToGetAdditionalFiles.push(commit);
                        }else{
                            commit.files.forEach(file => {
                                if(file.path.startsWith('force-app/main/default/'))
                                filePaths.push(file.path);
                            });   
                        }
                    }
                });

                component.set("v.commitsToProcess" , commitsToProcess);
                component.set("v.filePaths" , filePaths);
                component.set("v.commitsToGetAdditionalFiles" , commitsToGetAdditionalFiles);

                resolve( { 
                    commitsToProcess : commitsToProcess , 
                    commitsToGetAdditionalFiles : commitsToGetAdditionalFiles
                 });

            }catch(err){
                reject(err.stackTrace || err);
            }

        });

    },
    retrieveMissingFiles : function ( component ){
        return new Promise( (resolve , reject) => {
            try{

                let commitsToGetAdditionalFiles = component.get("v.commitsToGetAdditionalFiles");

                let promiseChain = Promise.resolve();               

                let _self = this;

                commitsToGetAdditionalFiles.forEach(commit => {
                    promiseChain =  promiseChain.then( res=> {
                        return  _self.fetchFilesForCommit( component , commit.id , commit.projectCode , commit.repoCode);
                    })
                    .catch( err => {                        
                        reject(err.stackTrace || err);
                        throw err.stackTrace || err;
                    })
                });

                promiseChain.then( res =>{
                    resolve();
                })
                .catch(err => {
                    reject(err);
                })

            }catch(err){
                reject( err.stackTrace || err);
            }
        });
    },
    fetchFilesForCommit : function(component , commitId , projectCode , repoCode , startPageAt ){
        let _self = this;
        return new Promise( (resolve,reject) =>{
            try{
                  _fireServerSideAction( component , 'getFilesFromCommit' , { commitId : commitId , projectCode: projectCode , repoCode : repoCode , startPageAt : (startPageAt ? startPageAt.toString() : '0')  } )
                        .then( res => {

                             let filesResp = JSON.parse(res.message);
                             let commitFiles = filesResp.values;
                             console.log( '?? startPageAt ' + startPageAt ,filesResp);
                           
                            _self.collectAdditionalFiles( component ,  commitFiles )
                            .then( resp => {
                                if(filesResp.isLastPage || !filesResp.nextPageStart ){
                                    resolve();
                                }else{                                    
                                    resolve( _self.fetchFilesForCommit(component , commitId , projectCode , repoCode , filesResp.nextPageStart)  );
                                }
                            })
                        })
                        .catch( err => {                           
                            reject( err.stackTrace || err);
                        });
            
                      
            }catch(err){
                reject( err.stackTrace || err);
            }
        });
    },
    collectAdditionalFiles : function(component , commitFiles ){
        return new Promise( (resolve , reject ) =>{
            try{
                let filePaths = component.get("v.filePaths");
                commitFiles.forEach( file => {                    
                    filePaths.push(file.new.path);
                });
                component.set("v.filePaths" , filePaths);
                resolve();
            }catch(err){
                reject(err);
            }
        });
    },
    groupFilesByMetadata : function(component){
        let _self = this;
        return new Promise( (resolve,reject) => {
            try{

                let filePaths = component.get("v.filePaths");
                let metadataConfig = component.get("v.metadataConfig");
                let metadataFiles = { };
                let metadataInfo = { };
                let restrictedTypes = [];
                let restrictedMetadata = [];
                filePaths.forEach( filePath => {
                    metadataInfo = _self.getMetadataInfo( filePath , metadataConfig );
                    if(metadataInfo && metadataInfo.metadataType && metadataInfo.componentName){
                        if( Object.keys(metadataFiles).indexOf(metadataInfo.metadataType) > -1){
                            if( metadataFiles[metadataInfo.metadataType].indexOf(metadataInfo.componentName) == -1)
                                metadataFiles[metadataInfo.metadataType].push(metadataInfo.componentName);
                        }else{
                            metadataFiles[metadataInfo.metadataType] = [metadataInfo.componentName];
                        }
                    }else if(metadataInfo && metadataInfo.restrictedMetadata){
                        if(restrictedTypes.indexOf(metadataInfo.restrictedMetadata.type) == -1){
                            restrictedMetadata.push(metadataInfo.restrictedMetadata);
                            restrictedTypes.push(metadataInfo.restrictedMetadata.type);
                        }
                    }//end of if - null check for metadata config                   
                        
                });// end of for - files collection
                 component.set("v.restrictedMetadata" , restrictedMetadata);
                _self.processMetadataFIles( component ,  metadataFiles);
                resolve();

            }catch(err){
                reject(err.stackTrace || err);
            }

        });
    },
    processMetadataFIles : function( component , metadataFiles ){
        let metadataGrouping = [];
        let  typeIndex = 0;
        Object.keys(metadataFiles).forEach( item => {
            let  items = [];
            let  compIndex = 0;
            metadataFiles[item].forEach( component => {                
                items.push({
                    label : component,
                    index: typeIndex + ':' + compIndex,
                    isDeleted : false
                });//end of pushing to items
                compIndex++;                
            });//end of component loop

            metadataGrouping.push({
                label : item,
                index: typeIndex,
                items: items ,
                isDeleted: false ,
                count: items.length              
            });//end of pushing metadata type
            typeIndex++;
        });//end of metadata loop

        component.set("v.metadataGrouping" , metadataGrouping);
    },
    getMetadataInfo : function( url ,  metadataConfig){
        let metadataInfo = {};
        
            try{
                Object.keys(metadataConfig).forEach( configKey =>{
                    if(!metadataConfig[configKey].CICD_RestrictMetadataType__c){
                        //create a Regex for the config comp name check
                        let regex = new RegExp(configKey);
                        let compResult = regex.exec(url);
                        let compName = compResult &&  compResult[0] ? compResult[0] : null ;
                        if(compName && compName.length > 0 ){
                            metadataInfo.metadataType = metadataConfig[configKey].DeveloperName;                       
                            // if parent regex exists get parent name and prefix to child eg., Account.Name for a field
                            if(metadataConfig[configKey].CICD_ParentNameExpression__c){
                                let parentRegex = new RegExp(metadataConfig[configKey].CICD_ParentNameExpression__c);
                                let parentResult = parentRegex.exec(url);
                                let parentName = parentResult &&  parentResult[0] ? parentResult[0] : null ;
                                if(parentName){
                                    compName = parentName + metadataConfig[configKey].CICD_JoinString__c + compName;
                                }//end of parent Name null check   
                            }//end of parent name exp null check
                            metadataInfo.componentName = compName;
                        }// end of comp nam null check
                    }else{
                        metadataInfo.restrictedMetadata = {
                            type : metadataConfig[configKey].DeveloperName,
                            message : metadataConfig[configKey].CICD_RestrictionMessage__c
                        };
                     } // end of restriction check
                                       

                });//end of keys loop
            }catch(err){
                metadataInfo = {};
                console.log(err);
            }
        return metadataInfo;
    },
    getMetadataConfiguration: function(component){
        let metadataQuery = 'select DeveloperName, CICD_ComponentNameExpression__c , CICD_ParentNameExpression__c  , CICD_JoinString__c , CICD_RestrictMetadataType__c , CICD_RestrictionMessage__c from CICD_MetadataDirectoryConfig__mdt where CICD_ComponentNameExpression__c != null';
       
        return new Promise( (resolve , reject) => {
            _fireServerSideAction(component , 'query' , { queryString :  metadataQuery})
                .then( res => {
                   
                    let metadataConfig = {};
                    res.forEach( config =>{
                        metadataConfig[config.CICD_ComponentNameExpression__c] = config;
                    });//end of forEach - config
                    component.set("v.metadataConfig" , metadataConfig);
                    console.log(' >> >metadataConfig ' , metadataConfig);
                   resolve();
                })
                .catch( err => {
                    reject( err );
                })
        });       
        
    },
    displaySteps : function(component , type){        
        var _self = this;
        return new Promise( (resolve, reject) => {
            try{
                let steps = [];
                let stepTitle = 'Retrieving information from selected commits';

                if( type == 'Commit_Files_Fetch_Progress'){
                    steps = _self.stepsForFetchingFiles();

                }

                component.set("v.steps" , steps);
                component.set("v.stepTitle" , stepTitle);

                component.set("v.displaySteps" , true );

                resolve(steps);

            }catch(err){
               
                reject(err.stackTrace || err);
            }
        });
    },
    stepsForFetchingFiles : function(){
        
       let steps =[
            {
                title : 'Verifying Commits for Salesforce Artifacts',
                isActive : false,
                isCompleted : false            
            },
            {
                title : 'Retrieving Additional Information',
                isActive : false,
                isCompleted : false            
            },            
            {
                title : 'Get Acceptable Metadata Configuration',
                isActive : false,
                isCompleted : false            
            },            
            {
                title : 'Grouping by Metadata',
                isActive : false,
                isCompleted : false            
            }
    ];

        return steps;
    },
    markStepActive : function(component , stepNumber ){
        var _self = this;
        return new Promise( (resolve , reject ) => {
            let stepPath = _self.getStepPath(stepNumber);
            let step = component.get(stepPath);
            step.isActive = true;
            component.set( stepPath , step);
            resolve(step);
        });
        
    },
    markStepComplete : function(component , stepNumber){
        var _self = this;
        return new Promise( (resolve , reject ) => {
            let stepPath = _self.getStepPath(stepNumber);
            let step = component.get(stepPath);
            step.isActive = false;
            step.isCompleted = true;
            component.set( stepPath , step);
            resolve(step);
        });
    },
    getStepPath : function(stepNumber){
        return "v.steps[" + ( stepNumber -1 ) + "]";
    },
    commitFiles : function(component){
        let _self = this;
        return new Promise( (resolve, reject) =>{
            try{
                let body = _self.getRequestBody(component);
                let params = {
                    body : body,
                    userStoryId : component.get("v.recordId"),
                    commitMessage : 'Automated Commit From Jira for ' + component.get("v.recordId")
                };  
                console.log( '>>> params being sent ' , params);
                _fireServerSideAction( component , 'commitToDeploymentPipeline' , params ) 
                .then( res => {
                    
                    let response =  JSON.parse(res.message);

                    if(res.statusCode == 200 && !response.error){
                        
                        _self.getCommitStatus( component ,response.copadoJobId );
                        component.set("v.displaySpinner" , false);
                        component.set("v.showCommitProgress" , true);                        
                        resolve();
                    }else{
                        reject(JSON.parse(res.message).error);
                    }
                    
                    
                })
                .catch( err => {
                    console.log(err);
                    reject(err);
                })
               
            }catch(err){
                reject(err);
            }
        })
    },
    getCommitStatus : function( component , copadoJobId ){
        let _self = this;
        _fireServerSideAction( component , 'getCopadoJobStatus' , { copadoJobId : copadoJobId } )
        .then( res => {
            let response = JSON.parse(res.message);
            console.log(response);
            component.set("v.copadoCommitStatus" , response );
            if( ! response.isFinished) setTimeout( $A.getCallback( function() { _self.getCommitStatus( component , copadoJobId) } )  , 10000);
        }) 
    },
    getRequestBody : function(component){
        let response = [];
        try{
            let metadataGrouping = component.get("v.metadataGrouping");
            metadataGrouping.forEach( metaType => {
                metaType.items.forEach( comp => {
                    if(!comp.isDeleted)
                    response.push({
                        'n' : comp.label,
                        'r' : false,
                        't' : metaType.label

                    });
                })
            });
        }catch(err){

        }
        return response.length > 0 ? JSON.stringify(response) : null;
    }

})