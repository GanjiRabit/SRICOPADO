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
import getSourceContentVersionData from '@salesforce/apex/clsRetrieveDataSetContent.getContentVersionData';
//import getContentVersionDataTemp from '@salesforce/apex/clsRetrieveDataSetContent.getContentVersionDataTemp';
import { publish, MessageContext } from 'lightning/messageService';
import CONTEXT_SOURCE_CHANGED_CHANNEL from '@salesforce/messageChannel/withinDataSetChannel__c';
import SOURCE_DATA_CHANGED_CHANNEL from '@salesforce/messageChannel/sourceDataChangeChannel__c';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';


export default class DisplayContact extends LightningElement {
    /** Id of record to display. */  
    @api recordId; //this captures AccountId which is passed from Parent Component
    @api objectApiName;
    @track error;   //this holds errors
    @api titlesLabel='Data Content Retriever';
    /////////////////////////////Select Data Set - attributes in a group to register search Component//////////////////////////////////////////////
    value;  //this displays selected value of combo box    
    dataTemplateNames;
    selctedContDocFile;
    contentDocumentVersions;
    prevSelectedFidefaultRecordleVersion;
    selectedFileVersion;
      
    //@api selectedStoryId='a2V1F000003IKJXUA4';
    @api latestVersionOfSource;
    @api withinDataSet;
    get isDisabled()
    {
        return this.latestVersionOfSource;
    }
    get isSameDataSource() {
       
        return this.withinDataSet;
    }

