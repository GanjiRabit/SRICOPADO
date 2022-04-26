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
 * @description Dynamic SOQL Query Utility Class
 */
public with sharing class IBot_DynamicQueryUtils{
    /**
	* @description this method builds the financial account dynamic SOQL query using the below params
	* @param the last n digits of financial account
	* @param the verification method value the bot user has given
	* @param the verificaton method the user has chosen
	* @return the financial account dynamic SOQL query as string
	*/
    public static String buildFinancialAccountQuery(String lastDigitsOfAccount, String verificationFieldValue, String verificationMethod) {
        
        List<String> fieldsList = IBot_ConfigSettings.getInstance().getSelectFieldsListForFADQ();
        String accTypeFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountTypeFieldAPIName();
        String accNumFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountNumberFieldAPIName();
        String primaryOwnerMobileField = IBot_ConfigSettings.getInstance().getPrimaryOwnerMobileRelationshipName();
        String financialAccountObjectAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountObjectAPIName();
        List<String> supportedAccTypes = IBot_ConfigSettings.getInstance().getListBotSupportedFinancialAccountTypes();
        String primaryOwnerContactIdField = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactIdRelationshipName();
        String primaryOwnerContactFirstNameField = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactFNameRelationshipName();
        String primaryOwnerContactGAUSerIdField = IBot_ConfigSettings.getInstance().getPrimaryOwnerContactGAUserIdFieldName();
        String primaryOwnerEmailField = IBot_ConfigSettings.getInstance().getPrimaryOwnerEmailRelationshipName();
        String soql = '';
        
        IBot_PrintUtils.print('verification method ' + verificationMethod);
        IBot_PrintUtils.print('verification method ' + verificationFieldValue);
        IBot_PrintUtils.print('verification method ' + lastDigitsOfAccount);
        
        //adding additional fields. Due to the field length limitation we cannot add more fields to custom metadata field value. Have to split this into
        //multiple records
        fieldsList.add(primaryOwnerMobileField);
        fieldsList.add(primaryOwnerEmailField);
        fieldsList.add(primaryOwnerContactGAUSerIdField);
        
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(financialAccountObjectAPIName);
        
        if(fscIBot_AccessController.isAccessible()) {
            String whereCondition = ' where ' + accNumFieldAPIName + ' like \'%' + String.escapeSingleQuotes(lastDigitsOfAccount) + '\'';
            whereCondition +=   ' AND '  + accTypeFieldAPIName + ' in ' + IBot_Utils.createInFilter(supportedAccTypes);

            if(String.isNotBlank(verificationMethod) && verificationMethod.equalsIgnoreCase('Mobile Number')) {
                whereCondition += ' AND ' + primaryOwnerMobileField +  '=\'' + String.escapeSingleQuotes(verificationFieldValue) + '\'';
            } else if(String.isNotBlank(verificationMethod) && verificationMethod.equalsIgnoreCase('Google Authenticator')) {
                whereCondition += ' AND ' + primaryOwnerContactGAUSerIdField +  '=\'' + String.escapeSingleQuotes(verificationFieldValue) + '\'';
            } else {
                whereCondition += ' AND ' + primaryOwnerEmailField +  '=\'' + String.escapeSingleQuotes(verificationFieldValue) + '\'';
            }

            soql  = 'select ' + String.join(fieldsList,',') + ' from ';
            soql += financialAccountObjectAPIName + ' ';
            soql += whereCondition;
            IBot_PrintUtils.print('Financial Account Query ' + soql);
 
        } else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(financialAccountObjectAPIName + ' ' + Label.ibot_obj_not_readable);
        }
        
        return soql;
    }
    
    /**
	* @description this method builds the financial card dynamic SOQL query using the below params
	* @param the list of financial account Ids
	* @return the card dynamic SOQL query as string
	*/
    public static String buildFinancialCardQuery(List<Id> faccIds) {
        List<String> fieldsList = IBot_ConfigSettings.getInstance().getSelectFieldsListForCardDQ();
        String financialCardObjectAPIName = IBot_ConfigSettings.getInstance().getCardObjectAPIName();
        String cardFALkpAPIName = IBot_ConfigSettings.getInstance().getCardFALookUpAPIName();
        String cardValitUntilFieldAPIName = IBot_ConfigSettings.getInstance().getCardValidUntilFieldAPIName();
        String cardActiveFieldAPIName = IBot_ConfigSettings.getInstance().getCardActiveFieldAPIName();
        String cardquery = '';
        
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(financialCardObjectAPIName);
        if(fscIBot_AccessController.isAccessible()){
        	if(fscIBot_AccessController.isFieldListAccessible(fieldsList)){	
                String whereCondition = ' where ' + cardFALkpAPIName + ' in ' + IBot_Utils.createInFilter(faccIds);
                whereCondition +=   ' AND '  + cardValitUntilFieldAPIName + ' >= TODAY';
                whereCondition +=   ' AND '  + cardActiveFieldAPIName + '=true';

                cardquery  = 'select ' + String.join(fieldsList,',') + ' from ';
                cardquery += financialCardObjectAPIName + ' ';
                cardquery += whereCondition;
                IBot_PrintUtils.print('cardquery ' + cardquery);
            }
        } else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(financialCardObjectAPIName + ' ' + Label.ibot_obj_not_readable);
        }
        
        return cardquery;
    }

    public static List<sObject> fetchCardsGivenFinancialAccIds(List<Id> faccIds) {
        String cardquery = buildFinancialCardQuery(faccIds);
        List<sObject> cards = IBot_DaoService.getInstance().fetchSObject(cardquery);

        return cards;         
    }
    
    public static List<sObject> fetchFinancialAccounts(String lastDigitsOfAccount, String verificationFieldValue, String verificationMethod) {
        String faquery = buildFinancialAccountQuery(lastDigitsOfAccount,verificationFieldValue,verificationMethod);
        IBot_PrintUtils.print('faquery ' + faquery);
        List<sObject> financialAccounts = IBot_DaoService.getInstance().fetchSObject(faquery);

        return financialAccounts;           
    }

    public static Boolean validateFinancialAccountNumber(String lastDigitsOfAccount) {
        Boolean isAccountNumberValid = false;
        String accTypeFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountTypeFieldAPIName();
        String accNumFieldAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountNumberFieldAPIName();
        String financialAccountObjectAPIName = IBot_ConfigSettings.getInstance().getFinancialAccountObjectAPIName();
        List<String> supportedAccTypes = IBot_ConfigSettings.getInstance().getListBotSupportedFinancialAccountTypes();
        String soql = '';
        
        
        
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController(financialAccountObjectAPIName);
        
        if(fscIBot_AccessController.isAccessible()) {
            String whereCondition = ' where ' + accNumFieldAPIName + ' like \'%' + String.escapeSingleQuotes(lastDigitsOfAccount) + '\'';
            whereCondition +=   ' AND '  + accTypeFieldAPIName + ' in ' + IBot_Utils.createInFilter(supportedAccTypes);

            soql  = 'select Id' + ' from ';
            soql += financialAccountObjectAPIName + ' ';
            soql += whereCondition;
            IBot_PrintUtils.print('Financial Account Query ' + soql);

            List<sObject> financialAccounts = IBot_DaoService.getInstance().fetchSObject(soql);
            isAccountNumberValid = (financialAccounts.size() > 0) ? true : false;
 
        } else if(!fscIBot_AccessController.isAccessible()){
            throw new IBot_CustomException(financialAccountObjectAPIName + ' ' + Label.ibot_obj_not_readable);
        }

        return isAccountNumberValid;           
    }

    public static Map<String, FscBot_Verification_Code__c> fetchActiveVerificationCodesMap(List<String> contactIds, List<Integer> codes) {
        Map<String, FscBot_Verification_Code__c> verificationCodeMap = new Map<String, FscBot_Verification_Code__c>();
        List<String> fieldsList = new List<String>{'Id','Expires_On__c','Code__c','Used__c','Verification_Method__c','Contact__c'};

        String whereCondition = ' where Contact__c in ' + IBot_Utils.createInFilter(contactIds);
        whereCondition += ' AND  '  + ' Code__c in ' + IBot_Utils.createInFilter(codes);
        whereCondition += ' AND '  + ' Used__c=false';
        whereCondition += ' AND '  + ' Expires_On__c >= TODAY';
        
        List<FscBot_Verification_Code__c> vCodes = (List<FscBot_Verification_Code__c>)IBot_DaoService.getInstance().fetchSObject('FscBot_Verification_Code__c', fieldsList, whereCondition, null);
        
        for(FscBot_Verification_Code__c vcode : vCodes){
            String code = vcode.Code__c == null ? '' : Integer.valueOf(vcode.Code__c).format();
            String contactId = vcode.Contact__c == null ? '' : vcode.Contact__c;
            String key = contactId + '_' + code;
            verificationCodeMap.put(key, vcode);
        }
        return verificationCodeMap;
    }

    public static void updateVerificaitonCodes(List<FscBot_Verification_Code__c> codes) {
        IBot_DaoService.getInstance().updateSObject('FscBot_Verification_Code__c', codes);
    }

    public static List<Contact> fetchContactsGivenIds(List<Id> contactIds) {
        List<String> fieldsList = new List<String>{'Id','mobilePhone','email','FirstName','LastName'};
        String whereCondition = ' where Id in ' + IBot_Utils.createInFilter(contactIds);
        List<Contact> contactList = (List<Contact>)IBot_DaoService.getInstance().fetchSObject('Contact', fieldsList, whereCondition, null);
        return contactList;
    }

    public static void clearExistingVerificationCodes(List<Contact> contacts){
        List<String> contactIds = IBot_Utils.getIdValues(contacts);
        String whereCondition = ' where Contact__c in ' + IBot_Utils.createInFilter(contactIds);
        String objApiName = 'FscBot_Verification_Code__c';
        IBot_DaoService.getInstance().deleteSObject(objApiName,whereCondition);
    }
    
    public static List<SObject> createNewVerificationCodes(List<FscBot_Verification_Code__c> vcodes){
        String objApiName = 'FscBot_Verification_Code__c';
        return IBot_DaoService.getInstance().createSObject(objApiName,vcodes);
    }

    public static FscBot_TravelRequest__c createNewTravelRequest(FscBot_TravelRequest__c tr){
        String objApiName = 'FscBot_TravelRequest__c';
        List<FscBot_TravelRequest__c> trList = new List<FscBot_TravelRequest__c>();
        trList.add(tr);
        List<SObject> objRecords = IBot_DaoService.getInstance().createSObject(objApiName,trList);
        return tr; 
    }

    public static FscBot_LostCard__c createNewLostCardRequest(FscBot_LostCard__c lc){
        String objApiName = 'FscBot_LostCard__c';
        List<FscBot_LostCard__c> lcList = new List<FscBot_LostCard__c>();
        lcList.add(lc);
        List<SObject> objRecords = IBot_DaoService.getInstance().createSObject(objApiName,lcList);
        return lc; 
    }

    public static List<FscBot_TravelRequest__c> fetchActiveTravelRequestsForContact(Id contactId){
        List<String> fieldsList = new List<String>{'Id', 'FromDate__c', 'ToDate__c', 'Travelling_Country__c', 'contact__c', 'case__c'};
        String whereCondition  = ' where Contact__c =\'' + String.escapeSingleQuotes(contactId) + '\'';
               whereCondition += ' AND IsActive__c =true';
        String objApiName = 'FscBot_TravelRequest__c';
        List<FscBot_TravelRequest__c> trList = (List<FscBot_TravelRequest__c>)IBot_DaoService.getInstance().fetchSObject(objApiName, fieldsList, whereCondition, null);
        return trList;
    }
    
    public static Map<String, Contact> fetchContactsGivenAccntAndMobileOREmail(Set<String> verificationEmailSet, Set<String> verificationMobileSet,Set<Id> primaryAccountIds){
        List<String> fieldsList = new List<String>{'Id','Email','MobilePhone','Phone','AccountId'};
        String objApiName = 'Contact';
        Map<String, Contact> accountIdContactMap = new Map<String,Contact>();
        String emailCondition = (!verificationEmailSet.isEmpty()) ? ' Email in ' + IBot_Utils.createInFilter(new List<String>(verificationEmailSet)) : '';
        String mobilePhoneCondition = (!verificationMobileSet.isEmpty()) ? ' MobilePhone in ' + IBot_Utils.createInFilter(new List<String>(verificationMobileSet)) : '';
        String accountCondition = (!primaryAccountIds.isEmpty()) ? ' AccountId in ' + IBot_Utils.createInFilter(new List<Id>(primaryAccountIds)) : '';
        String whereCondition  = ' where ' + accountCondition + ' AND (';
               whereCondition += String.isNotBlank(emailCondition) ? emailCondition : '';
               whereCondition += String.isNotBlank(emailCondition) &&  String.isNotBlank(mobilePhoneCondition)? ' OR ' : '';
               whereCondition += String.isNotBlank(mobilePhoneCondition) ? mobilePhoneCondition : '';
               whereCondition += ')';
            
        List<Contact> contactsList = (List<Contact>)IBot_DaoService.getInstance().fetchSObject(objApiName, fieldsList, whereCondition, null);
        for(Contact c: contactsList) {
            accountIdContactMap.put(c.AccountId,c);
        }
        return accountIdContactMap;
    }
    
    public static Case fetchCase(Id caseId){
        List<String> fieldsList = new List<String>{'Id','caseNumber'};
        String objApiName = 'Case';
        String whereCondition  = ' where Id =\'' + String.escapeSingleQuotes(caseId) + '\'';
        IBot_AccessController fscIBot_AccessController = new IBot_AccessController('Case');
        List<Case> caseList = (List<Case>)IBot_DaoService.getInstance().fetchSObject(objApiName, fieldsList, whereCondition, null);
        Case c = null;
        if(!caseList.isEmpty()) {
            c = caseList.get(0);
        }
        return c;
    }

    public static List<Case> getCasesUsingChatKeys(List<String> chatKeys) {
        List<String> fieldsList = new List<String>{'Id','ChatKey__c'};
        String whereCondition = ' where ChatKey__c in ' + IBot_Utils.createInFilter(chatKeys);
        String objApiName = 'Case';
        List<Case> caseList = (List<Case>)IBot_DaoService.getInstance().fetchSObject(objApiName, fieldsList, whereCondition, null);
        return caseList;
    }
}