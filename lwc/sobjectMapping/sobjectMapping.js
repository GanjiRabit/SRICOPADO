import { LightningElement, api, track } from "lwc";
import {
  handleInputChangeService,
  log,
  addCustomIndexToList,
  callServerSideAction,
  showToast,
  validateForm
} from "c/commonServices";

import saveMapping from "@salesforce/apex/AccelQConnect.saveMapping";
import getFieldMapping from "@salesforce/apex/AccelQConnect.getFieldMapping";

export default class SobjectMapping extends LightningElement {
  @track objectAPIName;
  @track metadataInfo;
  @track showSpinner;
  @track jobMetadata;
  @track config;
  @track selfReference;

  isMetadataLoaded;
  isJobMetadataLoaded;
  isConfigLoaded;

  @api
  set sobjectAPIName(apiName) {
    try {
      this.metadataInfo = null;
      this.isMetadataLoaded = false;
      this.objectAPIName = apiName;
      this.selfReference = {};
      this.loadConfig();
    } catch (err) {
      log(">> error setting object ", err);
    }
  } //end of set sobjectAPIName

  get sobjectAPIName() {
    return this.objectAPIName;
  }
  constructor() {
    super();
    this.showSpinner = true;
    this.config = [];
  }

  connectedCallback() {
    //this.loadConfig();
  } //end of connectedcallback

  renderedCallback() {
    try {
      if (!this.isJobMetadataLoaded) this.loadJobMetadata();

      if (!this.isMetadataLoaded && this.objectAPIName)
        this.initateMetadataLoad();
    } catch (err) {
      log(err);
    }
  } //end of rendered callback

  loadJobMetadata() {
    try {
      let metadataRetriever = this.template.querySelector(
        "c-metadata-provider"
      );
      metadataRetriever
        .getMetadataInformation("CIJob__c")
        .then(resp => {
          let jobMetadata = JSON.parse(resp);
          jobMetadata = this.pepareEditableFields(jobMetadata);
          this.jobMetadata = jobMetadata;
          this.isJobMetadataLoaded = true;
        })
        .catch(err => {
          this.isJobMetadataLoaded = true;
          log(err);
        });
    } catch (err) {
      log(">> error iniating meadata load ", err);
    }
  } //end of loadJobMetadata

  initateMetadataLoad() {
    try {
      let metadataRetriever = this.template.querySelector(
        "c-metadata-provider"
      );
      metadataRetriever
        .getMetadataInformation(this.objectAPIName)
        .then(resp => {
          let metadataInfo = JSON.parse(resp);
          metadataInfo = this.pepareEditableFields(metadataInfo);
          log(">> metadata loaded ", metadataInfo);
          this.metadataInfo = metadataInfo;
          this.showSpinner = false;
          this.isMetadataLoaded = true;
        })
        .catch(err => {
          this.showSpinner = false;
          this.isMetadataLoaded = true;
          log(err);
        });
    } catch (err) {
      log(">> error iniating meadata load ", err);
    }
  } //end of initiate metadata load

  pepareEditableFields(metadataInfo) {
    try {
      metadataInfo.availableFields = [];
      Object.keys(metadataInfo.fields).forEach(field => {
        let fieldInfo = metadataInfo.fields[field];
        if (fieldInfo.updateable)
          metadataInfo.availableFields.push({
            label: fieldInfo.label,
            value: fieldInfo.apiName,
            dataType: fieldInfo.dataType
          });
      });
      metadataInfo.availableFields = addCustomIndexToList(
        metadataInfo.availableFields
      );
    } catch (err) {
      log(err);
    }
    return metadataInfo;
  } //end of pepareEditableFields

  loadConfig() {
    try {
      callServerSideAction(getFieldMapping, {
        objectAPIName: this.objectAPIName
      })
        .then(resp => {
          this.isConfigLoaded = true;
          this.config = resp.config ? addCustomIndexToList(resp.config) : [];
          this.selfReference =
            resp.selfReference && resp.selfReference.length > 0
              ? resp.selfReference[0]
              : {};
          log(">>CONFIG ", resp);
        })
        .catch(err => {
          this.isConfigLoaded = true;
          log(">>Error getting Config");
        });
    } catch (err) {
      log(err);
    }
  }

  get readyToDisplay() {
    let loadComp = true;
    try {
      loadComp =
        this.metadataInfo && this.jobMetadata && this.isConfigLoaded
          ? true
          : false;
    } catch (err) {
      log(err);
    }
    return loadComp;
  } //end of readyToDisplay

  saveConfig(event) {
    try {
      event.preventDefault();
      let isValid = validateForm(this);
      if (isValid) {
        let config = this.config;
        let configToCreate = config.filter(item => !item.isRemoved);
        let configToDelete = config.filter(item => item.isRemoved && item.Id);
        callServerSideAction(saveMapping, {
          configToCreate: JSON.stringify(configToCreate),
          configToDelete: JSON.stringify(configToDelete),
          selfReference: JSON.stringify(this.selfReference),
          objectAPIName: this.objectAPIName
        })
          .then(resp => {
            showToast("success", "Scuccess", resp, this);
          })
          .catch(err => {
            showToast("error", "Issue Saving Config", err, this);
          });
      }
    } catch (err) {
      log(">> unable to save config", err);
    }
  } //end of save config

  handleInputChange(event) {
    handleInputChangeService(event, this);
    this.config = this.config;
  }

  addConfig(event) {
    try {
      event.preventDefault();
      let config = this.config;
      config.push({
        isRemoved: false,
        itemIndex: config.length,
        MappingType__c: "fieldMapping"
      });
      this.config = config;
    } catch (err) {
      log(err);
    }
  } //end of add config

  removeConfig(event) {
    let config = this.config;
    let removedItem = event.target.getAttribute("data-item");
    this.config[removedItem].isRemoved = true;
    this.config = config;
  }
}