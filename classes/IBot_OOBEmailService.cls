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
public with sharing class IBot_OOBEmailService implements IBot_EmailInterface{
	public void sendEmail(Decimal verificationCode, String email){
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        String orgWideEmailAddress = IBot_ConfigSettings.getInstance().getOrgWideEmailAddress();
        String noReplyEmailAddress = IBot_ConfigSettings.getInstance().getNoReplyEmailAddress();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(String.isNotBlank(orgWideEmailAddress)) {
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:orgWideEmailAddress limit 1];
            Id orgWideEmailAddressId = (owea.size() > 0) ? owea.get(0).Id : null;
            if (String.isNotBlank(orgWideEmailAddressId)) {
        		mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        	}
        }
        
        
        
        mail.toAddresses = new String[] { email};
        mail.setReplyTo(noReplyEmailAddress);
        mail.subject = Label.ibot_verification_code_subject;
        mail.plainTextBody = Label.ibot_verification_code_desc + ' ' + verificationCode ;
        messages.add(mail);
        
        if(!messages.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false); 
            for(Messaging.SendEmailResult result : results) {
                if (result.success) {
                    IBot_PrintUtils.print('The email was sent successfully.');
                } else {
                    IBot_PrintUtils.print('The email failed to send: ' + result.errors[0].message);
                } 
            }
        }
    }
    
}