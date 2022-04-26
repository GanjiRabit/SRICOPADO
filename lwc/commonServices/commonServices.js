import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import LogUIMessages from "@salesforce/label/c.LogUIMessages";
import B5G_Resources from "@salesforce/resourceUrl/B5G_Resources";

const callServerSideAction = (serverMethod, input) => {
  return new Promise((resolve, reject) => {
    serverMethod(input)
      .then(response => {
        try {
          if (response) {
            let result = JSON.parse(response);
            if (result.isSuccess) resolve(result.message);
            else reject(result.message);
          } else {
            reject("Unable to get server response");
          }
        } catch (error) {
          reject(error);
        }
      })
      .catch(error => {
        reject(error);
      });
  });
}; //end of call server side action helper

const showToast = (variant, title, message, _self) => {
  try {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    _self.dispatchEvent(evt);
  } catch (err) {}
}; // end of showToast helper

const addCustomIndexToList = list => {
  list.forEach((listItem, index) => {
    listItem.itemIndex = index;
    listItem.isRemoved =
      typeof listItem.isRemoved === "undefined" ? false : listItem.isRemoved;
  });
  return list;
}; //end of add custom index to list helper

const handleInputChangeService = (event, _self) => {
  try {
    let eventDetails =
      event.detail && typeof event.detail === "string"
        ? JSON.parse(event.detail)
        : null;
    let attributeToChange = eventDetails
      ? eventDetails.bindto
      : event.target.getAttribute("data-bind");
    let mainVariable = attributeToChange,
      dataType;
    let value = eventDetails
      ? eventDetails.value
      : event.target.value
      ? event.target.value
      : event.target.type === "text"
      ? null
      : event.target.checked;
    // log("value >> before trim " + value);
    // value = value ? value.trim() : value;
    // log("value >> after trim " + value);

    if (attributeToChange.indexOf(".") != -1) {
      mainVariable = attributeToChange.split(".")[0];
    }

    dataType = getDataType(mainVariable, _self);

    if (dataType === "object") setObjectKey(attributeToChange, event, _self);
    else if (dataType === "array") {
      setObjectkeyInArray(
        attributeToChange,
        mainVariable,
        event,
        _self,
        eventDetails ? eventDetails.itemindex : event.target.name
      );
      _self[attributeToChange] = _self[attributeToChange];
    } else _self[attributeToChange] = value;
  } catch (err) {
    log(err);
    showToast(
      "error",
      "Issue binding Input Value",
      err.stackTrace || err,
      _self
    );
  }
}; // end of handle input change service helper

const setObjectkeyInArray = (
  attribute,
  mainVariable,
  event,
  context,
  index
) => {
  try {
    attribute = attribute.split(".");
    attribute.splice(0, 1);
    attribute = attribute.join(".");
    setObjectKey(attribute, event, context[mainVariable][index]);
  } catch (err) {
    log("errorr ", err);
    showToast(
      "error",
      "Issue binding Input Value",
      err.stackTrace || err,
      context
    );
  }
}; // end of set object key in array helper

const setObjectKey = (attribute, event, context) => {
  try {
    let eventDetails =
      event.detail && typeof event.detail === "string"
        ? JSON.parse(event.detail)
        : null;
    let fieldPath = attribute.split(".");
    let field = context;
    let value = eventDetails
      ? eventDetails.value
      : event.target.value || event.target.checked;
    for (let i = 0; i < fieldPath.length - 1; i++) {
      field = field[fieldPath[i]];
    }
    field[fieldPath[fieldPath.length - 1]] = value;
  } catch (err) {
    log("errorr ", err);
    showToast("error", "Unable to bind value", err.stackTrace || err, context);
  }
}; // end of set object helper

const getDataType = (attribute, context) => {
  let dataType = "undefined";
  try {
    dataType = typeof context[attribute];
    dataType = Array.isArray(context[attribute]) ? "array" : dataType;
  } catch (err) {
    log("unable to decrypt data type ", err);
  }
  return dataType;
}; //end of get Data type helper

const validateForm = _self => {
  let isValid = true;
  try {
    let elementsToCheck = [
      "lightning-input",
      "lightning-combobox",
      "lightning-textarea"
    ];
    elementsToCheck.forEach(elementType => {
      _self.template.querySelectorAll(elementType).forEach(inputElement => {
        isValid = validateField(inputElement) ? isValid : false;
      });
    });
  } catch (err) {
    log(err);
  }
  return isValid;
}; // end of validate form

