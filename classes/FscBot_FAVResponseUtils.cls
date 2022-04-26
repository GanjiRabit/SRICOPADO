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
 * @description Util class to build financial account validation response for Email, Mobile and Google Auth methods
 **/
public with sharing class FscBot_FAVResponseUtils {
      
    public static FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse buildGAVDemoResponse(String gaUserId) {
        FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse response = new FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse();
        response.noOfAccounts = 1;
        response.faccountNumber = '016601548212121';
        response.faccountId = 'XXXXXXXX';
        response.poAccountId = 'XXXXXX';
        Contact primaryContact = new Contact();
        response.transferToAgent = false;
        response.retryGAValidation = false;
        primaryContact.put('FirstName','Rachel');
        primaryContact.put('LastName','Adamas');
        primaryContact.put('GAUserId__c',gaUserId);
        response.contact = primaryContact;
        response.noOfRetries = 1; 
        
        return response;
    }

    public static FscBot_ValidateAccntWithEmailCtrl.ValidationResponse buildEVDemoResponse(String email) {
        FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response = new FscBot_ValidateAccntWithEmailCtrl.ValidationResponse();
        response.noOfAccounts = 1;
        response.faccountNumber = '016601548212121';
        response.faccountId = 'xxxxxxx';
        response.poAccountId = 'xxxxxx';
        response.transferToAgent = false;
        response.retryEmailvalidation = false;
        response.sendVerificationCode = true;
        Contact primaryContact = new Contact();
        primaryContact.put('FirstName','Rachel');
        primaryContact.put('LastName','Adamas');
        primaryContact.put('Email',email);
        response.contact = primaryContact;
        response.noOfRetries = 1; 

        return response;
    }

    public static FscBot_ValidateAccntWithMobileNumCtrl.ValidationResponse buildMVDemoResponse(String mobileNumber) {
        FscBot_ValidateAccntWithMobileNumCtrl.ValidationResponse response = new FscBot_ValidateAccntWithMobileNumCtrl.ValidationResponse();
        response.noOfAccounts = 1;
        response.faccountNumber = '016601548212121';
        response.faccountId = 'xxxxxxx';
        response.poAccountId = 'xxxxxx';
        response.transferToAgent = false;
        response.retryPhoneValidation = false;
        response.sendVerificationCode = true;
        Contact primaryContact = new Contact();
        primaryContact.put('FirstName','Rachel');
        primaryContact.put('LastName','Adamas');
        primaryContact.put('MobilePhone',mobileNumber);
        response.contact = primaryContact;
        response.noOfRetries = 1; 

        return response;
    }
    
    public static FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse populateGAVResponse(FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse response,Boolean retryGAValidation,Boolean transferToAgent, String transferToAgentMessage) {
        response.transferToAgent = transferToAgent;
        response.transferToAgentMessage = transferToAgentMessage;
        response.retryGAValidation = retryGAValidation;     
        return response;
    }

    public static FscBot_ValidateAccntWithEmailCtrl.ValidationResponse populateEVResponse(FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response,Boolean retryEmailValidation,Boolean transferToAgent, Boolean sendVerificationCode, String transferToAgentMessage) {
        response.transferToAgent = transferToAgent;
        response.transferToAgentMessage = transferToAgentMessage;
        response.retryEmailValidation = retryEmailValidation; 
        response.sendVerificationCode = sendVerificationCode; 
        return response;
    }

    public static FscBot_ValidateAccntWithMobileNumCtrl.ValidationResponse populateMVResponse(FscBot_ValidateAccntWithMobileNumCtrl.ValidationResponse response,Boolean retryMobileValidation,Boolean transferToAgent, Boolean sendVerificationCode, String transferToAgentMessage) {
        response.transferToAgent = transferToAgent;
        response.transferToAgentMessage = transferToAgentMessage;
        response.retryPhoneValidation = retryMobileValidation; 
        response.sendVerificationCode = sendVerificationCode;    
        return response;
    }

    public static FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse buildGAVResponse(FscBot_ValAccWithGAUser_AccntNumberCtrl.ValidationResponse response, List<Sobject> accounts, Integer noOfRetries) {
        response.noOfRetries = (noOfRetries == null) ? 1 : noOfRetries + 1;
        if(response.noOfAccounts == 0) {
            if(response.noOfRetries == 3) {
                 //response,retryGAValidation,transferToAgent,sendVerificationCode,transferToAgentMessage
                response = FscBot_FAVResponseUtils.populateGAVResponse(response, false, true, Label.ibot_exceeded_max_attempts);
            } else {
                response = FscBot_FAVResponseUtils.populateGAVResponse(response, true, false, '');
            }
        } else if( response.noOfAccounts > 1) {
            response = FscBot_FAVResponseUtils.populateGAVResponse(response, false, true, Label.ibot_could_find_the_info);
        } else if(response.noOfAccounts == 1) {
            response = FscBot_FAVResponseUtils.populateGAVResponse(response, false, false, '');
            Sobject finAccount = accounts.get(0);
            String accNumFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountNumberFieldAPIName();
            String poAccountIdField = IBot_ConfigSettings.getInstance().getFinancialAccountPOFieldAPIName();
            response.faccountNumber = (String) finAccount.get(accNumFieldAPIName);
            response.faccountId= (String) finAccount.get('Id');
            response.poAccountId = (String) finAccount.get(poAccountIdField); 
            response.contact = IBot_Utils.buildContactSObject(finAccount);
        }

        return response;
    }

    public static FscBot_ValidateAccntWithEmailCtrl.ValidationResponse buildEVResponse(FscBot_ValidateAccntWithEmailCtrl.ValidationResponse response,List<Sobject> accounts, Integer noOfRetries) {
        response.noOfRetries = (noOfRetries == null) ? 1 : noOfRetries + 1;
        if(response.noOfAccounts == 0) {
            if(response.noOfRetries == 3) {
                //response,retryEmailvalidation,transferToAgent,sendVerificationCode,transferToAgentMessage
                response = FscBot_FAVResponseUtils.populateEVResponse(response, false, true, false, Label.ibot_exceeded_max_attempts);
            } else {
                response = FscBot_FAVResponseUtils.populateEVResponse(response, true, false, false, '');
            }
        } else if( response.noOfAccounts > 1) {
            response = FscBot_FAVResponseUtils.populateEVResponse(response, false, true, false, Label.ibot_could_find_the_info);
        } else if(response.noOfAccounts == 1) {
            Boolean sendVerificationCode = IBot_ConfigSettings.getInstance().isTwoFactorAuthenticationEnabled() ? true : false;
            response = FscBot_FAVResponseUtils.populateEVResponse(response, false, false, sendVerificationCode, '');
            String accNumFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountNumberFieldAPIName();
            String poAccountIdField = IBot_ConfigSettings.getInstance().getFinancialAccountPOFieldAPIName();
            Sobject finAccount = accounts.get(0);
            response.faccountNumber = (String) finAccount.get(accNumFieldAPIName);
            response.faccountId= (String) finAccount.get('Id');
            response.poAccountId = (String) finAccount.get(poAccountIdField); 
            response.contact = IBot_Utils.buildContactSObject(finAccount);
        }    
        return response;
    }

    public static FscBot_ValidateAccntWithMobileNumCtrl.ValidationResponse buildMVResponse(FscBot_ValidateAccntWithMobileNumCtrl.ValidationResponse response,List<Sobject> accounts, Integer noOfRetries) {
        response.noOfRetries = (noOfRetries == null) ? 1 : noOfRetries + 1;
        if(response.noOfAccounts == 0) {
            if(response.noOfRetries == 3) {
                 //response,retryPhoneValidation,transferToAgent,sendVerificationCode,transferToAgentMessage
                response = FscBot_FAVResponseUtils.populateMVResponse(response, false, true, false, Label.ibot_exceeded_max_attempts);
            } else {
                response = FscBot_FAVResponseUtils.populateMVResponse(response, true, false, false, '');
            }
        } else if( response.noOfAccounts > 1) {
            response = FscBot_FAVResponseUtils.populateMVResponse(response, false, true, false, Label.ibot_could_find_the_info); 
        } else if(response.noOfAccounts == 1) {
            response = FscBot_FAVResponseUtils.populateMVResponse(response, false, false, true, '');
            Sobject finAccount = accounts.get(0);
            String accNumFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountNumberFieldAPIName();
            String poAccountIdField = IBot_ConfigSettings.getInstance().getFinancialAccountPOFieldAPIName();
            response.faccountNumber = (String) finAccount.get(accNumFieldAPIName);
            response.faccountId= (String) finAccount.get('Id');
            response.poAccountId = (String) finAccount.get(poAccountIdField); 
            response.contact = IBot_Utils.buildContactSObject(finAccount);
        }    
        return response;
    }
}