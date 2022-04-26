/**
 * author            : Debanjan Mukherjee
 * last modified   : 11-20-2021 Debanjan Mukherjee
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   11-20-2021   Debanjan Mukherjee   Initial Version
**/
import { LightningElement, api, wire, track } from 'lwc';
import getDataSetsFromUs from '@salesforce/apex/clsRetrieveDataSetContent.getDataSetsFromUs';
import getTemplateFromDataSet from '@salesforce/apex/clsRetrieveDataSetContent.getTemplateFromDataSet';
import getContentVersionFromDocument from '@salesforce/apex/clsRetrieveDataSetContent.getContentVersionFromDocument';
import getTargetContentVersionData from '@salesforce/apex/clsRetrieveDataSetContent.getContentVersionData';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {  publish,subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext } from 'lightning/messageService';
import SOURCE_CONTEXT_CHANGED_CHANNEL from '@salesforce/messageChannel/withinDataSetChannel__c';//subscribe this
import TARGET_DATA_CHANGED_CHANNEL from '@salesforce/messageChannel/targetDataChangeChannel__c';//publish this

export default class DisplayContact extends LightningElement {
    /** Id of record to display. */  
    @api recordId; //this captures AccountId which is passed from Parent Component
    @track error;   //this holds errors
    @api titlesLabel='Data Content Retriever';
    /////////////////////////////Select Data Set - attributes in a group to register search Component//////////////////////////////////////////////
    value;  //this displays selected value of combo box    
    dataTemplateNames;
    selctedContDocFile;
    contentDocumentVersions;
    prevSelectedFidefaultRecordleVersion;
    selectedFileVersion;
    removeSelectedSourceVersionFromTarget = false;
    @api selectedStoryId;
    @api latestVersionOfSource=false;
    @api withinDataSet;
    get isDisabled() {
        return this.latestVersionOfSource;
    }
    get isSameDataSource() {
       
        return this.withinDataSet;
    }

    dataSets;
    copadoDataSetIds=[];
    selectedDataSetId;
    @api selectedDataSet;
    
    @api searchDataSet = {       
        objectName: "copado__Data_Set__c",
        objectLabel:'Dynamic',
        dynamicObjectLabel:true,
        icon: "standard:account",
        label:"Data Sets:",
        placeholder: "Please search a data set",
        fields:'Name',
        displayFields: "Name,Data_Template_Name__c,copado__Last_Generated_Date__c,Data_Template_Main_Object__c",
        valueId:'',
        valueName :'',
        currentRecordId:'',
        filter:'',
        order:'Order By copado__Last_Generated_Date__c DESC',
        limits:'Limit 50',
        disables:true,
        defaultRecord:null     
      };
    @api
    get defaultDataSet()
    {
        return this.searchDataSet.defaultRecord;
    }  
    set defaultDataSet(value) {
        this.searchDataSet.defaultRecord = value;
        if(this.searchDataSet.defaultRecord)
        this.setAttribute('defaultDataSet', this.searchDataSet.defaultRecord);
        else
        {
            //console.log('else undefined:');
            this.setAttribute('defaultDataSet', null);
            this.selectedDataSet = undefined;
        }
    }
    get filter()  
    {
        let filterTemp='';
        if(this.copadoDataSetIds && Array.isArray(this.copadoDataSetIds))
        {
            if(this.copadoDataSetIds.length>1)
            {
                filterTemp = "WHERE Id IN ('fields')";
                filterTemp =  filterTemp.replace('fields',this.copadoDataSetIds.join("','"));
            }
            else if(this.copadoDataSetIds.length>0){
                filterTemp = "WHERE Id = '"+this.copadoDataSetIds[0]+"'";
            }
        }
        this.searchDataSet.filter = filterTemp;
        return filterTemp;
    }
   
