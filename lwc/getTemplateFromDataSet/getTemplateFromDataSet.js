/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
import { LightningElement, api, wire, track } from 'lwc';

import getTemplateFromDataSet from '@salesforce/apex/clsRetrieveDataSetContent.getTemplateFromDataSet';
let i=0;

export default class DisplayContact extends LightningElement {
     /** Id of record to display. */
    @api recordId; //this captures AccountId which is passed from Parent Component
    @track error;   //this holds errors

    @track dataTemplateItems = []; //this holds the array for records with value & label

    @track value = '';  //this displays selected value of combo box

    /* Load dataTemplates related to User Stories */
    //@wire(getDataTemplatesFromUsCommits, { userStoryId: '$recordId'})
    @wire(getTemplateFromDataSet, { dataSetId: 'a4h1F000000ScEvQAK'})    
    wiredDataTemplates({ error, data }) {
        if (data) {
            
            //console.log(data );
            for (let key in data) {
                //console.log(key);
                //console.log(data[key]);
                //this.items.push({value:key, label:data[key]});
                this.dataTemplateItems = [...this.dataTemplateItems ,{value: key , label: data[key]}];    
             }
             /*
            for(i=0; i<data.length; i++) {
                console.log('id=' + data[i]);
                this.items = [...this.items ,{value: data[i] , label: data[i]}];                                   
            }  */
            console.log('hi');
            //console.log('items'+this.items);              
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.dataTemplateItems = undefined;
        }
    }
   
    //getter property from statusOptions which return the items array
    get dataTemplateNames() {
        //console.log(this.dataTemplateItems);
        return this.dataTemplateItems;
    }

    handleDataTemplateChange(event) {
        // Get the string of the "value" attribute on the selected option
        const seletedDataTemplate = event.detail.value;
        console.log('selectedOption=' + seletedDataTemplate);

        //This is for event propagation
        
        const dataTemplateChangeEvent = new CustomEvent('dataTemplateChangeEvent', {
            detail: { seletedDataTemplate },
        });

        
        // Fire the custom event
        this.dispatchEvent(dataTemplateChangeEvent);
    }
    
}