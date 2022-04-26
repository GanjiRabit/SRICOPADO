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
 * @description case service which creates a case
 **/
public with sharing class IBot_CaseService implements IBot_ServiceInterface{
    private static IBot_CaseService  botIBot_CaseService = new IBot_CaseService();

    /*
        private constructor to make a singleton instance
     */
    private IBot_CaseService() {
    }

    /*
     * Static method that returns singleton instance.
     */
    public static IBot_CaseService getInstance() {
        return botIBot_CaseService;
    }
    
    public Case insertCase(Id financialAccId, Id contactId, String subject, String description, String priority, String chatKey) {
        String caseFSLkpAPIName = IBot_ConfigSettings.getInstance().getCaseFALookUpAPIName();
        String chatKeyFieldAPIName = IBot_ConfigSettings.getInstance().getCaseChatKeyFieldAPIName();
        SObject caseObj = IBot_DynamicSObjectCreation.createObject('Case'); 
        caseObj.put('contactId', contactId);
        caseObj.put('subject', subject);
        caseObj.put('description', description);
        caseObj.put('priority', priority);
        caseObj.put(caseFSLkpAPIName, financialAccId);
        caseObj.put(chatKeyFieldAPIName, chatKey);
        List<SObject> objList = new List<SObject>();
        objList.add(caseObj);
        List<SObject> caseSObjList = IBot_DaoService.getInstance().createSObject('Case', objList);
        Case newCase = null;
        if(!caseSObjList.isEmpty()) {
            caseObj = caseSObjList.get(0);
            newCase = IBot_DynamicQueryUtils.fetchCase((Id)caseObj.get('Id'));
        }
        
        return newCase;
    }
}