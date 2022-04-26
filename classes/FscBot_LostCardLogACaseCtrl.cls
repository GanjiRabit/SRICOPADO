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
 * @description Creates a case for a lost/stolen card scenario
 **/

global with sharing class FscBot_LostCardLogACaseCtrl {
	global class CaseRequest{
        @InvocableVariable
        global Contact con;
        @InvocableVariable
        global String financialAccId;
        @InvocableVariable
        global String selectedCard;
        @InvocableVariable
        global String chatKey;
    }
    global class CaseResponse{
        @InvocableVariable
        global String caseNumber;
        @InvocableVariable
        global String message;
        @InvocableVariable
        global FscBot_TravelRequest__c travelrequest;
        @InvocableVariable
        global String caseId;
    }
    
    /**
    * @description this invocable method is wired with a bot dialogue to create a case for
    * lost card associated with a financial account.
    * @param List<CaseRequest> inputList
    * @return List<CaseResponse>
    **/
    @InvocableMethod(label='Create Lost Card Case' description='Creates a Case for Lost Card')
    public static List<CaseResponse> createCase(List<CaseRequest> inputList) {
        List<CaseResponse> bulkResponse = new List<CaseResponse>();
        if(inputList == null || inputList.isEmpty() || inputList.get(0) == null) {
            CaseResponse response = new CaseResponse();
            bulkResponse.add(response);
            return bulkResponse;
        }
        CaseRequest request = inputList.get(0);
        String subject = Label.ibot_lost_card_case_subject + ' ' + request.selectedCard;
        String description = Label.ibot_lost_card_case_subject + ' ' + request.selectedCard;
        IBot_PrintUtils.print('request ' + request);
        IBOT_CaseService caseService = (IBOT_CaseService)IBot_ServiceFactory.getInstance().getService('Case');
        Case newCase = caseService.insertCase(request.financialAccId, request.con.Id,subject, description, 'High',request.chatKey);
        CaseResponse response = new CaseResponse();
        response.caseNumber = newCase.caseNumber;
        response.caseId = newCase.Id;

        //create a lost card
        FscBot_LostCardService lostcardRequestService = (FscBot_LostCardService) IBot_ServiceFactory.getInstance().getService('LostCard');
        lostcardRequestService.createNewLostCardRequest(request.con.Id, newCase.Id, request.financialAccId, request.selectedCard);  

        List<FscBot_TravelRequest__c> trList = IBot_DynamicQueryUtils.fetchActiveTravelRequestsForContact(request.con.Id);
        
        if(trList.isEmpty()) {
            response.message =  Label.ibot_case_submit_message + ' ' + newCase.caseNumber + '.';
        } else {
            response.message = Label.ibot_active_travel_requests;
            response.travelrequest = trList.get(0);
            //TODO convert list to string list as bot builder currently doesn't support
            //list of custom objects
        }
        
        bulkResponse.add(response);
        return bulkResponse;
        
    }
 
}