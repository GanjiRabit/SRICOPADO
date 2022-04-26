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
 * @description Validates the financial account number input given by user
 **/

global with sharing class FscBot_ValidateInputAccountNumber {

    global class AccountNumberRequest {
        @InvocableVariable(required=true)
        global String lastDigitsOfAccount;
        @InvocableVariable
        global Integer noOfRetries;
    }
    
    global class ValidationResponse{
        @InvocableVariable
        global Boolean isValidLength;
        @InvocableVariable
        global Boolean isValid;
        @InvocableVariable
        global Integer inputLength;
        @InvocableVariable
        global Integer noOfRetries;
        @InvocableVariable
        global Boolean isTwoFactorAuthEnabled;
    }
    
	 /**
    * @description this invocable method is wired with a bot dialogue to validate the financial
    * account number input
    * @param List<AccountNumberRequest> accountNumberRequest
    * @return List<ValidationResponse>
    **/
    @InvocableMethod(label='Validate account number' description='Checks if the account number entered by customer has right no of digits')
    public static List<ValidationResponse> getNumberOfDigitsForAccountCheck(List<AccountNumberRequest> accountNumberRequestList) {
        List<ValidationResponse> responseList = new List<ValidationResponse>();
        for(AccountNumberRequest request : accountNumberRequestList){
            ValidationResponse response = new ValidationResponse();
            response.isValidLength = false;
            response.isValid = false;
            response.noOfRetries = (request.noOfRetries == null) ? 1 : request.noOfRetries + 1;
            response.isTwoFactorAuthEnabled = IBot_ConfigSettings.getInstance().isTwoFactorAuthenticationEnabled();
            Integer csnoofDigits = IBot_ConfigSettings.getInstance().getNoOfDigitsforAccCheck();
            if(!accountNumberRequestList.isEmpty()) {
                AccountNumberRequest areq = accountNumberRequestList.get(0);
                String inputAccountNumber = areq.lastDigitsOfAccount;
                response.inputLength = String.isNotBlank(inputAccountNumber) ? inputAccountNumber.length() : 0;
                if(String.isNotBlank(inputAccountNumber) && inputAccountNumber.length() == csnoofDigits) {
                    response.isValidLength = true;
                    response.isValid = true;
                }
                response.isValid = IBot_DynamicQueryUtils.validateFinancialAccountNumber(inputAccountNumber);
            }
    
            Ibot_PrintUtils.print(response);
            responseList.add(response);
            
        }
       	return responseList;
    }

}