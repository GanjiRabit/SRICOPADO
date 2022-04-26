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
public with sharing class IBot_GenericEmailService implements IBot_ServiceInterface{
    private static IBot_GenericEmailService  botEmailService = new IBot_GenericEmailService ();

    /*
        private constructor to make a singleton instance
     */
    private IBot_GenericEmailService () {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static IBot_GenericEmailService getInstance() {
        return botEmailService;
    }
    
    @future(callout = true)
    private static void sendEmail(Decimal code, String email){
        String emailService = IBot_ConfigSettings.getInstance().getEmailService();
        Type emailServiceType = Type.forName(emailService);
        IBot_EmailInterface service = (emailServiceType == null) ? null : (IBot_EmailInterface)emailServiceType.newInstance();
        
        if(service != null) {
            service.sendEmail(code,email);
        }
    }
    
    public void sendEmail(List<IBot_ContactVerificationCodeBean> cvcBeanList){
        for(IBot_ContactVerificationCodeBean bean : cvcBeanList) {
            sendEmail(bean.verificationCode.Code__c, bean.c.Email);
        }
    }
}