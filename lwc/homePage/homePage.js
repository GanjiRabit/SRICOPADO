import { LightningElement, track } from "lwc";
import {
  log,
  loadStyleSheets,
  handleInputChangeService,
  callServerSideAction,
  showToast,
  validateForm,
  getDropDownLabel,
  addCustomIndexToList,
  validateField
} from "c/commonServices";

import getConfig from "@salesforce/apex/AccelQConnect.getConfig";
import verifyCredentials from "@salesforce/apex/AccelQConnect.verifyCredentials";
import saveConfig from "@salesforce/apex/AccelQConnect.saveConfig";

export default class HomePage extends LightningElement {
  @track config;
  @track showSpinner;
  @track authTypeOptions;
  @track metadataInfo;
  @track sobjectVariant;
  @track sobjectVariations;
  @track verifiedProjectOptions;
  stylesLoaded = false;
  styleSheetName = "B5G_Home";
  jobMetadataLoaded = false;

  constructor() {
    super();
    this.loadConfig();
    this.metadataInfo = {};
    this.showSpinner = true;
    this.sobjectVariations = [];
  } //end of constructor

  renderedCallback() {
    try {
      if (!this.stylesLoaded) {
        loadStyleSheets(this)
          .then(() => {
            this.stylesLoaded = true;
          })
          .catch(err => {
            log(err);
          });
      }
      if (!this.jobMetadataLoaded) this.fetchMetadata("CIJob__c", false);
    } catch (err) {
      log(err);
    }
  } //end of renderedCallback

  connectedCallback() {} //end of connected callback

  fetchMetadata(objectAPIName, controlSpinner) {
    try {
      if (controlSpinner) this.showSpinner = true;

      let metadataRetriever = this.template.querySelector(
        "c-metadata-provider"
      );
      metadataRetriever
        .getMetadataInformation(objectAPIName)
        .then(resp => {
          if (controlSpinner) this.showSpinner = false;
          this.metadataInfo[objectAPIName] = JSON.parse(resp);
          this.jobMetadataLoaded = true;
          log(">> metadata ", this.metadataInfo);
          this.setMetadataForVariations();
        })
        .catch(err => {
          if (controlSpinner) this.showSpinner = false;
          this.jobMetadataLoaded = true;
          log(err);
        });
    } catch (err) {
      log(err);
    }
  } //end of fetch Metadata

  setMetadataForVariations() {
    try {
      this.sobjectVariations.forEach(variation => {
        variation.metadata = this.metadataInfo[variation.apiName];
      });

      this.sobjectVariations = this.sobjectVariations;
    } catch (err) {
      log(err);
    }
  } //end of setMetadataForVariations

  loadConfig() {
    try {
      this.showSpinner = true;
      callServerSideAction(getConfig, {})
        .then(config => {
          this.setAuthTypeOptions();
          config.accelQAuthValidated = "false";
          this.config = config;
          this.showSpinner = false;
        })
        .catch(err => {
          this.showSpinner = false;
          log("Error in load config ", err);
          showToast("error", "Unable to get config", err, this);
        });
    } catch (err) {
      log(err);
    }
  } //end of load config

  setAuthTypeOptions() {
    try {
      this.authTypeOptions = [
        { label: "Manual", value: "Manual" }
        // { label: "Named Credential", value: "Named Credential" }
      ];
    } catch (err) {
      log(err);
    }
  } //end of setAuthTypeOptions

  handleInputChange(event) {
    try {
      handleInputChangeService(event, this);
    } catch (err) {
      log(err);
    }
  } //end of handle input

  verifyEnteredCredentials(event) {
    try {
      event.preventDefault();
      if (!validateForm(this)) return;
      this.config.accelQAuthValidated = "false";
      this.config.accelQAuthLastValidatedOn = false;
      this.showSpinner = true;
      callServerSideAction(verifyCredentials, {
        userName: this.config.accelQUserName,
        password: this.config.accelQPassword,
        url: this.config.accelQUrl
      })
        .then(result => {
          this.showSpinner = false;

          if (result.isSuccess && result.statusCode === 200) {
            log(result);
            showToast("success", "Success", "Login Successful", this);
            this.config.accelQAuthValidated = "true";
            this.config.accelQAuthLastValidatedOn = new Date().toString();
            let loginInfo = JSON.parse(result.message);
            this.verifiedProjectOptions = loginInfo.userProjects;
            this.config.accelQTenant = loginInfo.tenantCode;
            // this.config.accelQAuthLastValidatedOn = new Date().toString();
            // this.config.accelQAuthLastValidatedOn = new Date().toString();
            //this.config.
          } else if (result.isSuccess) {
            showToast(
              "error",
              "Error",
              JSON.parse(result.message).message,
              this
            );
          } else {
            showToast("error", "Error", result.message, this);
          }
        })
        .catch(err => {
          log(err);
          this.showSpinner = false;
        });
    } catch (err) {
      log(err);
    }
  } //end of verifyEnteredCredentials

  saveCredentials(event) {
    try {
      event.preventDefault();
      let isValid = validateForm(this);
      if (isValid) {
        let config = this.config;
        callServerSideAction(saveConfig, { config: JSON.stringify(config) })
          .then(() => {
            showToast("success", "Success", "Config Saved", this);
          })
          .catch(err => {
            showToast("error", "Unable to save config", err, this);
          });
      } else {
        showToast("error", "Fill Required Fields", "", this);
      }
    } catch (err) {
      log(err);
    }
  } //end of save credentials

  addVariation(event) {
    try {
      event.preventDefault();
    } catch (err) {
      log(err);
    }
  } //end of add variation

  addConfig(event) {
    try {
      let itemIndex = event.target.getAttribute("data-item");
      let variations = this.sobjectVariations;

      if (!variations[itemIndex].mapping) variations[itemIndex].mapping = [];
      variations[itemIndex].mapping.push({});

      this.sobjectVariations = variations;
    } catch (err) {
      log(err);
    }
  } //end of addConfig

  get readyToDisplay() {
    return this.config && this.stylesLoaded;
  } //end of get readyToDisplay

  get showManualDetails() {
    return this.config && this.config.accelQAuthType === "Manual";
  } //end of get showManualDetails

  get isVerifyDisabled() {
    return this.config && this.config.accelQAuthValidated === "true";
  } //end of get isVerifyDisabled

  get isSaveDisabled() {
    return !(this.config && this.config.accelQAuthValidated === "true");
  } //end of get isSaveDisabled

  get showJobFieldDefaults() {
    return this.config && this.jobMetadataLoaded;
  } //end of get SHow job field defaults

  get projectOptions() {
    let options = [];

    try {
      if (this.verifiedProjectOptions) {
        this.verifiedProjectOptions.forEach(project => {
          options.push({
            label: project.projectDisplayName,
            value: project.projectName
          });
        });
      } else {
        options.push({
          label: this.config.accelQDefaultProject,
          value: this.config.accelQDefaultProject
        });
      }
    } catch (err) {
      log(err);
    }
    return options;
  } //end of projectOptions
}