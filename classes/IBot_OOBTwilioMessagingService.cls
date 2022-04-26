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
public with sharing class IBot_OOBTwilioMessagingService implements IBot_MessagingInterface{
    
    public void sendSMS(String phoneNumber, String smsBody){
        HttpRequest req = new HttpRequest();
        //read AccountId and Token from secret store. A managed package store 
        //for secrets and tokens.
        //This code assumes that the token and accountId are extracted from secret store
        //decrypted and then used here.
        String accountSid = IBot_ConfigSettings.getInstance().getTwilioAccountSid();
        String token = IBot_ConfigSettings.getInstance().getTwilioAuthToken();
        String twilioAccountPhoneNumber = IBot_ConfigSettings.getInstance().getTwilioFromPhoneNumber();
        
        String twilioEndPoint = IBot_ConfigSettings.getInstance().getTwilioEndPoint();
        IBot_PrintUtils.print('twilioEndPoint ' + twilioEndPoint);
        twilioEndPoint = twilioEndPoint.replace('{accountSid}',accountSid );
        req.setEndpoint(twilioEndPoint);
        req.setMethod('POST');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf(accountSid+':' +token)));
        req.setBody('To='+EncodingUtil.urlEncode(phoneNumber,'UTF-8')+'&From='+EncodingUtil.urlEncode(twilioAccountPhoneNumber,'UTF-8')+'&Body='+smsBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        IBot_PrintUtils.print(res.getBody());
    }

}