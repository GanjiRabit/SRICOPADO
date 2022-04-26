/**
 * author            : Debanjan Mukherjee
 * last modified   : 11-20-2021 Debanjan Mukherjee
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   11-20-2021   Debanjan Mukherjee   Initial Version
**/

import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {
   subscribe,
   MessageContext
} from 'lightning/messageService';
import STATUS_CHANGED_CHANNEL from '@salesforce/messageChannel/filterStatusChangeChannel__c';
export default class compareDataSet_v1 extends LightningElement {
    isModFilter=false;
     /** Id of record to display. */
    //@api recordId;//='a2V1F000003IKJXUA4'; //this captures AccountId which is passed from Parent Component
    @api  urlStateParameters;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.recordId = this.urlStateParameters.c__recordId;
       }
    } 
    @wire(MessageContext)
    statusMessageContext;
    // Encapsulate logic for LMS subscribe.
    subscribeToStatusChangedChannel() {
        ////console.log('subscribeToMessageChannel:');
        this.subscription = subscribe(
            this.statusMessageContext,
            STATUS_CHANGED_CHANNEL,
            (message) => this.handleSatusChanged(message)
        );
    }
    // Handler for message received by component
    handleSatusChanged(message) {
      console.log('compareDataSet : handleSatusChanged - ', message.Status);
      this.isModFilter = message.Status==='Modified'?true:false;
      if(isModFilter)
      this.template.this.template.querySelector('.modContainer').style.display='block';
      else
      this.template.this.template.querySelector('.modContainer').style.display='none';
      
    }          
    connectedCallback()
    {
      //this.subscribeToStatusChangedChannel();
    }
    
    handleToggleSection()
    {

    }
}