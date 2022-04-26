/**
 * author            : Debanjan Mukherjee
 * last modified   : 11-20-2021 Debanjan Mukherjee
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   11-20-2021   Debanjan Mukherjee   Initial Version
**/

import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {  subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext } from 'lightning/messageService';
import CONTEXT_CHANGED_CHANNEL from '@salesforce/messageChannel/contextChangedChannel__c';
export default class DisplayContact extends LightningElement {
    
     /** Id of record to display. */
    @api recordId; //this captures AccountId which is passed from Parent Component
    error;   //this holds errors
    targetData;
    sourceData;
    @api
    contextMessage= {
        storyId:this.recordId?this.recordId:'',
        withinDataSet:false,
        latestVersionOfSource:true,
        deploymentId:''
    };
    get latestVersionOfSource()
    {
        return this.contextMessage?.latestVersionOfSource?this.contextMessage?.latestVersionOfSource:false;
    }
    //compareEngine = this.template.querySelector('c-data-comparer-engine');
    //should be replaced by LMS to directy pass data from each sibling retrieveContentData to the sibling dataComparerEngine
    //either - destroy data in events in all containers - ultimately will affect heap size - each and everything gets computed against heap
    handleSourceVersionSelection(event)
    {
        console.log('compareDataSet: handleSourceVersionSelection - ');       
        this.sourceData=event.detail.data.contentData;        
        let compareEngine = this.template.querySelector('c-data-comparer-engine');
        if(compareEngine)
        {
            compareEngine.sourceData=this.sourceData?this.sourceData:undefined;
            compareEngine.targetData = this.targetData?this.targetData:undefined;
            compareEngine.loadCompareEngine();
        }
        if(this.sourceData)
            this.applyContext();
        else{
            let trgRetrieveCmp = this.template.querySelector('.target')
            if(trgRetrieveCmp) 
            {
                trgRetrieveCmp.defaultDataSet=undefined;
               
            }
        }
        
    }
    handleTargetVersionSelection(event)
    {
        console.log('compareDataSet: handleTargetVersionSelection ', event.detail.data.contentData);        
        this.targetData=event.detail.data.contentData;
        let compareEngine = this.template.querySelector('c-data-comparer-engine');
        
        if(compareEngine)//safe onLoad while the selectedVersion is undefined as always
        {   
            console.log(this.sourceData);console.log(this.targetData);console.log(compareEngine);        
            compareEngine.sourceData=this.sourceData?this.sourceData:undefined;
            compareEngine.targetData = this.targetData?this.targetData:undefined;           
            compareEngine.loadCompareEngine();
        }   
        //else{
        //    if(this.compareEngine)//safe onLoad while the selectedVersion is undefined as always
        //        this.compareEngine.renderMe = false;
        //}
        
    } 
    //listen to the context changes 
    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        //console.log('subscribeToMessageChannel:');
        this.subscription = subscribe(
            this.messageContext,
            CONTEXT_CHANGED_CHANNEL,
            (message) => this.handleContextChanged(message)
        );
    }

    // Handler for message received by component
    handleContextChanged(message) {
        console.log('comparedataSet : handleContextChanged - subscribeToMessageChannel:handleContextChanged');        
        
        
        this.contextMessage.latestVersionOfSource = message?.latestVersionOfSource?message?.latestVersionOfSource:false;
        this.contextMessage.withinDataSet = message.withinDataSet;        
        this.contextMessage.storyId = message?.storyId? message?.storyId:'';
        this.contextMessage.deploymentId = message?.deploymentId?message?.deploymentId:'';
        console.log('hi');
        console.log('handleMessage:this.contextMessage.latestVersionOfSourc '+this.contextMessage?.latestVersionOfSource);
        console.log('handleMessage: this.contextMessage.withinDataSet'+this.contextMessage?.withinDataSet);
        console.log('handleMessage:this.contextMessage.dataSetId'+this.contextMessage?.storyId);
        console.log('handleMessage:this.contextMessage.deploymentId'+this.contextMessage?.deploymentId);

        this.applyContext();
    }

    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        console.log('compareDataSet : connectedCallback - subscribeToMessageChannel');
        this.subscribeToMessageChannel();
        //read contextx on load - i.e. when coming from user story page
        let contextCmp = this.template.querySelector('c-set-context');
        this.contextMessage.latestVersionOfSource = contextCmp?.latestVersionOfSource;
        this.contextMessage.withinDataSet = contextCmp?.withinDataSet;        
        this.contextMessage.storyId = this.recordId?this.recordId:'';
        this.contextMessage.deploymentId = contextCmp?.deploymentId?contextCmp?.deploymentId:''; 

        this.applyContext();
        
    }
    renderedCallback()
    {        
        //this.applyContext();
    }
    applyContext()
    {
        console.log('this.contextMessage:', this.contextMessage);
        let srcRetrieveCmp = this.template.querySelector('.source');
        console.log('srcRetrieveCmp Label'+srcRetrieveCmp?.titlesLabel);
        if(srcRetrieveCmp) 
        {
            srcRetrieveCmp.selectedStoryId = this.contextMessage?.storyId?this.contextMessage?.storyId:'';
            srcRetrieveCmp.latestVersionOfSource = this.contextMessage?.latestVersionOfSource?this.contextMessage?.latestVersionOfSource:false;            
            
        }
        let trgRetrieveCmp = this.template.querySelector('.target')
        if(trgRetrieveCmp) 
        {
            trgRetrieveCmp.selectedStoryId= this.contextMessage?.storyId? contextMessage?.storyId:'';
            if(this.contextMessage?.withinDataSet && trgRetrieveCmp)
            {
                //disable thetargt dataset look up input box 
                trgRetrieveCmp.withinDataSet = this.contextMessage?.withinDataSet?this.contextMessage?.withinDataSet:false;
                console.log('compare Data Set : srcRetrieveCmp.selectedDataSet:', JSON.stringify(srcRetrieveCmp.selectedDataSet));
                if(srcRetrieveCmp && srcRetrieveCmp.selectedDataSet)
                {
                    trgRetrieveCmp.defaultDataSet=srcRetrieveCmp.selectedDataSet;    
                    console.log('compare Data Set : compareDataSet : trgRetrieveCmp.searchDataSet.defaultRecord - ', trgRetrieveCmp.defaultDataSet);        
                    
                   // trgRetrieveCmp.searchDataSet.valueId = srcRetrieveCmp.selectedDataSetId; 
                    //trgRetrieveCmp.searchDataSet.valueName = "test";//srcRetrieveCmp?.selectedDataSet["Name"]?srcRetrieveCmp?.selectedDataSet["Name"]:''; 
                    
                }else{
                    trgRetrieveCmp.searchDataSet.defaultRecord = null;
                    trgRetrieveCmp.defaultDataSet=undefined;
                    
                }
            }
            else
            {
                //disable thetargt dataset look up input box 
                trgRetrieveCmp.withinDataSet = false;
                trgRetrieveCmp.searchDataSet.defaultRecord = null;  
                trgRetrieveCmp.defaultDataSet=undefined;      
                trgRetrieveCmp.selectedDataSet = undefined;    
            }
        }
        
        //the story id is a public property in the child , though it gets used to compute the property filter 
        //which is bound to the UI of the child component and passed whiler registering it hence storyId is also a reactive propery and if new value comes child reRenders 
        
        
    }
    // Helper
    dispatchToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading contact',
                message: error,//reduceErrors(error).join(', '),
                variant: 'error'
            })
        );
    }   
     //End of listen to the context changes 

}