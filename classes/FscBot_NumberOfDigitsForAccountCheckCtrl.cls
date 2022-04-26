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
 * @description Fetches no of digits needed for account verification
 **/

global with sharing class FscBot_NumberOfDigitsForAccountCheckCtrl {

    global class NoOfDigitsResponse{
        @InvocableVariable
        global Integer noOfDigits;
        @InvocableVariable
        global String integrationUserId;
    }
    
    /**
    * @description this invocable method is wired with a bot dialogue to fetch
    * no of digits needed for account verification
    * @return List<NoOfDigitsResponse>
    **/
    @InvocableMethod(label='Get Number Of digits for account check' description='Returns the number of last digits required from the customer. Can be overriden.')
    public static List<NoOfDigitsResponse> getNumberOfDigitsForAccountCheck() {
        Integer csnoofDigits = IBot_ConfigSettings.getInstance().getNoOfDigitsforAccCheck();
        List<NoOfDigitsResponse> responseList = new List<NoOfDigitsResponse>();
        NoOfDigitsResponse response = new NoOfDigitsResponse();
        response.integrationUserId = UserInfo.getUserId();
        response.noOfDigits = csnoofDigits;
        responseList.add(response);
        return responseList;
    }
}