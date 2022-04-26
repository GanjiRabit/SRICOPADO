import { LightningElement, api, wire, track } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class CustomForm extends LightningElement {
  @track objectName;
  @track error;
  @track recordTypeId;
  @track requestQueue;
  @track metadataQueue;

  constructor() {
    super();
    this.requestQueue = this.requestQueue || {};
    this.metadataQueue = this.metadataQueue || [];
  }

  @wire(getObjectInfo, { objectApiName: "$objectName" })
  objectInformation({ error, data }) {
    if (this.objectName && this.requestQueue[this.objectName]) {
      if (data) {
        this.requestQueue[this.objectName].state = "done";
        this.requestQueue[this.objectName].data = JSON.stringify(data);
        this.requestQueue[this.objectName].resolve(
          this.requestQueue[this.objectName].data
        );
      } else {
        this.requestQueue[this.objectName].state = "err";
        this.requestQueue[this.objectName].data = error
          ? JSON.stringify(error)
          : "UnSupported Object API Name";
        this.requestQueue[this.objectName].reject(
          this.requestQueue[this.objectName].data
        );
      }
      this.manageQueue();
    }
  }

  manageQueue() {
    this.metadataQueue = this.metadataQueue.splice(1);
    if (this.metadataQueue.length > 0) {
      this.objectName = this.metadataQueue[0];
    } else {
      this.objectName = null;
    }
  }

  @api getMetadataInformation(objectName, recordTypeId) {
    const _self = this;

    return new Promise(function(resolve, reject) {
      try {
        if (
          _self.requestQueue[objectName] &&
          _self.requestQueue[objectName].state == "done"
        ) {
          resolve(_self.requestQueue[objectName].data);
        } else if (
          _self.requestQueue[objectName] &&
          _self.requestQueue[objectName].state == "err"
        ) {
          reject(_self.requestQueue[objectName].data);
        } else {
          _self.requestQueue[objectName] = {
            state: "pending",
            resolve: resolve,
            reject: reject
          };
          _self.recordTypeId = recordTypeId;

          //objectName = objectName.replace(/\w+/g,function(w){return w[0].toUpperCase() + w.slice(1).toLowerCase();});

          _self.metadataQueue.push(objectName);
          if (_self.metadataQueue.length == 1)
            _self.objectName = _self.metadataQueue[0];
        }
      } catch (err) {
        reject(err);
      }
    });
  }
}