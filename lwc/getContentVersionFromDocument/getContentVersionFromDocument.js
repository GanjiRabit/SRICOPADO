/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
import { LightningElement, api, wire, track } from 'lwc';

import getContentVersionFromDocument from '@salesforce/apex/clsRetrieveDataSetContent.getContentVersionFromDocument';
let i=0;

export default class DisplayContact extends LightningElement {
     /** Id of record to display. */
    @api recordId; //this captures AccountId which is passed from Parent Component
    @track error;   //this holds errors

    @track contentDocumentItems = []; //this holds the array for records with value & label

    @track value = '';  //this displays selected value of combo box

    /* Load contentDocuments related to User Stories */
    //@wire(getContentDocumentsFromUsCommits, { userStoryId: '$recordId'})
    @wire(getContentVersionFromDocument, { contentDocId: '0691F000001LEx3QAG'})    
    wiredContentDocuments({ error, data }) {
        if (data) {
            
            //console.log(data );
            for (let key in data) {
                //console.log(key);
                //console.log(data[key]);
                //this.items.push({value:key, label:data[key]});
                this.contentDocumentItems = [...this.contentDocumentItems ,{value: key , label: data[key]}];    
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
            this.contacts = undefined;
        }
    }
   
    //getter property from statusOptions which return the items array
    get contentDocumentNames() {
        //console.log(this.contentDocumentItems);
        return this.contentDocumentItems;
    }

    handleContentDocumentChange(event) {
        // Get the string of the "value" attribute on the selected option
        const selectedSourceFileVersionOption = event.detail.value;
        console.log('selectedOption=' + selectedSourceFileVersionOption);

        //This is for event propagation
        
        const contentDocumentSourceChangeEvent = new CustomEvent('contentDocumentSourceChangeEvent', {
            detail: { selectedSourceFileVersionOption },
        });

        
        // Fire the custom event
        this.dispatchEvent(contentDocumentSourceChangeEvent);
    }
    handleContentDocumentTargetChange(event) {
        // Get the string of the "value" attribute on the selected option
        const selectedTargetFileVersionOption = event.detail.value;
        console.log('selectedOption=' + selectedTargetFileVersionOption);

        //This is for event propagation
        
        const contentDocumentTargetChangeEvent = new CustomEvent('contentDocumentTargetChangeEvent', {
            detail: { selectedTargetFileVersionOption },
        });

        
        // Fire the custom event
        this.dispatchEvent(contentDocumentTargetChangeEvent);
    }
    
}