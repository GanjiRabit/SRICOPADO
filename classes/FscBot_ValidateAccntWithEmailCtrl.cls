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
 * @description validates an individual's financial account with Email
 * and last n digits of financial account number
 **/
global with sharing class FscBot_ValidateAccntWithEmailCtrl {
    global class ValidationRequest{
        @InvocableVariable
        global String lastDigitsOfAccount;
        @InvocableVariable
        global String email;
        @InvocableVariable
        global String verificationMethod;
        @InvocableVariable
        global Integer noOfRetries;
    }
    
    global class ValidationResponse{
        @InvocableVariable
        global Integer noOfAccounts;
        @InvocableVariable
        global Contact contact;
        @InvocableVariable
        global String faccountId;
        @InvocableVariable
        global String poAccountId;
        @InvocableVariable
        global String faccountNumber;
        @InvocableVariable
        global Integer noOfRetries;
        @InvocableVariable
        global Boolean transferToAgent;
        @InvocableVariable
        global Boolean retryEmailvalidation;
        @InvocableVariable
        global String transferToAgentMessage;
        @InvocableVariable
        global Boolean sendVerificationCode;
    }
    
    /**
    * @description this invocable method is wired with a bot dialogue to validate a financial
    * account with Email and last n digits of account number
    * @param List<ValidationRequest> validationRequest
    * @return List<ValidationResponse>
    **/
    @InvocableMethod(label='Validate Account Using Email and Account Number' description='Retruns the Financial Account associated with Email and Last Six Digits of Financial Account')
    public static List<ValidationResponse> validateAccountWithEmail(List<ValidationRequest> validationRequest) {
        IBot_PrintUtils.print('validationRequest ' + validationRequest);
        List<ValidationResponse> bulkResponse = new List<ValidationResponse>();
        ValidationResponse response = new ValidationResponse();
        String accNumFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountNumberFieldAPIName();
        String financialAccountObjectAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountObjectAPIName();
        
        if(validationRequest == null || validationRequest.isEmpty() || validationRequest.get(0) == null) {
            bulkResponse.add(response);
            return bulkResponse;
        }
        
        ValidationRequest input = validationRequest.get(0);
        if(IBot_ConfigSettings.getInstance().isDemoModeEnabled() && String.isNotBlank(input.lastDigitsOfAccount)) {
            //this runs in the context where demo mode is enabled. This will retur dummy response.
            if(input.lastDigitsOfAccount.equals(IBot_ConfigSettings.getInstance().getDemoFinancialAccountNumber())) {
                response = FscBot_FAVResponseUtils.buildEVDemoResponse(input.email);
            }
        } else {
            //this runs in the context where demo mode is false and FSC package is installed
            List<sObject> accounts = String.isNotBlank(input.lastDigitsOfAccount) && String.isNotBlank(input.email) ? IBot_DynamicQueryUtils.fetchFinancialAccounts(input.lastDigitsOfAccount,input.email, input.verificationMethod) : new List<SObject>();
            
            IBot_PrintUtils.print('account size '+ accounts.size());
            response.noOfAccounts = accounts.size();
            response.sendVerificationCode = false;
            response = FscBot_FAVResponseUtils.buildEVResponse(response, accounts, input.noOfRetries); 
        } 
        IBot_PrintUtils.print(response);
        bulkResponse.add(response);
        return bulkResponse;
    }  
}