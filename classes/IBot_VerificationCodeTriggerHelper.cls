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
public with sharing class IBot_VerificationCodeTriggerHelper {
    public static void handleAfterInsert(List<FscBot_Verification_Code__c> newRecords){
        sendVerificationCodes(newRecords);
    }
    
    private static void sendVerificationCodes(List<FscBot_Verification_Code__c> verificationCodes){
        try{
            Map<Id, FscBot_Verification_Code__c> contactVerificationCodeMap = new Map<Id, FscBot_Verification_Code__c>();
            for(FscBot_Verification_Code__c vc : verificationCodes){
                if(vc.Contact__c != null && !vc.Used__c){
                    contactVerificationCodeMap.put(vc.Contact__c, vc);
                }
            }
            
            if(contactVerificationCodeMap.isEmpty()){ return; }
            List<Id> contactIds = new List<Id>(contactVerificationCodeMap.keySet());
            List<Contact> contacts = IBot_DynamicQueryUtils.fetchContactsGivenIds(contactIds);
            
            List<IBot_ContactVerificationCodeBean> cvcMobileList = new List<IBot_ContactVerificationCodeBean>();
            List<IBot_ContactVerificationCodeBean> cvcEMailList = new List<IBot_ContactVerificationCodeBean>();
            //TODO Bulkify send emails
            for(Contact elem : contacts){
                FscBot_Verification_Code__c vc = contactVerificationCodeMap.get(elem.Id);
                if(String.isNotBlank(vc.Verification_Method__c) && vc.Verification_Method__c.equals('Email') && elem.email != null){
                    IBot_ContactVerificationCodeBean cvc = new IBot_ContactVerificationCodeBean();
                    cvc.verificationCode = vc;
                    cvc.c = elem;
                    cvcEMailList.add(cvc);
                }else {
                    IBot_ContactVerificationCodeBean cvc = new IBot_ContactVerificationCodeBean();
                    cvc.verificationCode = vc;
                    cvc.c = elem;
                    cvcMobileList.add(cvc);
                }
            }
            if(!cvcEMailList.isEmpty()) {
                IBot_GenericEmailService.getInstance().sendEmail(cvcEMailList);
            }
            IBot_PrintUtils.print('cvcMobileList ' + cvcMobileList);
            if(!cvcMobileList.isEmpty()) {
                IBot_GenericMessagingService.getInstance().sendSMS(cvcMobileList);
            }
        }catch(Exception e){
            //Swallow exception for now...
            IBot_PrintUtils.print(e);
        }
    }
}