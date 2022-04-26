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
 * @description Fetches the active debit/credit cards associated with a financial account
 **/
global with sharing class FscBot_FetchCardsAssociatedWithFACtrl {
    
    /**
    * @description this invocable method is wired with a bot dialogue to fetch the active cards 
    * associated with a financial account. This method is called by the BOT once 
    * the user verification is done.
    * @param List<String> accountIds
    * @return List<List<String>> list of masked active card numbers
    **/
    @InvocableMethod(label='Fetch Cards Associated With Financial Account' description='Returns the list of cards associated with the accountId provided')
    public static List<List<String>> getActiveCards(List<String> accountIds) {
        if(accountIds.size() == 0){
            return new List<List<String>>();
        }
        
        String cardNumberField = IBot_ConfigSettings.getInstance().getCardNumberFieldAPIName();
       	List<SObject> cards = IBot_DynamicQueryUtils.fetchCardsGivenFinancialAccIds(accountIds);
        String cardNumberMask = IBot_ConfigSettings.getInstance().getCardNumberMask();
        List<String> maskedCC = new List<String>();
        for(SObject cardSObj : cards){
            maskedCC.add(cardNumberMask + String.valueOf(cardSObj.get(cardNumberField)).right(4) + ' - '+ cardSObj.get('Name'));
        }
        
        List<List<String>> cardList = new List<List<String>>();
        cardList.add(maskedCC);
        return cardList;
    }
}