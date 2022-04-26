import { LightningElement,api,track,wire } from 'lwc';
import getLicenseInformation from '@salesforce/apex/CustomCapadoController.getLicenseInformation';

export default class CopadoLiscList extends LightningElement{
    @track responsedata;
   // @wire(getLicenseInformation) licenseInfo;
    
   connectedCallback(){
      
      return new Promise((resolve, reject) => {
         getLicenseInformation()
          .then((data) => {
             this.responsedata = data;
            //alert("data::"+JSON.stringify(data));
            //let tempData1 = JSON.parse(data);
            
          })
          .catch((err) => {
            alert("err2"+JSON.stringify(err));

          });
      });
    }
}