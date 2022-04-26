import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import CONTEXT_CHANGED_CHANNEL from '@salesforce/messageChannel/contextChangedChannel__c';
export default class DisplayContact extends LightningElement {
     /** Id of record to display. */
    @api recordId; //this captures AccountId which is passed from Parent Component
    @api objectApiName;
     error;   //this holds errors
     contextMessage= {
        storyId:this.recordId?this.recordId:'',
        withinDataSet:false,
        latestVersionOfSource:true,
        deploymentId:''
    };
    @api searchUserStory = {       
        objectName: "copado__User_Story__c",
        objectLabel:'User Story',
        dynamicObjectLabel:false,
        icon: "standard:account",
        label:"User Story : ",
        placeholder: "Please search a User Story",
        fields:'Name',
        displayFields: "Name,copado__User_Story_Title__c,copado__Parent_Epic_Title__c,copado__Project__c",
        valueId:'',
        valueName :'',
        currentRecordId:'',
        filter:'',
        order:'Order By copado__Last_Promotion_Date__c DESC',
        limits:'Limit 50'        
      };
      
    get filterUs()  
    {
        
        if(this.recordId)
        {
            this.searchUserStory.filter = "WHERE Id = '"+this.recordId+"'";            
        }
        //WHERE BillingState IN ('California', 'New York')
        
    }
    
    
    handleUsLookup(event){         
        if(event.detail.data.recordId)
        {
            this.contextMessage.storyId=event.detail.data.recordId;
            
        }else{
            this.contextMessage.storyId=undefined;           
        }  
        this.publishContextChange();     
    }
    
    @api searchDeployment = {       
        objectName: "copado__Deployment__c",
        objectLabel:'Deployment',
        dynamicObjectLabel:false,
        icon: "standard:account",
        label:"Deployment : ",
        placeholder: "Please search a User Story",
        fields:'Name',
        displayFields: "Name,copado__Source_Environment__c,copado__Description__c,copado__Date__c",
        valueId:'',
        valueName :'',
        currentRecordId:'',
        filter:'',
        order:'Order By copado__Date__c DESC',
        limits:'Limit 50'        
      };
      
    get filterDeployment()  
    {
       // if(searchDeplyment.filter)
        //{
           // this.searchDeplyment.filter = "WHERE Id IN ('fields')";
            //this.searchUsesearchDeplymentrStory.filter =  this.searchUserStory.filter.replace('fields',this.dataSetIds.join("','"));
        //}
        //WHERE BillingState IN ('California', 'New York')
    }
    handleDeploymentLookup(event){
        console.log('Parent handleLookup'+ JSON.stringify ( event.detail) );
        console.log('event.detail.data.recordId:', event.detail.data.recordId);
        if(event.detail.data.recordId)
        {
            this.contextMessage.deploymentId=event.detail.data.recordId;
            
        }else{
            this.contextMessage.deploymentId=undefined;           
        }  
        this.publishContextChange();
    }
    
    handleChangeLatestVersionOfSource(event)    
    {    
        console.log('event:',  event.target.checked);     
        this.contextMessage.latestVersionOfSource =  event.target.checked;   
        this.publishContextChange();
    }
    handleChangeWithinDataSet(event)    
    {    
        console.log('event:',  event.target.checked);   
        this.contextMessage.withinDataSet = event.target.checked;
        this.publishContextChange();
    }
     //LMS to broadcast compare results
     @wire(MessageContext)
     messageContextChanged;
     
     // Respond to UI event by publishing message
    publishContextChange()
    {
        const payload = {storyId: this.contextMessage?.storyId,latestVersionOfSource:this.contextMessage?.latestVersionOfSource,withinDataSet: this.contextMessage?.withinDataSet, deploymentId:this.contextMessage?.deploymentId};
        console.log('dataComparerEngine : publishDataDiff publishing' );
        publish(this.messageContextChanged, CONTEXT_CHANGED_CHANNEL, payload);
    }
    connectedCallback()
    {
        if(this.recordId)
        {            
            switch (this.objectApiName) {
                case 'copado__User_Story__c ': 
                {
                    this.searchUserStory.valueId = this.recordId;
                    this.contextMessage.storyId = this.recordId;
                }
            break;            
                case 'copado__Deployment__c': this.searchDeployment.valueId = this.recordId;
            break;
            
                default: 
                {
                    this.searchUserStory.valueId = undefined;
                    this.contextMessage.storyId ='';
                }
                }
            
        }
        this.publishContextChange();
    }
}