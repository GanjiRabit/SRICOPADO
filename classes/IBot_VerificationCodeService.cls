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
global with sharing class IBot_VerificationCodeService {
	global class VerificationCodeRequest{
        @InvocableVariable
        global String contactEmailorMobile;
        @InvocableVariable
        global String verificationType;
        @InvocableVariable
        global String primaryAccountId;
    }
    
    global class ContactVerificationMethod {
        global string verificationMethod;
        global Contact individual;
    }

    @InvocableMethod(label='Send OTP' description='Sends a verification code to the specified contact')
    global static void sendVerificationCode(List<VerificationCodeRequest> requestList) {
		Set<String> verificationEmailSet = new Set<String>();
		Set<String> verificationMobileSet = new Set<String>();
        Set<Id> primaryAccountIds = new Set<Id>();
        for(VerificationCodeRequest vcr : requestList){
            vcr.verificationType = String.isBlank(vcr.verificationType)?'Email':vcr.verificationType;
            if(String.isNotBlank(vcr.verificationType) && vcr.verificationType.equalsIgnoreCase('Mobile Number')){
                verificationMobileSet.add(vcr.contactEmailorMobile);
            }else{
                verificationEmailSet.add(vcr.contactEmailorMobile);
            }
            primaryAccountIds.add(vcr.primaryAccountId);
        }
        
        Map<String, Contact> accountIdContactMap = IBot_DynamicQueryUtils.fetchContactsGivenAccntAndMobileOREmail(verificationEmailSet,verificationMobileSet,primaryAccountIds);
        
        IBot_PrintUtils.print('primaryAccountIds ' + primaryAccountIds);
        IBot_PrintUtils.print('accountIdContactMap ' + accountIdContactMap);
        
        if(accountIdContactMap.isEmpty()){
            return;
        }
        
        List<Contact> filteredContacts = new List<Contact>();
        List<ContactVerificationMethod> filteredRequests = new List<ContactVerificationMethod>();
        for(VerificationCodeRequest vcr : requestList) {
            Id poaccId = vcr.primaryAccountId;
            Contact c = accountIdContactMap.get(poaccId);
            if( c !=null) {
                filteredContacts.add(c);
                ContactVerificationMethod cvm = new ContactVerificationMethod();
                cvm.verificationMethod = vcr.verificationType;
                cvm.individual = c;
                filteredRequests.add(cvm);
            }

        }
        IBot_PrintUtils.print('filteredContacts ' + filteredContacts);
        IBot_PrintUtils.print('filteredRequests ' + filteredRequests);

        IBot_DynamicQueryUtils.clearExistingVerificationCodes(filteredContacts);
        createNewVerificationCodes(filteredRequests);
    }
    
    private static void createNewVerificationCodes(List<contactVerificationMethod> cvmList){
        List<FscBot_Verification_Code__c> newCodes = new List<FscBot_Verification_Code__c>();
        for(contactVerificationMethod cvm: cvmList){
            FscBot_Verification_Code__c vc = new FscBot_Verification_Code__c();
            vc.Contact__c = cvm.individual.Id;
            vc.Expires_On__c = DateTime.now().addMinutes(IBot_ConfigSettings.getInstance().getVCExpirationMinutes());
            vc.Code__c = IBot_Utils.generateRandomCode();
            vc.Verification_Method__c = cvm.verificationMethod ;
            newCodes.add(vc);
        }
       	
        IBot_PrintUtils.print('newCodes ' + newCodes);
        if(!newCodes.isEmpty()) {
            IBot_DynamicQueryUtils.createNewVerificationCodes(newCodes);
        }
    }
}