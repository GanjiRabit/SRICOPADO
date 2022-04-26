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
 * @description Holds all the custom settings needed for the bot map.
 * If a custom metadata type is defined it is used other wise each custom metadata
 * has a default value
 **/
public with sharing class IBot_ConfigSettings extends IBot_ConfigBeanBase {
	// Singleton instance of this bean.
    private static IBot_ConfigSettings bean = new IBot_ConfigSettings();


    /**
     * Private constructor, initializes environment properties
     */
    private IBot_ConfigSettings() {
        super();
    }

    /**
     * Static method that returns singleton instance.
     */
    public static IBot_ConfigSettings getInstance() {
        return bean;
    }
    
    public String getSMSService(){
        return getStringValue('SMSService','Twilio');
    }
    
    public Boolean isTwoFactorAuthenticationEnabled(){
        return getBooleanValue('TwoFactorAuthenticationEnabled',false);
    }
    
    public Boolean isDemoModeEnabled(){
        return getBooleanValue('DemoModeEnabled',false);
    }
    
    public Integer getNoOfDigitsforAccCheck(){
        return getIntegerValue('NoOfDigitsInAccountCheck',6);
    }
    
    public String getAccountNumberFieldAPIName(){
        return getStringValue('FinancialAccountNumberField','FinServ__FinancialAccountNumber__c');
    }
    
    public String getFinancialAccountNumberFieldAPIName(){
        return getStringValue('FinancialAccountNumberField','FinServ__FinancialAccountNumber__c');
    }
    
    public List<String> getListBotSupportedFinancialAccountTypes(){
        return getCSVToListValue('BotSupportedAccountTypes',new List<String>{'Checking','Credit Card'});
    }
    
    public String getFinancialAccountObjectAPIName(){
    	return getStringValue('FinancialAccountObject','FinServ__FinancialAccount__c');
    }
    
    public String getFinancialAccountPOFieldAPIName() {
        return getStringValue('FinancialAccountPOField','FinServ__PrimaryOwner__c');
    }
    
    public String getFinancialAccountTypeFieldAPIName(){
    	return getStringValue('FinancialAccountTypeField','FinServ__FinancialAccountType__c');
    }
    
    public String getPrimaryOwnerContactEmailRelationshipName() {
        return getStringValue('PrimaryOwnerContactEmailRelationship','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.Email');
    }
    
    public String getPrimaryOwnerContactGAUserIdFieldName() {
        return getStringValue('PrimaryOwnerContactGAUserIdFieldName','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.GAUserId__c');
    }
    
    public String getPrimaryOwnerContactMobileRelationshipName() {
        return getStringValue('PrimaryOwnerContactMobileRelationship','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.MobilePhone');
    }
    
    public String getPrimaryOwnerContactIdRelationshipName() {
        return getStringValue('PrimaryOwnerContactIdRelationship','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.Id');
    }
    
    public String getPrimaryOwnerContactFNameRelationshipName() {
        return getStringValue('PrimaryOwnerContactFNameRelationship','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.FirstName');
    }
    
    public String getPrimaryOwnerEmailRelationshipName() {
        return getStringValue('PrimaryOwnerEmailRelationship','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.Email');
    }
    
    public String getContactGAUSerIdFieldName() {
        return getStringValue('ContactGAUserId','GAUserId__c');
    }
    
    public String getPrimaryOwnerMobileRelationshipName() {
        return getStringValue('PrimaryOwnerMobileRelationship','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.MobilePhone');
    }
    
    public Boolean isEnforceFSCPackageInstallation() {
        return getBooleanValue('FSCPackageInstalltionNeeded',true);
    }
    
    public String getPrimaryOwnerRelationshipName() {
        return getStringValue('PrimaryOwnerRelationshipName','FinServ__PrimaryOwner__r');
    }
    
    public String getPrimaryOwnerContactRelationshipName() {
        return getStringValue('PrimaryOwnerContactRelationshipName','FinServ__PrimaryContact__r');
    }
    
    public List<String> getSelectFieldsListForFADQ() {
        List<String> fieldsList = getCSVToListValue('FieldsListForFADQ',new List<String>{'Id','FinServ__FinancialAccountNumber__c','FinServ__PrimaryOwner__c','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.Id','FinServ__PrimaryOwner__r.FinServ__PrimaryContact__r.FirstName','Name'});
    	return fieldsList;
    }
    
    public List<String> getSelectFieldsListForCardDQ() {
        return getCSVToListValue('SelectFieldsForCardsDQ',new List<String>{'Id','FinServ__BinNumber__c','FinServ__FinancialAccount__c','Name'});
    }
    
    public String getCardObjectAPIName() {
        return getStringValue('CardObjectAPIName','FinServ__Card__c');
    }
    
    public String getCardFALookUpAPIName() {
        return getStringValue('CardObjectFALkpAPIName','FinServ__FinancialAccount__c');
    } 
    
    public String getCardNumberFieldAPIName() {
        return getStringValue('CardNumberFieldAPIName','FinServ__BinNumber__c');
    } 
    
    public String getCaseFALookUpAPIName() {
        return getStringValue('CardFALkpAPIName','FinServ__FinancialAccount__c');
    } 
    
    public String getOrgWideEmailAddress() {
        return getStringValue('BotOrgWideEmailAddress','');
    }
    
    public String getEmailService() {
        return getStringValue('EmailService','IBot_OOBEmailService');
    }
    
    public String getMessagingService() {
        return getStringValue('GenericMessagingService','IBot_OOBTwilioMessagingService');
    }
    
    public String getnoReplyEmailAddress() {
        return getStringValue('NoReplyEmailAddress','');
    }
    
	public String getTwilioFromPhoneNumber(){
        return getStringValue('TwilioFromPhoneNumber','');
    }
    
    public String getTwilioAccountSid(){
        return getStringValue('TwilioAccountSid','');
    }
    
    public String getTwilioAuthToken(){
        return getStringValue('TwilioAuthToken','');
    }
    
     public String getTwilioEndPoint(){
         return getStringValue('TwilioEndPoint','https://api.twilio.com/2010-04-01/Accounts/{accountSid}/SMS/Messages.json');
    }
    
    public Boolean isOTPTestModeEnabled(){
        return getBooleanValue('OTPTestModeEnabled',true);
    }
    
    public Integer getVCExpirationMinutes() {
        return getIntegerValue('VCExpirationMinutes',15);
    }
    
    public String getCardValidUntilFieldAPIName(){
        return getStringValue('CardValidUntilField','FinServ__ValidUntil__c');
    }
    
    public String getCardActiveFieldAPIName(){
        return getStringValue('CardActiveField','FinServ__Active__c');
    }
    
    public String getCaseChatKeyFieldAPIName(){
        return getStringValue('CaseChatKeyFieldAPIName','ChatKey__c');
    }
    
    public String getTimebasedOTPDefaultUserId(){
        return getStringValue('TimebasedOTPDefaultUserId','');   
    }
    
    public String getTimebasedOTPAppKey(){
        return getStringValue('TimebasedOTPAppKey','');   
    }
    
    public String getTimebasedOTPAuthenticator(){
        return getStringValue('TimebasedOTPAuthenticator','IBot_OOBTimebasedOTPAuthenticator');   
    }

    public String getCardNumberMask() {
        return getStringValue('CardNumberMask','XXXX-XXXX-XXXX-');
    }

    public Boolean isDebugEnabled() {
        return getBooleanValue('isDebugEnabled',true);
    }

    public String getDemoFinancialAccountNumber() {
        return getStringValue('DemoFANumber','212121');
    }

    public Integer getDemoOTP() {
        return getIntegerValue('DemoOTP',112233);
    }

    public String getAuthyEndPoint() {
        return getStringValue('TwilioAuthyEndpoint','http://api.authy.com/protected/json/verify/{totp}/{userId}');
    }
}