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
 * @description creates a new travel request case for a given financial account debit/credit card
 **/
global with sharing class FscBot_TravelRequestLogACaseCtrl {
	global class CaseRequest{
        @InvocableVariable
        global Contact con;
        @InvocableVariable
        global Date fromDate;
        @InvocableVariable
        global Date toDate;
        @InvocableVariable
        global String travelCountry;
        @InvocableVariable
        global String selectedCard;
        @InvocableVariable
        global String financialAccId;
        @InvocableVariable
        global String chatKey;
    }
    global class CaseResponse{
        @InvocableVariable
        global String caseNumber;
        @InvocableVariable
        global String message;
        @InvocableVariable
        global String caseId;
        @InvocableVariable
        global String travelRequestId;
    }
    
    /**
    * @description this invocable method is wired with a bot dialogue to
    * create a new travel request case
    * @param List<CaseRequest> inputList
    * @return List<CaseResponse>
    **/
    @InvocableMethod(label='Create Travel Request Case' description='Creates a Case for Travel Request')
    public static List<CaseResponse> createCase(List<CaseRequest> inputList) {
        
        /// REVIEW: if the i/p is List, it should be iterated. why Only 1st request is processed?
        List<CaseResponse> bulkResponse = new List<CaseResponse>();
        if(inputList == null || inputList.isEmpty() || inputList.get(0) == null) {
            CaseResponse response = new CaseResponse();
            bulkResponse.add(response);
            return bulkResponse;
        }

        IBot_CaseService caseService = (IBot_CaseService) IBot_ServiceFactory.getInstance().getService('Case');

        CaseRequest request = inputList.get(0); 
        String subject = Label.ibot_travel_request_case_subject + ' ' + request.selectedCard;
        String description = Label.ibot_travel_request_case_subject + ' ' + request.selectedCard;
        Case newCase = caseService.insertCase(request.financialAccId, request.con.Id, subject, description, 'High', request.chatKey);
        CaseResponse response = new CaseResponse();
        response.caseNumber = newCase.caseNumber;
        response.caseId = newCase.Id;
        response.message = Label.ibot_case_submit_message + ' ' + newCase.caseNumber + '.';

        //create a travel request record
        FscBot_TravelRequestService travelRequestService = (FscBot_TravelRequestService) IBot_ServiceFactory.getInstance().getService('TravelRequest');
        response.travelRequestId = travelRequestService.createNewTravelRequest(request.con.Id, newCase.Id, request.fromDate, request.toDate, request.travelCountry, request.financialAccId);              
        
        bulkResponse.add(response);
        return bulkResponse;
        
    }
}