    handleLookup(event){
        
        //as the above undefined the child options to be blaked
        this.selectedFileVersion=undefined;
        //this.loadContentVerionData(); //broadcast de-selection and set to undefined of child selectedFileVersion         
        this.contentDocumentVersions = [];

        this.selctedContDocFile = undefined;           
        this.dataTemplateNames = [];   
        /*
        if(this.searchDataSet.defaultRecord && this.searchDataSet.defaultRecord!=null)
        {
            this.selectedDataSetId  = this.searchDataSet.defaultRecord.Id;
            this.selectedDataSet = this.searchDataSet.defaultRecord;
            //this.loadTemplates();
        }else */
        //console.log('retrieveDataComponent : handleLookup :  event.detail.data.recordId - ' + event.detail.data.recordId );
        if(event.detail.data.recordId)
        {
            if(this.selectedDataSetId != event.detail.data.recordId)
            {
                this.selectedDataSetId = event.detail.data.recordId;
                //selectedDataSet record will be used from parent to set the same selected datasetrecord in target's default record attr
                this.selectedDataSet = event.detail.data.record;
                
            }
            this.loadTemplates();
        }else{
            this.selectedDataSetId=undefined;
            this.selectedDataSet = undefined;
            //as the above undefined the child options to be blaked
            this.dataTemplateNames=[];

        }  
            
    }
    @wire(getDataSetsFromUs, { userStoryId: '$selectedStoryId'})    
    wiredDataSets({ error, data }) {
        this.dataSets='';
        if(this.recordId)
            this.copadoDataSetIds=[];
        if (data) {
            //console.log(data);
            this.dataSets=data;
            if(this.recordId && this.dataSets?.size()>0)
            {
                this.dataSets.forEach(dataSet => {
                    //console.log(dataSet.dataSetName, dataSet.dataSetId,dataSet.dataTemplateName?dataSet.dataTemplateName:'');
                    this.copadoDataSetIds.push(dataSet.dataSetId);
                });
            }             
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dataSets = undefined;
        }
    }
    get dataSets()
    {
        return this.dataSets;
    }
    /////////////////////////////End of Select Data Set and event trigger///////////////////////////
    ////////////////////////////getTemplateFromDataSet//////////////////////////////////////////////

    loadTemplates()
    {
        //this.dataTemplateNames=[];
        this.dataTemplateNames.splice(0, this.dataTemplateNames.length);
        getTemplateFromDataSet({ dataSetId: this.selectedDataSetId })
            .then((result) => {
                for (let key in result) {
                    this.dataTemplateNames = [...this.dataTemplateNames ,{value: key , label: result[key]}];    
                 }                 
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.dataTemplateItems = undefined;
                //console.log('error:', error);
            });
            if(this.selctedContDocFile!=this.contextMessage?.selctedContDocFile)
            {
                this.selctedContDocFile = this.contextMessage.withinDataSet?this.contextMessage?.selctedContDocFile:undefined;
                if(this.selctedContDocFile) this.loadContentVerions();
            }

    }
    //property to bind UI control
    get dataTemplateNames() {
        return this.dataTemplateNames;
    }
    //onClick Event
    handleDataTemplateChange(event) {    
        //console.log('handleDataTemplateChange'+event.target.value); 
        this.selectedFileVersion=undefined;
        //this.loadContentVerionData(); //broadcast de-selection and set to undefined of child selectedFileVersion         
        this.contentDocumentVersions = [];
        
        if(event.target.value)  
        {
            this.selctedContDocFile = event.target.value;
            //console.log('this.contextMessage?.selectedSourceVersion:', this.contextMessage?.selectedSourceVersion);
            //console.log('this.contextMessage?.selctedContDocFile:', this.contextMessage?.selctedContDocFile);
            //console.log('this.selctedContDocFile:', this.selctedContDocFile);
            
            //console.log('this.removeSelectedSourceVersionFromTarget:', this.removeSelectedSourceVersionFromTarget);
            this.loadContentVerions();
        }
        else
        {
            this.selctedContDocFile = undefined; 
        }
        //console.log(this.selctedContDocFile);
        
    }
    //to bind in the value property of combobox and display selection
    get selctedContDocFile()
    {
        return this.selctedContDocFile;
    }
    
    ////////////////////////////End of getTemplateFromDataSet//////////////////////////////////////////////
    ////////////////////////////get versions of content / file ////////////////////////////////////////////
       
    loadContentVerions()
    {    
        if(this.contextMessage.withinDataSet && this.contextMessage?.selectedSourceVersion && this.contextMessage?.selctedContDocFile == this.selctedContDocFile)
        {
            this.removeSelectedSourceVersionFromTarget = true;
        }else{
            this.removeSelectedSourceVersionFromTarget = false;
        }
        this.contentDocumentVersions=[];    this.selectedFileVersion = undefined;
        getContentVersionFromDocument({ contentDocId:this.selctedContDocFile})
            .then((result) => {
                for (let key in result) {
                    //console.log('result[key]:', result[key]);
                    if(this.removeSelectedSourceVersionFromTarget && key == this.contextMessage?.selectedSourceVersion)
                    {
                        continue;
                    }
                    else
                    this.contentDocumentVersions = [...this.contentDocumentVersions ,{value: key , label: result[key]}];    
                 }
                 //console.log('this.latestVersionOfSource:', this.latestVersionOfSource);
                 if(this.latestVersionOfSource)
                 {
                     //as its already ordered by lastGeneratedDate DESC - 0th element is the latest version
                    //this.selectedFileVersion =   this.contentDocumentVersions[0].value;
                    //this.loadContentVerionData();
                 }else{
                    //this.selectedFileVersion = undefined;
                 }               
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.contentDocumentVersions = undefined;
                //console.log('error:', error);
            });
    }
    get contentDocumentVersions() {
        return this.contentDocumentVersions;
    } 
    //Bind onChange Event
    handleContDocVersionChange(event) {
        //validate whether value changed and then load versionData and broadcast event only on change
        //console.log('retrieveTargetDataContent : handleContDocVersionChange - this.selectedFileVersion'+this.selectedFileVersion);

        if(event.target.value != this.selectedFileVersion)
        {
            if(event.target.value)
            {
                this.selectedFileVersion = event.target.value;                
            }
            else{
                this.selectedFileVersion = undefined;
            }
            this.loadContentVerionData();
        }
    }
    
    
    //////////////////////////////////end of loading  versions of source document /////////////////
    ///////////////////////////////////////////////////start of populate Sorce File Version Data///////////////
    loadContentVerionData()
    {   
       
        //console.log('retrieveTargetContent : loadContentVerionData - this.selectedFileVersioniable:', this.selectedFileVersion);
        if(this.selectedFileVersion)
        {   
            getTargetContentVersionData({ contentVersionId:this.selectedFileVersion})
                .then((data) => {
                    this.error = undefined;
                    //console.log('data:', data);
                    this.publishVersionDataChange(data,this.selectedFileVersion);
                })
                .catch((error) => {
                    this.error = error;
                    //console.log('error:', error);
                    //this.publishVersionDataChange(undefined,this.selectedFileVersion);
            
                    this.showNotification();
                })
                .finally(()=>{                   
                    
                });           
        }
        
    }
    
