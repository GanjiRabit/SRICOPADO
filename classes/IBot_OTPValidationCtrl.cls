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
global with sharing class IBot_OTPValidationCtrl {
	global class ValidationRequest{
        @InvocableVariable
        global String verificationCode;
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
        global Boolean retryVCValidation;
        @InvocableVariable
        global String transferToAgentMessage;
        
    }

    @InvocableMethod(label='Validate OTP' description='Validates a verification code sent to contact')
	global static List<ValidationResponse> isValid(List<ValidationRequest> validationRequestList) {
        List<ValidationResponse> bulkResponse = new List<ValidationResponse>();
        
        if(validationRequestList == null || validationRequestList.isEmpty() || validationRequestList.get(0) == null){
            bulkResponse.add(FscBot_OTPResponseUtils.buildVerifyOTPResponseForEmptyInput());
			return bulkResponse;
        }
        
        // Collect contact Ids and codes for bulk processing
        List<String> contactIds = new List<String>();
        List<Integer> codes = new List<Integer>();

        for(ValidationRequest req : validationRequestList){
            // If OTP is not numeric, then it is invalid.
            if(!(req.verificationCode.isNumeric())){
                req.verificationCode='00000000';
            }
            req.verificationMethod = String.isNotBlank(req.verificationMethod) ? req.verificationMethod : 'Email';
            contactIds.add(req.contact.Id);
            codes.add(Integer.valueOf(req.verificationCode));
        }
        
        // Always valid code, for testing purposes
        if(IBot_ConfigSettings.getInstance().isOTPTestModeEnabled() && validationRequestList.get(0).verificationCode == String.valueOf(IBot_ConfigSettings.getInstance().getDemoOTP())){
            bulkResponse.add(FscBot_OTPResponseUtils.buildVerifyOTPResponse(validationRequestList.get(0), true));
			return bulkResponse;
        }  
        
        Map<String, FscBot_Verification_Code__c> verificationCodeMap = IBot_DynamicQueryUtils.fetchActiveVerificationCodesMap(contactIds,codes);
        IBot_PrintUtils.print(JSON.serialize(verificationCodeMap));
        
        if(verificationCodeMap.isEmpty()){
            bulkResponse = FscBot_OTPResponseUtils.buildVerifyOTPBulkResponse(validationRequestList, false);
            IBot_PrintUtils.print(bulkResponse);
			return bulkResponse;
        }

        bulkResponse = FscBot_OTPResponseUtils.verifyAndUpdateOTPCodes(validationRequestList,verificationCodeMap);
            
        return bulkResponse;
	}
}