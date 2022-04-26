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
public with sharing class IBot_LiveChatTranscriptTriggerHelper {
    public static void handleAfterInsert(List<LiveChatTranscript> newRecords){
        updateCaseIdOnTranscripts(newRecords);
    }
    
    private static void updateCaseIdOnTranscripts(List<LiveChatTranscript> newRecords){
        List<String> chatKeys = new List<String>();
        Map<String,LiveChatTranscript> tmap = new Map<String,LiveChatTranscript>();
    	for(LiveChatTranscript elem : newRecords){
        	chatKeys.add(elem.ChatKey);
            tmap.put(elem.ChatKey,elem);
        }
        
        List<Case> caseList = IBot_DynamicQueryUtils.getCasesUsingChatKeys(chatKeys);
        for(Case elem : caseList){
            if(tmap.get(elem.ChatKey__c) != NULL && tmap.get(elem.ChatKey__c).Id != NULL) {
                elem.Live_Chat_Transcript__c = tmap.get(elem.ChatKey__c).Id;
            }
        }
        
        if(!caseList.isEmpty()) {
            Database.update(caseList);
        }
    }
}