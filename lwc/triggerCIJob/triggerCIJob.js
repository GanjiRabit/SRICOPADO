import { LightningElement, api } from "lwc";
import { log, callServerSideAction, showToast } from "c/commonServices";
import triggerMonitoringService from "@salesforce/apex/AccelQConnect.triggerMonitoringService";
import createNewJob from "@salesforce/apex/AccelQConnect.createNewJob";
export default class TriggerCIJob extends LightningElement {
  @api recordId;
  @api triggerNewJob;

  connectedCallback() {
    if (!this.triggerNewJob) this.runJob();
    else this.initiateJob();
  } //end of connected callback

  runJob() {
    try {
      if (this.recordId) {
        callServerSideAction(triggerMonitoringService, {
          recordId: this.recordId
        })
          .then(result => {
            showToast("success", "Success", result, this);
            this.notifyParent();
          })
          .catch(err => {
            showToast("error", "Error", err, this);
            this.notifyParent();
          });
      } else {
        showToast("error", "Error", "No Job ID Found", this);
      }
    } catch (err) {
      log(err);
    }
  } //end of initate job

  initiateJob() {
    try {
      if (this.recordId) {
        callServerSideAction(createNewJob, {
          recordId: this.recordId
        })
          .then(result => {
            showToast("success", "Success", result, this);
            this.notifyParent();
          })
          .catch(err => {
            showToast("error", "Error", err, this);
            this.notifyParent();
          });
      } else {
        showToast("error", "Error", "No Job ID Found", this);
      }
    } catch (err) {
      log(err);
    }
  } //end of initate job

  notifyParent() {
    this.dispatchEvent(new CustomEvent("closedialog"));
  }
}