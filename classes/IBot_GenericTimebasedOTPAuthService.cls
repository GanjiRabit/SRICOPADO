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
public with sharing class IBot_GenericTimebasedOTPAuthService implements IBot_ServiceInterface{
    private static IBot_GenericTimebasedOTPAuthService  botTimebasedOTPAuthService = new IBot_GenericTimebasedOTPAuthService ();

    /*
        private constructor to make a singleton instance
     */
    private IBot_GenericTimebasedOTPAuthService () {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static IBot_GenericTimebasedOTPAuthService getInstance() {
        return botTimebasedOTPAuthService;
    }
    
    public boolean isTimebasedOTPValid(Integer topt, String extUserId){
        boolean result = false;
        String toptAuthenticator = IBot_ConfigSettings.getInstance().getTimebasedOTPAuthenticator();
        Type topotAuthInterface = Type.forName(toptAuthenticator);
        IBot_TimebasedOTPAuthenticatorInterface service = (topotAuthInterface == null) ? null : (IBot_TimebasedOTPAuthenticatorInterface)topotAuthInterface.newInstance();
        
        if(service != null) {
            result = service.isTimebasedOTPValid(topt,extUserId);
        }
        
        return result;
    }
}