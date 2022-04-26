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
 * @description service to fetch and create travel requests for a Individual Contact
 **/
public with sharing class FscBot_TravelRequestService implements IBot_ServiceInterface{
    
    
    private static FscBot_TravelRequestService  botTRService = new FscBot_TravelRequestService();

    /*
        private constructor to make a singleton instance
     */
    private FscBot_TravelRequestService() {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static FscBot_TravelRequestService getInstance() {
        return botTRService;
    }
    
    /**
    * @description fetches active travel requests for a given contact
    * @param Id contactId
    * @return FscBot_TravelRequest__c
    **/
    public List<FscBot_TravelRequest__c> fetchActiveTravelRequests(Id contactId) {
        return IBot_DynamicQueryUtils.fetchActiveTravelRequestsForContact(contactId);
    }

    /**
    * @description creates  a new travel requests for a given contact
    * @param Id contactId, Date fromDate, Date toDate, String travelCountry, String selectedAccNo
    * @return String
    **/
    public String createNewTravelRequest(Id contactId, Date fromDate, Date toDate, String travelCountry, String selectedAccNo) {
        return createNewTravelRequest(contactId,null,fromDate,toDate,travelCountry,selectedAccNo);
    }
    
    /**
    * @description creates  a new travel requests for a given contact and links the support case to the travel request
    * @param Id contactId, Id caseId, Date fromDate, Date toDate, String travelCountry, String selectedAccNo
    * @return String
    **/
    public String createNewTravelRequest(Id contactId, Id caseId, Date fromDate, Date toDate, String travelCountry, String selectedAccNo) {
        FscBot_TravelRequest__c tr = new FscBot_TravelRequest__c();
        tr.contact__c = contactId;
        tr.case__c = caseId;
        tr.FromDate__c = date.valueOf(fromDate);
        tr.ToDate__c  = date.valueOf(toDate);
        tr.Travelling_Country__c  = travelCountry;
        tr.FinancialAccountNumber__c = selectedAccNo;
        
        FscBot_TravelRequest__c travelRequest = IBot_DynamicQueryUtils.createNewTravelRequest(tr);
        return travelRequest.Id;
    }
}