    ///////////////////////////////////////////////////End of populate Sorce File Version Data///////////////
    contextMessage= {
        selectedSourceDataSet:undefined,
        withinDataSet:true,
        latestVersionOfSource:true,
        selectedSourceVersion:undefined,
        selctedContDocFile:undefined
    }
    
   //listen to the context changes 
   @wire(MessageContext)
   messageContext;
     // Standard lifecycle hooks used to sub/unsub to message channel
   connectedCallback() {
    //console.log('connectedCallback :subscribeToMessageChannel:handleMessage');
    this.subscribeToMessageChannel();
}
   // Encapsulate logic for LMS subscribe.
   subscribeToMessageChannel() {
       //console.log('subscribeToMessageChannel:');
       this.subscription = subscribe(
           this.messageContext,
           SOURCE_CONTEXT_CHANGED_CHANNEL,
           (message) => this.handleContextChanged(message)
       );
   }

   // Handler for message received by component
   handleContextChanged(message) {
       //console.log('comparedataSet : handleContextChanged - subscribeToMessageChannel:handleContextChanged');        
       
       this.contextMessage.latestVersionOfSource = message?.latestVersionOfSource?message?.latestVersionOfSource:false;           
        this.contextMessage.withinDataSet = message?.withinDataSet? message?.withinDataSet:'';
        this.contextMessage.selectedSourceDataSet = message?.selectedSourceDataSet? message?.selectedSourceDataSet:'';
        this.contextMessage.selectedSourceVersion = message?.selectedSourceVersion?message?.selectedSourceVersion:'';
        this.contextMessage.selctedContDocFile = message?.selctedContDocFile?message?.selctedContDocFile:'';
        
        //console.log('hi');
        //console.log('handleMessage:this.contextMessage.latestVersionOfSourc '+this.contextMessage?.latestVersionOfSource);
        //console.log('handleMessage: this.contextMessage.withinDataSet'+this.contextMessage?.withinDataSet);
        //console.log('handleMessage:this.contextMessage.selectedSourceDataSet'+this.contextMessage?.selectedSourceDataSet);
        //console.log('handleMessage:this.contextMessage.selectedSourceVersion'+this.contextMessage?.selectedSourceVersion);
        //console.log('handleMessage:this.contextMessage.selctedContDocFile'+this.contextMessage?.selctedContDocFile);
        this.withinDataSet = this.contextMessage?.withinDataSet;
       
       
       this.applyContext();
   }
   applyContext()
   {   
        
        if(this.contextMessage?.withinDataSet && this.contextMessage?.selectedSourceDataSet)
        {
            this.template.querySelector('c-search-component').defaultRecord= this.contextMessage?.selectedSourceDataSet;
                 
        }else{
            this.template.querySelector('c-search-component').defaultRecord= undefined;
 
        }
        
   }
   showNotification() {
        const evt = new ShowToastEvent({
            title: 'No Match column',
            message: this.error,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
    @wire(MessageContext)
    targetDataChanged;    
    publishVersionDataChange(versionData,contentVersionId)
    {
        try {
            const payload = {selectedData:versionData,versionId:contentVersionId};
            //console.log('retrieveTarget :  publishVersionDataChange' );
            publish(this.targetDataChanged, TARGET_DATA_CHANGED_CHANNEL, payload);
        } catch (error) {
            //console.log('publishVersionDataChange error :', error);
        }
       
    }

}