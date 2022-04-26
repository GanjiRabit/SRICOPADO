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
 * @description Util class to build OTP response for Email, Mobile and Google Auth methods
 **/
public with sharing class FscBot_OTPResponseUtils {
    public static IBot_OTPValidationCtrl.ValidationResponse buildVerifyOTPResponseForEmptyInput() {
        IBot_OTPValidationCtrl.ValidationResponse response = new IBot_OTPValidationCtrl.ValidationResponse();
        response.isValid = false;
        response.noOfRetries = 1;
        return response;
    }
    
    public static IBot_OTPValidationCtrl.ValidationResponse buildVerifyOTPResponse(IBot_OTPValidationCtrl.ValidationRequest input, Boolean isValid) {
        IBot_OTPValidationCtrl.ValidationResponse response = new IBot_OTPValidationCtrl.ValidationResponse();
        response.isValid = isValid;
        
        response.noOfRetries = input.noOfRetries == null ? 1 : input.noOfRetries + 1;
        if(!isValid && response.noOfRetries < 3) {
            response.retryVCValidation = true;
            response.transferToAgent = false;
        } else if(!isValid && response.noOfRetries >= 3) {
            response.retryVCValidation = false;
            response.transferToAgent = true;
            response.transferToAgentMessage = Label.ibot_exceeded_max_attempts;
        } else if(isValid) {
            response.retryVCValidation = false;
            response.transferToAgent = false;
        }
        IBot_PrintUtils.print('response ' + response);
        return response;
    }
    
    public static List<IBot_OTPValidationCtrl.ValidationResponse> buildVerifyOTPBulkResponse(List<IBot_OTPValidationCtrl.ValidationRequest> input, Boolean isValid) {
        
        List<IBot_OTPValidationCtrl.ValidationResponse> bulkResponse = new List<IBot_OTPValidationCtrl.ValidationResponse>();
        for(IBot_OTPValidationCtrl.ValidationRequest request :input) {
            bulkResponse.add(buildVerifyOTPResponse(request, isValid));
        }
        
        return bulkResponse;
    }
    
    /* This method compares the VC's from user to the codes stored in DB.
     * We also update the code to used once its verified. 
     */
    public static List<IBot_OTPValidationCtrl.ValidationResponse> verifyAndUpdateOTPCodes(List<IBot_OTPValidationCtrl.ValidationRequest> validationReqList,Map<String, FscBot_Verification_Code__c> verificationCodeMap) {
        List<IBot_OTPValidationCtrl.ValidationResponse> bulkResponse = new List<IBot_OTPValidationCtrl.ValidationResponse>();
        List<FscBot_Verification_Code__c> usedCodes = new List<FscBot_Verification_Code__c>();
        
        for(IBot_OTPValidationCtrl.ValidationRequest req : validationReqList){
            String code = req.verificationCode == null ? '' : Integer.valueOf(req.verificationCode).format();
            String contactId = req.contact == null ? '' : req.contact.Id;
            String key = contactId + '_' + code;
            //from DB
            FscBot_Verification_Code__c verificationCode = verificationCodeMap.get(key);
            if(verificationCode == null || String.isNotBlank(verificationCode.Verification_Method__c) && !verificationCode.Verification_Method__c.equals(req.verificationMethod)){
                bulkResponse.add(buildVerifyOTPResponse(req,false));
            }else{
                verificationCode.Used__c = true;
                usedCodes.add(verificationCode);
                bulkResponse.add(buildVerifyOTPResponse(req,true));
            }
        }
        
        if(usedCodes.size() > 0){
            IBot_DynamicQueryUtils.updateVerificaitonCodes(usedCodes);
        }
        return bulkResponse;
    } 

    public static IBot_ValidateTimebasedOTPCtrl.ValidationResponse buildTOPTResponseForEmptyInput() {
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = new IBot_ValidateTimebasedOTPCtrl.ValidationResponse();
        response.isValid = false;
        response.noOfRetries = 1;
        return response;
    }
    
    public static IBot_ValidateTimebasedOTPCtrl.ValidationResponse buildTOPTResponse(IBot_ValidateTimebasedOTPCtrl.ValidationRequest input, Boolean isValid) {
        IBot_ValidateTimebasedOTPCtrl.ValidationResponse response = new IBot_ValidateTimebasedOTPCtrl.ValidationResponse();
        response.isValid = isValid;
        response.noOfRetries = input.noOfRetries == null ? 1 : input.noOfRetries + 1;
        if(!isValid && response.noOfRetries < 3) {
            response.retryGAOTPValidation = true;
            response.transferToAgent = false;
        } else if(!isValid && response.noOfRetries >= 3) {
            response.retryGAOTPValidation = false;
            response.transferToAgent = true;
            response.transferToAgentMessage = Label.ibot_exceeded_max_attempts;
        } else if(isValid) {
            response.retryGAOTPValidation = false;
            response.transferToAgent = false;
        }
        return response;
    }
}