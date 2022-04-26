/*  Copyright [2018] [salesforce.com]
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
/**
 * @description
 **/
global with sharing class IBot_ValidateTimebasedOTPCtrl {
    global class ValidationRequest{
        @InvocableVariable
        global Integer verificationCode;
        @InvocableVariable
        global Contact contact;
        @InvocableVariable
        global Integer noOfRetries;
        @InvocableVariable
        global String verificationMethod;
    }

     global class ValidationResponse{
        @InvocableVariable
        global boolean isValid;
        @InvocableVariable
        global Integer noOfRetries;
        @InvocableVariable
        global Boolean transferToAgent;
        @InvocableVariable
        global Boolean retryGAOTPValidation;
        @InvocableVariable
        global String transferToAgentMessage;
    }

    @InvocableMethod(label='Validate TimebasedOTP' description='Validates the TimebasedOTP given by the User')
    global static List<ValidationResponse> isValid(List<ValidationRequest> validationRequestList) {
        List<ValidationResponse> bulkResponse = new List<ValidationResponse>();
        
        if(validationRequestList == null || validationRequestList.isEmpty() || validationRequestList.get(0) == null){
            bulkResponse.add(FscBot_OTPResponseUtils.buildTOPTResponseForEmptyInput());
			return bulkResponse;
        }
        
        // Always valid code, for testing purposes
        if(IBot_ConfigSettings.getInstance().isOTPTestModeEnabled() && validationRequestList.get(0).verificationCode == IBot_ConfigSettings.getInstance().getDemoOTP()){
            bulkResponse.add(FscBot_OTPResponseUtils.buildTOPTResponse(validationRequestList.get(0), true));
			return bulkResponse;
        }
        
        List<Boolean> results = new List<Boolean>();
        IBot_GenericTimebasedOTPAuthService toptAuthenticatorService = IBot_GenericTimebasedOTPAuthService.getInstance();
        
        for(ValidationRequest vr : validationRequestList){
            Boolean isGAOTPValid = toptAuthenticatorService.isTimebasedOTPValid(vr.verificationCode, (String) vr.contact.get('GAUserId__c'));
            ValidationResponse vresponse = FscBot_OTPResponseUtils.buildTOPTResponse(vr,isGAOTPValid);
            bulkResponse.add(vresponse);
        }
        
        return bulkResponse;
    }
}