const validateField = inputElement => {
  let isValid = true;
  try {
    if (inputElement.setCustomValidity) {
      if (inputElement.required && !inputElement.value) {
        inputElement.setCustomValidity(
          `${inputElement.label || "Field"} is required`
        );
        isValid = false;
      } else {
        inputElement.setCustomValidity("");
      }
      if (
        isValid &&
        inputElement.checkValidity &&
        !inputElement.checkValidity()
      ) {
        isValid = false;
        inputElement.setCustomValidity(
          `Invalid value for ${inputElement.label || "Value"}`
        );
      }
      inputElement.reportValidity();
    }
  } catch (err) {
    log(err);
    isValid = false;
  }
  return isValid;
}; //end of validate field

const reportErrorOnField = (field, errorMessage) => {
  try {
    if (field && field.setCustomValidity) {
      field.setCustomValidity(errorMessage);
      if (field.reportValidity) field.reportValidity();
    }
  } catch (err) {
    log(err);
  }
}; //end of reportErrorOnField

const log = (...args) => {
  if (LogUIMessages.toLowerCase() == "true") {
    if (args) {
      args.forEach(argument => {
        console.log(argument);
      });
    }
  }
}; //end of log

const loadResources = (styles, scripts, _self) => {
  let promises = [];

  if (styles)
    styles.forEach(styleUrl => {
      promises.push(loadStyle(_self, styleUrl));
    });

  if (scripts)
    scripts.forEach(scriptUrl => {
      promises.push(loadScript(_self, scriptUrl));
    });

  return Promise.all(promises);
}; //end of loadResources

const loadStyleSheets = _self => {
  let styleSheets = [];
  //adding global variables
  styleSheets.push(B5G_Resources + "/css/B5G_GlobalVariables.css");

  //adding local style sheet from resources
  if (_self.styleSheetName)
    styleSheets.push(B5G_Resources + "/css/" + _self.styleSheetName + ".css");

  //adding global styles
  styleSheets.push(B5G_Resources + "/css/B5G_GlobalStyles.css");

  return loadResources(styleSheets, null, _self);
}; //end of loadStyleSheets

const getDropDownLabel = (ddOptions, value) => {
  let ddLabel = "";
  try {
    ddLabel = ddOptions.find(option => option.value === value).label;
  } catch (err) {
    log(err);
  }
  return ddLabel;
}; //end of getDropDownLabel

const getUrlParam = paramName => {
  let urlParam;
  try {
    urlParam = getAllUrlParams()[paramName];
  } catch (err) {
    log(err);
  }
  return urlParam;
}; //end of getUrlParam

const getAllUrlParams = () => {
  let urlParams = {};
  try {
    let parts = window.location.href.replace(
      /[?&]+([^=&]+)=([^&]*)/gi,
      function(m, key, value) {
        urlParams[key] = value;
      }
    );
  } catch (err) {
    log(err);
  }
  return urlParams;
}; //end of getAllUrlParams

const openWindow = (url, urlParams) => {
  try {
    let redirectUrlParams = url.split(">>");
    if (urlParams) redirectUrlParams[0] += urlParams;
    window.open(redirectUrlParams[0], redirectUrlParams[1]);
  } catch (err) {
    log(err);
  }
}; //end of openWindow

const digestableDate = dateString => {
  let formattedDate;
  try {
    let monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    let dateSplit = dateString.split("-");
    let targetDate = new Date(
      parseInt(dateSplit[0]),
      parseInt(dateSplit[1]) - 1,
      parseInt(dateSplit[2])
    );
    formattedDate = `${
      monthNames[targetDate.getMonth()]
    } ${targetDate.getDate()}, ${targetDate.getFullYear()}`;
  } catch (err) {
    log(err);
  }
  return formattedDate;
}; //end of digestabledate

export {
  callServerSideAction,
  showToast,
  addCustomIndexToList,
  handleInputChangeService,
  validateForm,
  log,
  loadResources,
  validateField,
  getDropDownLabel,
  reportErrorOnField,
  getUrlParam,
  getAllUrlParams,
  openWindow,
  digestableDate,
  loadStyleSheets
};