/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
import { LightningElement, api, wire, track } from 'lwc';
import { getRecordUi } from 'lightning/uiRecordApi';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import CREATED_FIELD from '@salesforce/schema/Account.CreatedDate';

const fields = [REVENUE_FIELD, CREATED_FIELD];

import getDataSetsFromUsCommits from '@salesforce/apex/clsRetrieveDataSetContent.getDataSetsFromUsCommits';
let i=0;

export default class DisplayContact extends LightningElement {
     /** Id of record to display. */
    @api recordId; //this captures AccountId which is passed from Parent Component
    @track error;   //this holds errors

    @track dataSetItems = []; //this holds the array for records with value & label

    @track value = '';  //this displays selected value of combo box
    
    @wire(getDataSetsFromUsCommits, { userStoryId: 'a2V1F000003IKJXUA4'})    
    wiredDataSets({ error, data }) {
        if (data) {
            
            console.log(data );
            for (let key in data) {
                //console.log(key);
                //console.log(data[key]);
                //this.items.push({value:key, label:data[key]});
                this.dataSetItems = [...this.dataSetItems ,{value: key , label: data[key]}];    
             }
             /*
            for(i=0; i<data.length; i++) {
                console.log('id=' + data[i]);
                this.items = [...this.items ,{value: data[i] , label: data[i]}];                                   
            }  */
            //console.log('hi');
            //console.log('items'+this.items);              
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dataSetItems = undefined;
        }
    }
   
    //getter property from statusOptions which return the items array
    get dataSetNames() {
        console.log(this.dataSetItems);
        return this.dataSetItems;
    }

    handleDataSetChange(event) {
        // Get the string of the "value" attribute on the selected option
        const seletedDataSet = event.detail.value;
        console.log('selectedOption=' + seletedDataSet);

        //This is for event propagation
        
        const dataSetChangeEvent = new CustomEvent('dataSetChangeEvent', {
            detail: { seletedDataSet },
        });

        
        // Fire the custom event
        this.dispatchEvent(dataSetChangeEvent);
    }
    getSObjects(wiredData) {
        let sObject = {
            sobjectType: data.apiName,
            Id: data.id
        };
        Object.keys(wiredData.fields).map(fieldPath => {
            sObject[fieldPath] = wiredData.fields[fieldPath].value;
        });
        return sObject;
    }   
}