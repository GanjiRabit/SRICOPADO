import {LightningElement,api,wire} from "lwc";
import {NavigationMixin} from 'lightning/navigation';
import {CurrentPageReference} from 'lightning/navigation';
export default class CompareDataVersion extends NavigationMixin(LightningElement){
@api tabName= 'Compare_Data_Version';
_recordId;

@api set recordId(value) {
    this._recordId = value;

    // do your thing right here with this.recordId / value
}

get recordId() {
    return this._recordId;
}
@api objectApiName;
//@wire(CurrentPageReference)
//pageRef;
@wire(CurrentPageReference)
 getStateParameters(currentPageReference) {
     if (currentPageReference) {
         this.recordId = currentPageReference.state.recordId;
     }
 }
  @api invoke() {
    console.log("Hi, I'm an action CompareDataVersion.");
    console.log('this.recordId: invoke', this._recordId);
    this[NavigationMixin.Navigate]({
        type: 'standard__navItemPage',
            attributes: {
                apiName: this.tabName,
                recordId:this._recordId,
                objectApiName:this.objectApiName
            },
            state: {
                c__recordId: this._recordId
            }
    });
  }
  connectedCallback() {
    
  }
  renderedCallback(){
    
  }
}