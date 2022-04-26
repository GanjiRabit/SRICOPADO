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
 * @description service to fetch and create lost cards for a Individual Contact
 **/
public with sharing class FscBot_LostCardService implements IBot_ServiceInterface{
    
    
    private static FscBot_LostCardService  botTRService = new FscBot_LostCardService();

    /*
        private constructor to make a singleton instance
     */
    private FscBot_LostCardService() {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static FscBot_LostCardService getInstance() {
        return botTRService;
    }
    
    /**
    * @description creates  a new lost cards requests for a given contact and links the support case to the lost card
    * @param Id contactId, Id caseId, Date fromDate, Date toDate, String travelCountry, String financialAccId
    * @return String
    **/
    public String createNewLostCardRequest(Id contactId, Id caseId, String financialAccId, String selectedCard) {
        FscBot_LostCard__c lc = new FscBot_LostCard__c();
        lc.contact__c = contactId;
        lc.case__c = caseId;
        lc.Card_Number__c = selectedCard;
        lc.FinancialAccountNumber__c = financialAccId;
        
        FscBot_LostCard__c lostCard = IBot_DynamicQueryUtils.createNewLostCardRequest(lc);
        return lostCard.Id;
    }
}