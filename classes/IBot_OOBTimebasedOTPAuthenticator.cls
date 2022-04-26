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
public with sharing class IBot_OOBTimebasedOTPAuthenticator implements IBot_TimebasedOTPAuthenticatorInterface{
    public boolean isTimebasedOTPValid(Integer totp, String extUserId){
        String url = IBot_ConfigSettings.getInstance().getAuthyEndPoint();
        url = url.replace('{totp}', String.valueOf(totp) ).replace('{userId}', extUserId);
        //read appkey from secret store. A managed package store for secrets and tokens
        String appKey = IBot_ConfigSettings.getInstance().getTimebasedOTPAppKey();
        appKey = IBot_CryptoService.getInstance().decryptAndDecode64(appKey);
        HttpResponse res = verifyTotp(url,appKey);
        
        String response = res.getBody();
        IBot_PrintUtils.print('response ' + response);
        return validateTotpVerifyResponse(response);
        
    }
    
    public HttpResponse verifyTotp(String url, String appKey){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('X-Authy-API-Key',appkey);
     
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res;

    }
    
    public boolean validateTotpVerifyResponse(String response){
        JSONParser parser = JSON.createParser(response);
        Boolean isValid = false;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'success')) {
                // Get the value.
                parser.nextToken();
                // Check if validation is success
                isValid = Boolean.valueOf(parser.getText());
            }
        }
        
        return isValid;
    }
}