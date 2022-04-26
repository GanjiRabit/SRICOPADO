/**
 * author            : Debanjan Mukherjee
 * last modified   : 11-20-2021 Debanjan Mukherjee
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   11-20-2021   Debanjan Mukherjee   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import search from '@salesforce/apex/SearchController.search';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
const DELAY = 300;

export default class SearchComponent extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api valueId;
    @api valueName;
    @api objName='Contact';
    @api objectLabel;
    
    @api iconName='standard:account';
    @api labelName='test';
    @api readOnly = false;
    @api currentRecordId='';
    @api placeholder = 'Search';
    @api createRecord;
    @api fields = ['Name'];
    @api displayFields='Name,Email,Phone';
    @api filter;//filter example : WHERE BillingState IN ('California', 'New York') - should go before the ending first brace of returning
    @api order;//order example : ORDER BY Name DESC NULLS last
    @api limits;//limits example : Limit 20
    @api isDisabled=false;
    @api wrapperDisplay;
    __defaultRecord;
    @track error;
    @api
    searchTerm;
    delayTimeout;

    searchRecords=[];
    selectedRecord;
    get selectedRecord()
    {
        return this.selectedRecord;
    }
    //objectLabel;
    isLoading = false;

    field;
    field1;
    field2;
    field3;
    get selectedField()
    {
        return this.selectedRecord.FIELD1?this.selectedRecord.FIELD1:this.selectedRecord['Name'];
    }
    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';
    _dynamicObjectLabel;
    @api 
    get dynamicObjectLabel()
    {   
        return this._dynamicObjectLabel;
    }
    set dynamicObjectLabel(value)
    {   
        this._dynamicObjectLabel = value;
        if(this._dynamicObjectLabel) this.setAttribute('dynamicObjectLabel', this._dynamicObjectLabel);
    }
    @api
    get defaultRecord()
    {
        return this.__defaultRecord;
    }  
    set defaultRecord(value) {
        if(value){
            this.searchRecords=[];
            //console.log('Search Compponent : set defaultRecord 1:',JSON.stringify(value));
            this.__defaultRecord = value;
                //console.log(' Search Compponent : set defaultRecord  2:', this.__defaultRecord);
            if(this.__defaultRecord) 
            {
                this.searchRecords.push(this.__defaultRecord);
                //console.log('3:', this.searchRecords);
                for(let key in value)
                {   
                    if(key==='Id')
                    {
                        this.selectedRecordChange(value[key]);
                        break;
                    }
                    
                }
            
                //if(this.searchRecords[0]) //console.log('3:', this.searchRecords[0]);
                this.setAttribute('defaultRecord', this.__defaultRecord);
            }
            else 
            {
                this.setAttribute('defaultRecord', undefined);
                //console.log('selectedRecordClosed undefined:', undefined);
                this.selectedRecordClosed(undefined);
            }            
        }
    }
    connectedCallback(){
        //console.log('this.recordId:searchComponent', this.recordId);
        //console.log('@api objectApiName:searchComponent', this.objectApiName);
        let icons  = this.iconName?.split(':');
        if(this.iconName)
        {
            this.ICON_URL       = this.ICON_URL?.replace('{0}',icons[0]);
            this.ICON_URL       = this.ICON_URL?.replace('{1}',icons[1]);
           
        }else{
            this.ICON_URL='';
            
        }
        //console.log('this._dynamicObjectLabel:', this._dynamicObjectLabel);
        if(!this._dynamicObjectLabel)
        {
            if(!this.objectLabel || this.objectLabel==''){
                this.objectLabel = this.objName;                       
                if(this.objName.includes('__c'))
                {
                    this.objectLabel = this.objName.replace('__c','');   
                }else
                {
                    this.objectLabel = this.objName; 
                }        
                this.objectLabel = this.titleCase(this.objectLabel);
            }
            
        }
        //console.log('this.objectLabel:', this.objectLabel);
        let fieldList;
        if(this.wrapperDisplay && this.__defaultRecord)
        {
            this.displayFields = this.wrapperDisplay;
        }
        if( !Array.isArray(this.displayFields)){
            fieldList       = this.displayFields.split(',');
        }else{
            fieldList       = this.displayFields;
        }
        
        if(fieldList.length > 1){
            this.field  = fieldList[0].trim();
            this.field1 = fieldList[1].trim();
        }
        if(fieldList.length > 2){
            this.field2 = fieldList[2].trim();
        }
        if(fieldList.length > 3){
            this.field3 = fieldList[3].trim();
        }
        let combinedFields = [];
        fieldList.forEach(field => {
            if( !this.fields.includes(field.trim()) ){
                combinedFields.push( field.trim() );
            }
        });

        this.fields = combinedFields.concat( JSON.parse(JSON.stringify(this.fields)) );
        
    }

    handleInputChange(event){
        window.clearTimeout(this.delayTimeout);
        
            const searchKey = event.target.value;
            //this.isLoading = true;
            this.delayTimeout = setTimeout(() => {
                if(searchKey.length >= 2){
                    search({ 
                        objectName : this.objName,
                        fields     : this.fields,
                        searchTerm : searchKey,
                        filter:this.filter,
                        order:this.order,
                        limits:this.limits
                    })
                    .then(result => {
                        let stringResult = JSON.stringify(result);
                        let allResult    = JSON.parse(stringResult);
                        allResult.forEach( record => {
                            record.FIELD1 = record[this.field];
                            record.FIELD2 = record[this.field1];
                            if( this.field2 ){
                                record.FIELD3 = record[this.field2];
                            }else{
                                record.FIELD3 = '';
                            }
                            if( this.field3 && this._dynamicObjectLabel){
                                record.FIELD4 = record[this.field3];
                            }else{
                                record.FIELD4 = '';
                            }
                        });
                        this.searchRecords = allResult;
                        //console.log('variable:', this.searchRecords);
                    })
                    .catch(error => {
                        console.error('Error:handleInputChange- ', error);
                        console.error('Error:handleInputChange- ',json.stringify(error));
                    })
                    .finally(()=>{
                        //this.isLoading = false;
                    });
                }
            }, DELAY);
        
    }

    handleSelect(event){
        
        let recordId = event.currentTarget.dataset.recordId;
        //console.log('recordId:', recordId);
        this.selectedRecordChange(recordId);
    }
    // this method will help to set a default value mentioned specially when disabled and gets driven by other inputs as per business logic 
    selectedRecordChange(selectedRecordId)
    {
        this.selectedRecord = this.searchRecords.find((item) => {
            //console.log('item.Id:', item.Id);
            return item.Id === selectedRecordId;
        });const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {  
                data : {
                    record          : this.selectedRecord,
                    recordId        : selectedRecordId,
                    currentRecordId : this.currentRecordId
                }
            }
        });
        //console.log('selectedEvent:', selectedEvent);
        this.dispatchEvent(selectedEvent);
    }
    handleClose(event){
        this.selectedRecordClosed(event.currentTarget.dataset.recordId);        
    }
    selectedRecordClosed(recordId)
    {
        this.selectedRecord = undefined;
        this.searchRecords  = undefined;
        this.__defaultRecord = undefined;
        const selectedEvent = new CustomEvent('lookup', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {
                    data : {
                        record          : this.selectedRecord,
                        recordId        : recordId,
                        currentRecordId : this.currentRecordId
                     }
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    titleCase(string) {
        var sentence = string?.toLowerCase().split(" ");
        for(var i = 0; i< sentence.length; i++){
            sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
        }
        return sentence;
    }
}