    dataSets;
    copadoDataSetIds=[];
    selectedDataSetId;
    @api selectedDataSet;
    contextMessage= {
        selectedSourceDataSet:this.selectedDataSet?this.selectedDataSet:'',
        withinDataSet:true,
        latestVersionOfSource:false,
        selectedSourceVersion:this.selectedFileVersion,
        selctedContDocFile:this.selctedContDocFile
    }
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
        disables:false,
        defaultRecord:null,
        wrapperDisplay:"Name,dataTemplateObject,dataTemplateObject"         

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
              ////console.log('else undefined:');
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
        //////console.log('this.searchDataSet.filter:', this.searchDataSet.filter);
        return filterTemp;
    }
   
    handleLookup(event){
        ////console.log('retrieveDataComponent : handleLookup :  event.detail.data.recordId - ' + event.detail.data.recordId );
        if(event.detail.data.recordId!=this.selectedDataSetId)
        {
            this.selectedDataSetId = event.detail.data.recordId;
            this.selectedDataSet = event.detail.data.record;
            this.loadTemplates();
        } 
        ////console.log('end of handleLookup in source:');    
    }
    @wire(getDataSetsFromUs, { userStoryId: '$recordId'})    
    wiredDataSets({ error, data }) {
        this.dataSets=[];
        if(this.recordId)
            this.copadoDataSetIds=[];
        if (data) {
            ////console.log(data);
            this.dataSets=data;
            if(this.recordId && this.dataSets)
            {
                this.searchDataSet.defaultRecord = this.dataSets[0];
                ////console.log('this.searchDataSet.defaultRecord:', this.searchDataSet.defaultRecord);
                /* //below was for filter implementation to make available all Data Sets part of the user story as search - not as above to get the last generated as selected 
                this.dataSets.forEach(dataSet => {
                    ////console.log(dataSet.dataSetName, dataSet.dataSetId,dataSet.dataTemplateName?dataSet.dataTemplateName:'',dataSet.dataTemplateMainObject);
                    this.copadoDataSetIds.push(dataSet.dataSetId);
                    
                });
                */
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
        this.dataTemplateNames = [];
        getTemplateFromDataSet({ dataSetId: this.selectedDataSetId })
            .then((result) => {
                for (let key in result) {
                    this.dataTemplateNames = [...this.dataTemplateNames ,{value: key , label: result[key]}];    
                 }                 
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.dataTemplateNames = undefined;
                ////console.log('error:', error);
            });
    }
    //property to bind UI control
    get dataTemplateNames() {
        return this.dataTemplateNames;
    }
    //onClick Event
    handleDataTemplateChange(event) {    
        if(event.target.value!=this.selctedContDocFile)  
        {
            ////console.log('handleDataTemplateChange:this.selctedContDocFile ', this.selctedContDocFile);

            this.selctedContDocFile = event.target.value;
            this.latestVersionOfSource=true;
            this.loadContentVerions();
            this.publishContextChange();//will let target know whether its a within data set compare & pre select the same file 
            ////console.log('handleDataTemplateChange:this.selctedContDocFile ', this.selctedContDocFile);
        }
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
        ////console.log('retrieveSource : this.selectedFileVersion: loadContentVerionData with ', this.selctedContDocFile);
        this.contentDocumentVersions=[];    
        getContentVersionFromDocument({ contentDocId:this.selctedContDocFile})
            .then((result) => {
                for (let key in result) {
                    this.contentDocumentVersions = [...this.contentDocumentVersions ,{value: key , label: result[key]}];                                                 
                }
                if(this.latestVersionOfSource)
                {
                    this.selectedFileVersion = this.contentDocumentVersions[0].value;
                    this.loadContentVerionData();               
                    this.error = undefined;
                }
            })
            .catch((error) => {
                this.error = error;
                this.contentDocumentVersions = undefined;
                ////console.log('error:', error);
            });
    }
    get contentDocumentVersions() {
        return this.contentDocumentVersions;
    } 
    //Bind onChange Event
    handleContDocVersionChange(event) {
        //validate whether value changed and then load versionData and broadcast event only on change
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
            ////console.log('retrieveSourceDataContent : handleContDocVersionChange - this.selectedFileVersion'+this.selectedFileVersion);
        }
    }
    
    
    //////////////////////////////////end of loading  versions of source document /////////////////
    ///////////////////////////////////////////////////start of populate Sorce File Version Data///////////////
    loadContentVerionData()
    {   
       
        ////console.log('retrieveSourceContent : loadContentVerionData - this.selectedFileVersioniable:', this.selectedFileVersion);
        if(this.selectedFileVersion)
        {   
            getSourceContentVersionData({ contentVersionId:this.selectedFileVersion})
                .then((data) => {
                    ////console.log('data:', data);
                    this.error = undefined;
                    this.publishVersionDataChange(this.selectedFileVersion,data);
                })
                .catch((error) => {
                    this.error = error;
                    ////console.log('error:', error);
                    //this.publishVersionDataChange(this.selectedFileVersion,undefined);                   
                })
                .finally(()=>{                    
                    //this.publishContextChange();                    
                });           
        }        
    }
    
    ///////////////////////////////////////////////////End of populate Sorce File Version Data///////////////
    handleChangeWithinDataSet(event)    
    {    
        ////console.log('event:',  event.target.checked);   
        this.contextMessage.withinDataSet = event.target.checked;
        this.publishContextChange();
    }
     //LMS to broadcast compare results
     @wire(MessageContext)
     sourceContextChanged;
     
     // Respond to UI event by publishing message
    publishContextChange()
    {
        const payload = {selctedContDocFile: this.selctedContDocFile,selectedSourceDataSet: this.selectedDataSet,latestVersionOfSource:this.contextMessage?.latestVersionOfSource,withinDataSet: this.contextMessage?.withinDataSet,selectedSourceVersion:this.selectedFileVersion};
        ////console.log('retrieveSource :  publishContextChange' );
        publish(this.sourceContextChanged, CONTEXT_SOURCE_CHANGED_CHANNEL, payload);
    }
    @wire(MessageContext)
     sourceDataChanged;
     publishVersionDataChange(contentVersionId,versionData)
     {
         ////console.log('retrieveSource : publishVersionDataChange- versionData:', versionData);
        try{
            const payload = {selectedData:versionData,versionId:contentVersionId};
            ////console.log('retrieveSource :  publishVersionDataChange' );
            publish(this.sourceDataChanged, SOURCE_DATA_CHANGED_CHANNEL, payload);
        } catch (error) {
            ////console.log('publishVersionDataChange error :', error);
        }
     }
}