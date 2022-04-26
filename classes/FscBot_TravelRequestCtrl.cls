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
 * @description creates a new travel request for a given contact and financial account
 **/

global with sharing class FscBot_TravelRequestCtrl{
    global class TravelRequest{
        @InvocableVariable
        global Contact contact;
        @InvocableVariable
        global Date fromDate;
        @InvocableVariable
        global Date toDate;
        @InvocableVariable
        global String travelCountry;
        @InvocableVariable
        global String selectedAccNo;
    }
    
    global class Response{
        @InvocableVariable
        global String travelRequestId;
    }

    /**
    * @description this invocable method is wired with a bot dialogue to
    * create a new travel request
    * @param List<TravelRequest> requestList
    **/
     @InvocableMethod(label='Create Travel Request' description='Creates the Travel Request record for this request')
     global static List<Response> createTravelRequest(List<TravelRequest> requestList) {
          FscBot_TravelRequestService travelRequestService = (FscBot_TravelRequestService) IBot_ServiceFactory.getInstance().getService('TravelRequest');
          List<Response> responses = new List<Response>();
          for(TravelRequest ctr : requestList){
              Response response = new Response();
              // Validate that fromDate should be before toDate
              if(ctr.fromDate <= ctr.toDate){
		          response.travelRequestId = travelRequestService.createNewTravelRequest(ctr.contact.Id, ctr.fromDate, ctr.toDate, ctr.travelCountry, ctr.selectedAccNo);              
              }
              responses.add(response);
          }
         return responses;
     }
}