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
public with sharing class IBot_GenericMessagingService implements IBot_ServiceInterface{
    private static IBot_GenericMessagingService  botMessagingService = new IBot_GenericMessagingService ();

    /*
        private constructor to make a singleton instance
     */
    private IBot_GenericMessagingService () {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static IBot_GenericMessagingService getInstance() {
        return botMessagingService;
    }
    
    @future(callout = true)
    private static void sendSMS(String phoneNumber, String smsBody){
        String messagingService = IBot_ConfigSettings.getInstance().getMessagingService();
        Type messagingServiceType = Type.forName(messagingService);
        IBot_MessagingInterface service = (messagingServiceType == null) ? null : (IBot_MessagingInterface)messagingServiceType.newInstance();
        
        if(service != null) {
            service.sendSMS(phoneNumber,smsBody);
        }
    }
    
    public void sendSMS(List<IBot_ContactVerificationCodeBean> cvcBeanList){
        for(IBot_ContactVerificationCodeBean bean : cvcBeanList) {
            sendSMS(bean.c.mobilePhone, 'Your Verification Code is ' + bean.verificationCode.Code__c);
        }
    }
}